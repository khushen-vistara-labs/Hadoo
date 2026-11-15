import 'package:flick/models/song.dart';
import 'package:flick/services/discord_presence_service.dart';
import 'package:flick/services/player_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Player implements PlayerService {
  @override
  final currentSongNotifier = ValueNotifier<Song?>(null);
  @override
  final isPlayingNotifier = ValueNotifier(false);
  @override
  final isNetworkLoadingNotifier = ValueNotifier(false);
  @override
  final durationNotifier = ValueNotifier(Duration.zero);
  @override
  final positionNotifier = ValueNotifier(Duration.zero);
  @override
  final playbackSpeedNotifier = ValueNotifier(1.0);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Song song(String id) => Song(
  id: id,
  title: id,
  artist: 'Artist',
  album: 'Album',
  duration: const Duration(minutes: 3),
  fileType: 'FLAC',
  albumArt: '/local/cover.jpg',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'next, previous and resolved artwork update without restarting Discord during loading',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'lokal_discord_presence_enabled': true,
      });
      const channel = MethodChannel('test.lokal/discord');
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return call.method == 'available' || call.method == 'initialize'
                ? true
                : null;
          });
      final player = _Player();
      final service = DiscordPresenceService.create(
        channel: channel,
        android: true,
        artworkResolver: (song) async => 'https://i.scdn.co/image/${song.id}',
      );
      await service.start(player);
      player.currentSongNotifier.value = song('first');
      player.isPlayingNotifier.value = true;
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      List<Map> updates() => calls
          .where((c) => c.method == 'update')
          .map((c) => c.arguments as Map)
          .toList();
      expect(updates().last['title'], 'first');
      expect(updates().last['artwork'], 'https://i.scdn.co/image/first');
      expect(service.artworkStatus, contains('Cover URL sent to Discord'));
      player.isNetworkLoadingNotifier.value = true;
      await tester.pump();
      expect(calls.where((c) => c.method == 'shutdown'), isEmpty);
      player.currentSongNotifier.value = song('second');
      player.isNetworkLoadingNotifier.value = false;
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(updates().last['title'], 'second');
      expect(updates().last['artwork'], 'https://i.scdn.co/image/second');
      player.currentSongNotifier.value = song('first');
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(updates().last['title'], 'first');
      expect(calls.where((c) => c.method == 'initialize'), hasLength(1));
      await service.stop();
    },
  );
  test('presence never publishes private cover addresses or credentials', () {
    for (final url in [
      'http://192.168.1.2/art',
      '/local/cover',
      'https://i.scdn.co/image/a?token=private',
      'https://192.168.1.22/cover.jpg',
      'https://localhost/cover.jpg',
      'https://music.local/cover.jpg',
      'https://intranet.lan/art.jpg',
      'https://cdn.example.com/cover.jpg?token=private',
    ]) {
      expect(DiscordPresenceService.publicArtwork(url), isEmpty);
    }
    expect(
      DiscordPresenceService.publicArtwork(
        'https://e-cdns-images.dzcdn.net/images/cover/id/500x500.jpg',
      ),
      isNotEmpty,
    );
    // External album artwork isn't restricted to a fixed provider allowlist.
    // Tidal, alternative Apple storefronts and independent CDNs are valid.
    for (final url in [
      'https://resources.tidal.com/images/a/b/c/1280x1280.jpg',
      'https://example.com/album-cover.jpg',
      'https://is21-ssl.mzstatic.com/image/thumb/album/600x600bb.jpg',
      'https://lh3.googleusercontent.com/some-safe-public-art',
    ]) {
      expect(DiscordPresenceService.publicArtwork(url), url);
    }

    // The Last.fm resolver may return a different regional Apple CDN;
    // Discord must not silently discard the identical valid cover.
    expect(
      DiscordPresenceService.publicArtwork(
        'https://is7-ssl.mzstatic.com/image/thumb/Music/cover/600x600bb.jpg',
      ),
      isNotEmpty,
    );
    expect(
      DiscordPresenceService.publicArtwork(
        'https://is10-ssl.mzstatic.com/image/thumb/Music/cover/600x600bb.jpg',
      ),
      isNotEmpty,
    );
    expect(
      DiscordPresenceService.publicArtwork(
        'https://is7-ssl.mzstatic.com.evil.example/cover.jpg',
      ),
      isEmpty,
    );
    expect(
      DiscordPresenceService.publicArtwork(
        'https://is7-ssl.mzstatic.com/image/' + ''.padRight(310, 'x'),
      ),
      isEmpty,
    );
  });

  test('repeated Discord artwork failures use bounded backoff', () {
    expect(DiscordPresenceService.coverRetryDelayForFailure(1),
        const Duration(seconds: 45));
    expect(DiscordPresenceService.coverRetryDelayForFailure(2),
        const Duration(minutes: 2));
    expect(DiscordPresenceService.coverRetryDelayForFailure(3),
        const Duration(minutes: 5));
    expect(DiscordPresenceService.coverRetryDelayForFailure(4),
        const Duration(minutes: 15));
    expect(DiscordPresenceService.coverRetryDelayForFailure(50),
        const Duration(minutes: 15));
  });

}
