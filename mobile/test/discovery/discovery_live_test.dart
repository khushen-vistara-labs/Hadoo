import 'package:flick/features/discovery/discovery_http.dart';
import 'package:flick/features/discovery/discovery_sources.dart';
import 'package:flick/features/discovery/youtube_audio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test(
    'opt-in live guest YouTube Music catalog smoke',
    () async {
      final client = http.Client();
      addTearDown(client.close);
      final results = await YoutubeMusicCatalog(DiscoveryHttp(client))
          .search('Beethoven Moonlight Sonata');
      expect(results, isNotEmpty);
      expect(
        results.every((t) => t.sourceUrl?.host == 'music.youtube.com'),
        isTrue,
      );
    },
    skip: !const bool.fromEnvironment('DISCOVERY_LIVE_TEST'),
    timeout: const Timeout(Duration(seconds: 30)),
  );

  test(
    'opt-in live YouTube audio: found, resolved and its first part fetched',
    () async {
      final client = http.Client();
      addTearDown(client.close);
      final web = DiscoveryHttp(client);
      final results = await YoutubeMusicCatalog(web)
          .search('Daft Punk One More Time');
      final audio = await YoutubeAudio(web).resolve(results.first.id);
      expect(audio.length, greaterThan(100000));
      final bytes = <int>[];
      await web.transfer(
        audio.url.replace(
          queryParameters: {...audio.url.queryParameters, 'range': '0-65535'},
        ),
        headers: audio.headers,
        maxBytes: 65536,
        deadline: const Duration(seconds: 20),
        onChunk: bytes.addAll,
      );
      expect(bytes.length, 65536);
      expect(String.fromCharCodes(bytes.sublist(4, 8)), 'ftyp');
    },
    skip: !const bool.fromEnvironment('DISCOVERY_LIVE_TEST'),
    timeout: const Timeout(Duration(seconds: 60)),
  );
}
