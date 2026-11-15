import 'package:flick/core/utils/artist_credits.dart';
import 'package:flick/features/discovery/discovery_models.dart';
import 'package:flick/features/discovery/discovery_sources.dart';
import 'package:flick/models/song.dart';

/// Desktop's music-video matching (electron/online/musicVideo.js), the
/// metadata half only: a YouTube Music search, then the result must be by the
/// song's artist, have the same title once "(Official Video)" and "feat. X"
/// are dropped, not be another version (live, lyric video, cover…) and run
/// about as long as the song.
///
/// Desktop then downloads the video's audio to line it up with the song;
/// mobile never fetches YouTube media. The video only ever plays in
/// YouTube's own embedded player.

const _leadSeconds = 4;
const _maxExtraSeconds = 240;

const _otherVersion = {
  'live', 'lyric', 'lyrics', 'visualizer', 'visualiser', 'audio', 'cover', //
  'slideshow', 'photo', 'static', 'remix', 'sped', 'slowed', 'reverb',
  'karaoke', 'instrumental', 'teaser', 'trailer', 'behind', 'making',
  'reaction', 'acoustic', '8d', 'nightcore', 'boosted', 'extended', 'piano',
  'tutorial', 'practice', 'performance', 'session', 'concert', 'tour',
  'rehearsal', 'shorts', 'loop', 'hour', 'mashup', 'parody',
};

final _noiseTag = RegExp(
  r'[(\[](?:[^)\]]*\b(?:official|video|hd|hq|4k|remaster(?:ed)?|explicit|clean|uncensored|mv|m/v|music video)\b[^)\]]*)[)\]]',
  caseSensitive: false,
);
final _feat = RegExp(
  r'[(\[]?\s*\b(?:feat\.?|ft\.?|featuring)\s+[^)\]]*[)\]]?',
  caseSensitive: false,
);
final _officialVideo = RegExp(
  r'\b(?:official(?:\s+music)?\s+video|official\s+mv|music\s+video)\b',
  caseSensitive: false,
);
final _vevo = RegExp(r'vevo$', caseSensitive: false);
final _channelSuffix = RegExp(r'\s*(?:vevo|official|topic)$');
final _diacritics = RegExp(r'[̀-ͯ]');
final _nonWord = RegExp(r'[^a-z0-9À-￿]+');
final _artistDash = RegExp(r'^(.+?)\s+[-–—]\s+(.+)$');

const _accents = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ç': 'c', //
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ì': 'i', 'í': 'i', 'î': 'i',
  'ï': 'i', 'ñ': 'n', 'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ø': 'o', 'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ý': 'y', 'ÿ': 'y',
};

/// Lowercase words only: no accents, punctuation or "&".
String videoMatchClean(String text) {
  final lower = text.toLowerCase().replaceAll(_diacritics, '');
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_accents[char] ?? char);
  }
  return buffer
      .toString()
      .replaceAll('&', ' and ')
      .replaceAll(_nonWord, ' ')
      .trim();
}

String _baseTitle(String title) =>
    videoMatchClean(title.replaceAll(_noiseTag, ' ').replaceAll(_feat, ' '));

List<String> _artistNames(String artist) => [
  for (final name in splitArtistCredits(artist))
    if (videoMatchClean(name).replaceAll(_channelSuffix, '').trim()
        case final cleaned when cleaned.isNotEmpty)
      cleaned,
];

bool _sameArtist(String a, String b) {
  if (a == b) return true;
  String key(String v) =>
      v.replaceFirst(RegExp(r'^the\s+'), '').replaceAll(RegExp(r'\s+'), '');
  return key(a) == key(b) ||
      key(a) == 'the${key(b)}' ||
      key(b) == 'the${key(a)}';
}

/// A video search result with what YouTube Music says it is.
class VideoCandidate {
  const VideoCandidate(this.track, {this.musicVideoType});

  final DiscoveryTrack track;

  /// MUSIC_VIDEO_TYPE_OMV for an official music video.
  final String? musicVideoType;

  bool get official =>
      musicVideoType == 'MUSIC_VIDEO_TYPE_OMV' ||
      _officialVideo.hasMatch(track.title) ||
      _vevo.hasMatch(track.artist.trim());
}

/// Whether [candidate] is [song]'s own official music video.
bool isMusicVideoFor(Song song, VideoCandidate candidate) {
  final item = candidate.track;
  if (!candidate.official) return false;
  if (candidate.musicVideoType == 'MUSIC_VIDEO_TYPE_ATV') return false;
  final songNames = _artistNames(song.artist);
  if (songNames.isEmpty) return false;
  bool bySongArtist(String artist) =>
      _artistNames(artist)
          .any((name) => songNames.any((wanted) => _sameArtist(name, wanted)));
  if (!bySongArtist(item.artist)) return false;
  var title = item.title;
  final dash = _artistDash.firstMatch(title);
  if (dash != null && bySongArtist(dash.group(1)!)) title = dash.group(2)!;
  final wanted = _baseTitle(song.title);
  if (wanted.isEmpty || _baseTitle(title) != wanted) return false;
  final songWords = videoMatchClean(song.title).split(' ').toSet();
  if (videoMatchClean(item.title)
      .split(' ')
      .any((w) => _otherVersion.contains(w) && !songWords.contains(w))) {
    return false;
  }
  final length = song.duration.inSeconds;
  final duration = item.duration?.inSeconds;
  if (length <= 0 || duration == null || duration <= 0) return true;
  return duration >= length - _leadSeconds &&
      duration <= length + _maxExtraSeconds;
}

/// Each result's musicVideoType, by video id.
Map<String, String> musicVideoTypes(Map<String, dynamic> response) {
  final types = <String, String>{};
  var nodes = 0;
  void walk(Object? value, int depth) {
    if (++nodes > 30000 || depth > 40) return;
    if (value is Map) {
      final endpoint = value['watchEndpoint'];
      if (endpoint is Map) {
        final id = endpoint['videoId'];
        final config = endpoint['watchEndpointMusicSupportedConfigs'];
        final music = config is Map ? config['watchEndpointMusicConfig'] : null;
        final type = music is Map ? music['musicVideoType'] : null;
        if (id is String && type is String) types.putIfAbsent(id, () => type);
      }
      for (final child in value.values) {
        walk(child, depth + 1);
      }
    } else if (value is List) {
      for (final child in value) {
        walk(child, depth + 1);
      }
    }
  }

  walk(response['contents'], 0);
  return types;
}

/// The YouTube video id of [song]'s official music video, or null.
/// A search only: no stream, cookie or account is used.
Future<String?> findMusicVideo(YoutubeMusicCatalog catalog, Song song) async {
  final query = '${song.artist} ${song.title}'.trim();
  if (query.isEmpty) return null;
  final response = await catalog.rawSearch(
    query.length > 200 ? query.substring(0, 200) : query,
    params: YoutubeMusicCatalog.videosFilter,
  );
  final types = musicVideoTypes(response);
  for (final track in YoutubeMusicCatalog.parse(response)) {
    final candidate = VideoCandidate(track, musicVideoType: types[track.id]);
    if (isMusicVideoFor(song, candidate)) return track.id;
  }
  return null;
}

/// YouTube's own thumbnail for a video.
String musicVideoThumbnail(String videoId) =>
    'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
