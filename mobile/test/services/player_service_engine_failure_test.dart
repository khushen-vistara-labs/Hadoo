import 'package:flutter_test/flutter_test.dart';
import 'package:flick/services/player_service.dart';

void main() {
  group('isDeadRustEngineError', () {
    test('matches direct backend output loss', () {
      expect(
        isDeadRustEngineError(
          'Audio engine output lost: DSD ALSA write failed (EPIPE)',
        ),
        isTrue,
      );
    });

    test('matches managed Oboe callback failure with silenced output', () {
      expect(
        isDeadRustEngineError(
          'Audio engine output lost: Android managed output callback failure: '
          'output burst of 4096 frames exceeds scratch capacity of 16384 '
          'frames (output silenced)',
        ),
        isTrue,
      );
    });

    test('matches the legacy crash markers', () {
      expect(isDeadRustEngineError('Rust audio engine thread crashed'), isTrue);
      expect(isDeadRustEngineError('disconnected channel'), isTrue);
    });

    test('ignores unrelated playback errors', () {
      expect(isDeadRustEngineError('USB DAC disconnected'), isFalse);
      expect(isDeadRustEngineError('unsupported audio format'), isFalse);
    });
  });

  group('proxySafeHeaders', () {
    test('drops an empty map so local URIs skip the just_audio proxy', () {
      expect(proxySafeHeaders(const <String, String>{}), isNull);
    });

    test('passes non-empty headers through for network sources', () {
      const headers = <String, String>{'Authorization': 'Bearer token'};
      expect(proxySafeHeaders(headers), same(headers));
    });
  });

  group('shouldForceRustEngineFallback', () {
    final now = DateTime(2026, 9, 30, 12, 0, 0);

    test('does not force fallback for the first failure', () {
      expect(
        shouldForceRustEngineFallback(
          recoveryTimestamps: <DateTime>[now],
          now: now,
        ),
        isFalse,
      );
    });

    test('forces fallback for a second failure inside the window', () {
      expect(
        shouldForceRustEngineFallback(
          recoveryTimestamps: <DateTime>[
            now.subtract(const Duration(seconds: 30)),
            now,
          ],
          now: now,
        ),
        isTrue,
      );
    });

    test('ignores failures older than the window', () {
      expect(
        shouldForceRustEngineFallback(
          recoveryTimestamps: <DateTime>[
            now.subtract(
              deadRustEngineRecoveryWindow + const Duration(seconds: 1),
            ),
            now,
          ],
          now: now,
        ),
        isFalse,
      );
    });
  });
}
