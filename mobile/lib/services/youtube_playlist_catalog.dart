import 'package:http/http.dart' as http;
import 'package:flick/features/discovery/lastfm_discovery.dart';
import 'package:flick/features/discovery/youtube_music_account.dart';
import 'package:flick/features/discovery/youtube_music_playlist_cache.dart';
import 'package:flick/features/discovery/youtube_music_store.dart';
import 'package:flick/features/konnekted/konnekted_discovery.dart'
    show discoveryPendingSong;
import 'package:flick/models/song.dart';

/// Background car launches use the same secure account and metadata cache as
/// the phone. Each operation owns its HTTP client; credentials never leave
/// YouTube's account API or enter media IDs.
class YoutubePlaylistCatalog {
  YoutubePlaylistCatalog({
    YoutubeMusicSessionStore? store,
    YoutubeMusicPlaylistCache? cache,
  }) : _store = store ?? YoutubeMusicSessionStore(),
       _cache = cache ?? YoutubeMusicPlaylistCache.instance;
  final YoutubeMusicSessionStore _store;
  final YoutubeMusicPlaylistCache _cache;

  Future<List<T>> _read<T>(
    Future<List<T>> Function(YoutubeMusicAccount) read,
  ) async {
    final session = await _store.read();
    if (session == null) return [];
    final client = http.Client();
    try {
      return await read(YoutubeMusicAccount(client, session));
    } finally {
      client.close();
    }
  }

  Future<List<LokalDiscoveryMix>> playlists() => _read((api) async {
    final saved = await _cache.playlists(api.session.accountKey);
    // Metadata cached by the foreground library keeps car startup bounded.
    if (saved != null) return saved;
    return _cache.refreshLibrary(api);
  });

  Future<List<Song>> songs(String id, List<Song> library) => _read((api) async {
    final saved = await _cache.tracks(api.session.accountKey, id);
    final tracks = saved ?? await _cache.refreshTracks(api, id);
    return [
      for (final track in tracks)
        library
                .where((song) => song.remoteId == 'yt:${track.videoId}')
                .firstOrNull ??
            discoveryPendingSong(track),
    ];
  });
}
