import 'package:flick/features/playlist_links/playlist_link_matcher.dart';
import 'package:flick/features/playlist_links/playlist_link_models.dart';
import 'package:flick/models/song.dart';
import 'package:flutter_test/flutter_test.dart';

Song _song(
  String id,
  String title,
  String artist, {
  String? album,
  int seconds = 180,
}) => Song(
  id: id,
  title: title,
  artist: artist,
  album: album,
  duration: Duration(seconds: seconds),
  fileType: 'FLAC',
  filePath: '/music/$id.flac',
);

void main() {
  test(
    'strict normalized title/artist matching does not select an unrelated first hit',
    () {
      final report = const PlaylistLinkMatcher().match(
        const [RemotePlaylistEntry(title: 'THE Song!', artist: 'The Artist')],
        [
          _song('wrong', 'Other Song', 'The Artist'),
          _song('right', 'the song', 'the artist'),
        ],
      );
      expect(report.matches.single.song.id, 'right');
      expect(report.unmatchedEntries, isEmpty);
    },
  );

  test(
    'ambiguous duplicates are unmatched unless duration and album distinguish them',
    () {
      final songs = [
        _song('a', 'Song', 'Artist', album: 'Album', seconds: 180),
        _song('b', 'Song', 'Artist', album: 'Other', seconds: 200),
      ];
      final ambiguous = const PlaylistLinkMatcher().match(const [
        RemotePlaylistEntry(title: 'Song', artist: 'Artist'),
      ], songs);
      final strict = const PlaylistLinkMatcher().match(const [
        RemotePlaylistEntry(
          title: 'Song',
          artist: 'Artist',
          album: 'Album',
          duration: Duration(seconds: 180),
        ),
      ], songs);
      expect(ambiguous.matches, isEmpty);
      expect(ambiguous.unmatchedEntries, hasLength(1));
      expect(strict.matches.single.song.id, 'a');
    },
  );
}
