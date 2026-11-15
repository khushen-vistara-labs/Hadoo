import 'package:flick/features/library_jobs/library_jobs.dart';
import 'package:flick/services/library_job_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('lokal/library_sync_notification');
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  testWidgets(
    'video search has its own progress kind and completion wins over pending progress',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return true;
          });
      final notification = LibraryJobNotification();
      notification.update(
        const LibraryJobStatus(
          job: LibraryJob.videos,
          running: true,
          total: 20,
        ),
      );
      await tester.pump();
      notification.update(
        const LibraryJobStatus(
          job: LibraryJob.videos,
          running: true,
          done: 4,
          total: 20,
        ),
      );
      notification.update(
        const LibraryJobStatus(job: LibraryJob.videos, done: 20, total: 20),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(calls.first.arguments['kind'], 'library_job');
      expect(calls.first.arguments['busy'], true);
      expect(calls.last.arguments['processed'], 20);
      expect(calls.last.arguments['busy'], false);
      expect(calls.length, 2);
      notification.dispose();
      debugDefaultTargetPlatformOverride = null;
    },
  );
}
