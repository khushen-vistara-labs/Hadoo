import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:flick/features/settings/library_scan/library_scan_flow.dart';
import 'package:flick/services/library_scanner_service.dart' show ScanProgress;
import 'package:flick/services/scan_session_controller.dart';

ScanProgress _progress(
  int processed,
  int total, {
  int newSongs = 0,
  bool complete = false,
  bool unavailable = false,
}) => ScanProgress(
  songsFound: processed,
  totalFiles: total,
  filesProcessed: processed,
  newSongs: newSongs,
  isComplete: complete,
  unavailable: unavailable,
);

void main() {
  final controller = ScanSessionController.instance;

  setUp(() {
    controller.end();
    controller.dismiss();
  });

  tearDown(() {
    controller.end();
    controller.dismiss();
  });

  int begin() => controller.begin(
    title: 'Music',
    kind: ScanSessionKind.scan,
    onCancel: () {},
  );

  Future<ScanSessionStatus> drive(
    int generation,
    Stream<ScanProgress> stream, {
    Future<int> Function()? countSongs,
  }) => driveScanSession(
    controller: controller,
    generation: generation,
    stream: stream,
    title: 'Music',
    kind: ScanSessionKind.scan,
    countSongs: countSongs,
  );

  test('the completion event finishes the scan with what it added', () async {
    final generation = begin();
    final status = await drive(
      generation,
      Stream.fromIterable([
        _progress(0, 10),
        _progress(10, 10, newSongs: 7),
        _progress(10, 10, newSongs: 7, complete: true),
      ]),
      countSongs: () async => 42,
    );

    expect(status, ScanSessionStatus.complete);
    expect(controller.status.value, ScanSessionStatus.complete);
    expect(controller.result.value?.newSongs, 7);
    expect(controller.result.value?.totalSongs, 42);
    expect(controller.isActive, isFalse);
    expect(scanResultHeadline(controller.result.value!), '7 songs added');
  });

  test('post-scan work after the completion event is never awaited', () async {
    // A scanner that keeps its stream open after completing (background
    // covers, preload) must not keep the scan "running".
    final source = StreamController<ScanProgress>();
    final generation = begin();
    final done = drive(generation, source.stream);

    source.add(_progress(5, 5, newSongs: 5, complete: true));
    final status = await done.timeout(const Duration(seconds: 1));

    expect(status, ScanSessionStatus.complete);
    expect(controller.status.value, ScanSessionStatus.complete);
    await source.close();
  });

  test(
    'a stream that ends without a completion event still completes',
    () async {
      final generation = begin();
      final status = await drive(
        generation,
        Stream.fromIterable([_progress(2, 4)]),
      );

      expect(status, ScanSessionStatus.complete);
      expect(controller.status.value, ScanSessionStatus.complete);
    },
  );

  test('unplugged storage ends as unavailable', () async {
    final generation = begin();
    final status = await drive(
      generation,
      Stream.value(_progress(0, 0, complete: true, unavailable: true)),
    );

    expect(status, ScanSessionStatus.unavailable);
    expect(controller.status.value, ScanSessionStatus.unavailable);
    expect(controller.result.value, isNull);
  });

  test('an error ends as failed', () async {
    final generation = begin();
    final status = await drive(
      generation,
      Stream<ScanProgress>.error(StateError('disk gone')),
    );

    expect(status, ScanSessionStatus.failed);
    expect(controller.status.value, ScanSessionStatus.failed);
    expect(controller.isActive, isFalse);
  });

  test('Stop mid-scan stays cancelled and records no result', () async {
    final source = StreamController<ScanProgress>();
    final generation = begin();
    final done = drive(generation, source.stream);

    source.add(_progress(1, 10));
    await Future<void>.delayed(Duration.zero);
    controller.stop();
    source.add(_progress(10, 10, complete: true));

    expect(await done, ScanSessionStatus.cancelled);
    expect(controller.status.value, ScanSessionStatus.cancelled);
    expect(controller.result.value, isNull);
    await source.close();
  });

  test('progress is mirrored into the controller while running', () async {
    final source = StreamController<ScanProgress>();
    final generation = begin();
    final done = drive(generation, source.stream);

    source.add(_progress(3, 9));
    await Future<void>.delayed(Duration.zero);
    expect(controller.progress.value?.filesProcessed, 3);
    expect(controller.status.value, ScanSessionStatus.running);

    source.add(_progress(9, 9, complete: true));
    await done;
    await source.close();
  });
}
