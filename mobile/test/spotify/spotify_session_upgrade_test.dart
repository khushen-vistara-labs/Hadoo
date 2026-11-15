import 'dart:convert';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flick/features/spotify/spotify_oauth.dart';

import 'package:flick/features/spotify/spotify_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('native session failures explain the failed step without blaming every cookie', () async {
    const channel = MethodChannel('test/spotify-session-error');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (_) async => throw PlatformException(
            code: 'SPOTIFY_SESSION_ERROR',
            message: 'Web player could not load.',
          ),
        );
    await expectLater(
      const MethodChannelSpotifyOAuthBrowser(channel: channel)
          .mintTokens('cookie'),
      throwsA(
        isA<SpotifyOAuthException>().having(
          (e) => e.message,
          'reason',
          'Web player could not load.',
        ),
      ),
    );
  });
  test(
    'Canvas and Discovery share one real browser refresh for the same cookie',
    () async {
      const channel = MethodChannel('test/spotify-shared-mint');
      var calls = 0;
      final ready = Completer<Map<String, Object>>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls++;
            return ready.future;
          });
      const a = MethodChannelSpotifyOAuthBrowser(channel: channel),
          b = MethodChannelSpotifyOAuthBrowser(channel: channel);
      final first = a.mintTokens('saved-cookie'),
          second = b.mintTokens('saved-cookie');
      await Future<void>.delayed(Duration.zero);
      expect(calls, 1);
      ready.complete({
        'accessToken': 'browser-access',
        'clientToken': 'browser-client',
        'expiresAtMs': DateTime.now()
            .add(const Duration(hours: 1))
            .millisecondsSinceEpoch,
        'queryHashes': {'home': 'a' * 64},
      });
      final sessions = await Future.wait([first, second]);
      expect(sessions.every((s) => s?.clientToken == 'browser-client'), isTrue);
      expect(sessions.first?.queryHashes['home'], 'a' * 64);
    },
  );
  test(
    'legacy fabricated-client session remints without losing the saved cookie',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'konnekted.spotify.tokens.v1': jsonEncode({
          'version': 1,
          'accessToken': 'old-access',
          'clientToken': 'old-client',
          'sessionCookie': 'saved-cookie',
          'expiresAt': DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),
        }),
      });
      final store = SecureSpotifyTokenStore();
      final legacy = await store.readTokens();
      expect(legacy!.sessionCookie, 'saved-cookie');
      expect(legacy.isExpired, isTrue);
      expect(legacy.clientToken, isNull);
      await store.writeTokens(
        legacy.copyWith(
          accessToken: 'browser-access',
          clientToken: 'browser-client',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          queryHashes: {'home': 'a' * 64},
        ),
      );
      final fresh = await store.readTokens();
      expect(fresh!.isExpired, isFalse);
      expect(fresh.clientToken, 'browser-client');
      expect(fresh.queryHashes['home'], 'a' * 64);
    },
  );
}
