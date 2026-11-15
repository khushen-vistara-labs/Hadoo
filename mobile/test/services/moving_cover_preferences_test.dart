import 'dart:convert';

import 'package:flick/models/song.dart';
import 'package:flick/services/motion_art/moving_cover_matcher.dart';
import 'package:flick/services/motion_art/moving_cover_settings.dart';
import 'package:flick/services/motion_art/spotify_canvas_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'per-song Canvas disable and Spotify priority survive a fresh provider',
    () async {
      SharedPreferences.setMockInitialValues({});
      final song = Song(
        id: 'phone',
        title: '駅',
        artist: '竹内まりや',
        duration: Duration.zero,
        fileType: 'FLAC',
      );
      final key = movingCoverSongKey(song);
      final first = ProviderContainer();
      first.read(movingCoverSettingsProvider);
      await Future<void>.delayed(Duration.zero);
      await first
          .read(movingCoverSettingsProvider.notifier)
          .setSongEnabled(key, false);
      await first
          .read(movingCoverSettingsProvider.notifier)
          .prioritizeSpotify(true);
      first.dispose();
      final reloaded = await MovingCoverSettings.load();
      expect(reloaded.disabledSongs, contains(key));
      expect(reloaded.order.first, 'spotify');
      final second = ProviderContainer();
      second.read(movingCoverSettingsProvider);
      await Future<void>.delayed(Duration.zero);
      await second
          .read(movingCoverSettingsProvider.notifier)
          .setSongEnabled(key, true);
      expect(
        (await MovingCoverSettings.load()).disabledSongs,
        isNot(contains(key)),
      );
      second.dispose();
    },
  );
  test(
    'Canvas parser selects requested track and rejects malformed payloads',
    () {
      List<int> field(int n, String s) {
        final b = utf8.encode(s);
        return [n * 8 + 2, b.length, ...b];
      }

      List<int> row(String uri, String url) {
        final b = [...field(2, url), ...field(5, uri)];
        return [10, b.length, ...b];
      }

      final bytes = [
        ...row('other', 'https://video.scdn.co/other.mp4'),
        ...row('wanted', 'https://video.scdn.co/wanted.mp4'),
      ];
      expect(
        SpotifyCanvasService.parseCanvasResponse(bytes, 'wanted'),
        'https://video.scdn.co/wanted.mp4',
      );
      expect(
        SpotifyCanvasService.parseCanvasResponse([10, 127, 2], 'wanted'),
        isNull,
      );
      expect(SpotifyCanvasService.validCanvasUrl('file:///local.mp4'), isNull);
      expect(
        SpotifyCanvasService.validCanvasUrl('https://x.example/image.jpg'),
        isNull,
      );
    },
  );
  test('matching keeps Japanese metadata and removes upload noise', () {
    expect(motionName('竹内まりや'), '竹内まりや');
    expect(motionTitle('駅 (Official Music Video)'), '駅');
    expect(motionArtistsMatch('A feat. B', ['A', 'B']), isTrue);
    expect(motionArtistsMatch('A feat. B', ['A', 'C']), isFalse);
    expect(motionAlbum('Unknown Album'), isEmpty);
  });
}
