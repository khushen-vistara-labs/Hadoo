import 'package:flick/features/playlist_links/playlist_link_models.dart';
import 'package:flick/features/playlist_links/playlist_link_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaylistLinkParser', () {
    test('accepts canonical Spotify URL and URI', () {
      const id = '0123456789abcdefghijkl';
      final url = PlaylistLinkParser.parse(
        'https://open.spotify.com/playlist/$id?si=x',
      );
      final uri = PlaylistLinkParser.parse('spotify:playlist:$id');

      expect(url.source, PlaylistLinkSource.spotify);
      expect(url.remoteId, id);
      expect(url.canonicalUrl, 'https://open.spotify.com/playlist/$id');
      expect(uri.linkId, 'spotify:$id');
    });

    test('accepts YouTube and YouTube Music playlist URLs', () {
      final link = PlaylistLinkParser.parse(
        'https://music.youtube.com/playlist?list=PL_abc-12345',
      );
      final watch = PlaylistLinkParser.parse(
        'https://www.youtube.com/watch?v=video123&list=PL_abc-12345',
      );

      expect(link.source, PlaylistLinkSource.youtube);
      expect(link.remoteId, 'PL_abc-12345');
      expect(watch.canonicalUrl, link.canonicalUrl);
    });

    test('rejects hostile hosts, malformed IDs, and playlist lookalikes', () {
      const hostile = [
        'https://evilspotify.com/playlist/0123456789abcdefghijkl',
        'https://open.spotify.com.evil.example/playlist/0123456789abcdefghijkl',
        'https://youtube.com.evil.example/playlist?list=PL_abc-12345',
        'https://youtu.be/video123?list=PL_abc-12345',
        'https://www.youtube.com/watch?list=../../etc/passwd',
        'https://open.spotify.com/album/0123456789abcdefghijkl',
        'spotify:playlist:not-a-spotify-id',
      ];

      for (final input in hostile) {
        expect(
          () => PlaylistLinkParser.parse(input),
          throwsA(isA<PlaylistLinkFormatException>()),
          reason: input,
        );
      }
    });
  });
}
