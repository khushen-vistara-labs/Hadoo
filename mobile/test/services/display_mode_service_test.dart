import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flick/services/display_mode_service.dart';

/// One resolution, two refresh rates — a typical 60/120 Hz phone panel.
const int _width = 1080;
const int _height = 2400;

const Map<String, Object> _mode60 = {
  'id': 1,
  'width': _width,
  'height': _height,
  'refreshRate': 60.0,
};

const Map<String, Object> _mode120 = {
  'id': 2,
  'width': _width,
  'height': _height,
  'refreshRate': 120.0,
};

const Map<String, Object> _autoMode = {
  'id': 0,
  'width': 0,
  'height': 0,
  'refreshRate': 0.0,
};

/// Fake of the `flutter_display_mode` platform channel.
///
/// With [rejectForcedModes] a non-zero mode request is acknowledged but the
/// active mode never changes, mirroring firmware that ignores the request
/// (reported on the Fairphone 6, see moss-apps/Flick#210).
class _FakeDisplay {
  final List<int> setPreferredCalls = [];
  bool rejectForcedModes = false;

  int _activeId = 1;
  int _preferredId = 0;

  Map<String, Object> get _active => _activeId == 2 ? _mode120 : _mode60;

  Map<String, Object> get _preferred {
    switch (_preferredId) {
      case 1:
        return _mode60;
      case 2:
        return _mode120;
      default:
        return _autoMode;
    }
  }

  Future<Object?> handle(MethodCall call) async {
    switch (call.method) {
      case 'getSupportedModes':
        return const [_mode60, _mode120];
      case 'getActiveMode':
        return _active;
      case 'getPreferredMode':
        return _preferred;
      case 'setPreferredMode':
        final id = (call.arguments as Map)['mode'] as int;
        setPreferredCalls.add(id);
        _preferredId = id;
        if (id == 0) {
          _activeId = 1;
        } else if (!rejectForcedModes) {
          _activeId = id;
        }
        return null;
      default:
        return null;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter_display_mode');
  late _FakeDisplay fake;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    fake = _FakeDisplay();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, fake.handle);
    final service = DisplayModeService();
    service.debugReset();
    service.verificationDelay = Duration.zero;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    DisplayModeService().debugReset();
  });

  test('high requests the highest refresh rate at the current resolution', () async {
    final service = DisplayModeService();
    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'preference',
    );
    expect(fake.setPreferredCalls, [2]);

    await pumpEventQueue();
    expect(
      fake.setPreferredCalls,
      [2],
      reason: 'an accepted mode is not requested again',
    );

    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'mount',
    );
    expect(fake.setPreferredCalls, [2], reason: 'a repeat mount is skipped');
  });

  test('standard requests the lowest refresh rate at the current resolution', () async {
    final service = DisplayModeService();
    await service.applyRefreshRateMode(
      DisplayModeService.standard,
      reason: 'preference',
    );
    expect(fake.setPreferredCalls, [1]);
  });

  test('adaptive clears the forced mode instead of requesting one', () async {
    final service = DisplayModeService();
    await service.applyRefreshRateMode(
      DisplayModeService.adaptive,
      reason: 'preference',
    );
    expect(fake.setPreferredCalls, [0]);

    await service.applyRefreshRateMode(
      DisplayModeService.adaptive,
      reason: 'mount',
    );
    expect(fake.setPreferredCalls, [0], reason: 'already auto is skipped');
  });

  test('a rejected forced mode falls back to auto and stays suppressed', () async {
    fake.rejectForcedModes = true;
    final service = DisplayModeService();
    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'preference',
    );
    expect(fake.setPreferredCalls, [2]);

    await pumpEventQueue();
    expect(
      fake.setPreferredCalls,
      [2, 0],
      reason: 'the rejected request is followed by a reset to auto',
    );

    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'mount',
    );
    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'resume',
    );
    await pumpEventQueue();
    expect(
      fake.setPreferredCalls,
      [2, 0],
      reason: 'automatic applies stop forcing after a rejection',
    );
  });

  test('an explicit preference change still attempts forcing when suppressed', () async {
    fake.rejectForcedModes = true;
    final service = DisplayModeService();
    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'preference',
    );
    await pumpEventQueue();
    expect(fake.setPreferredCalls, [2, 0]);

    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'preference',
    );
    expect(fake.setPreferredCalls, [2, 0, 2]);
    await pumpEventQueue();
  });

  test('an unknown mode falls back to the high behaviour', () async {
    final service = DisplayModeService();
    await service.applyRefreshRateMode('bogus', reason: 'preference');
    expect(fake.setPreferredCalls, [2]);
    await pumpEventQueue();
  });

  test('does nothing on non-Android platforms', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final service = DisplayModeService();
    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'preference',
    );
    expect(fake.setPreferredCalls, isEmpty);
  });
}
