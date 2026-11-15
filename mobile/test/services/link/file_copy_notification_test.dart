import 'package:flick/models/lokal_remote_state.dart';
import 'package:flick/services/link/file_copy_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('lokal/file_copy');
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  test(
    'starts before progress, serializes progress then ends on completion',
    () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return null;
          });
      final notification = FileCopyNotification();
      await notification.begin('Expertbook');
      notification.update(
        const LinkCopyProgress(
          phase: LinkCopyPhase.copying,
          total: 2,
          processed: 1,
          sent: 1,
        ),
      );
      await notification.finish(
        const LinkCopyProgress(
          phase: LinkCopyPhase.complete,
          total: 2,
          processed: 2,
          sent: 2,
        ),
      );
      expect(calls.map((c) => c.method), ['start', 'update', 'stop']);
      expect((calls.last.arguments as Map)['title'], 'Music copy complete');
      notification.update(const LinkCopyProgress(phase: LinkCopyPhase.copying));
      expect(calls.length, 3);
    },
  );
  test('startup failures propagate before work starts', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (_) async =>
              throw PlatformException(code: 'COPY_BACKGROUND_UNAVAILABLE'),
        );
    await expectLater(
      FileCopyNotification().begin('PC'),
      throwsA(isA<PlatformException>()),
    );
  });
}
