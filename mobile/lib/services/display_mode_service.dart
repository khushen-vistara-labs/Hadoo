import 'package:flutter/foundation.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flick/core/utils/dev_log.dart';

/// Applies the user's refresh-rate preference to the current window.
///
/// The preference values mirror the `refreshRateMode` app preference:
///  * `adaptive` — leave the mode to the system (no preferred mode set);
///  * `standard` — request the lowest refresh rate at the current resolution;
///  * `high` — request the highest refresh rate at the current resolution.
///
/// Forced modes are verified shortly after they are requested. Some firmware
/// acknowledges the request and then drops the panel into a low-power state
/// (reported on the Fairphone 6, see moss-apps/Flick#210); when the active
/// mode does not match the request the service falls back to `auto` and stops
/// forcing for the rest of the session, so later screen mounts and resumes do
/// not keep poking the display driver.
class DisplayModeService {
  /// Preference value: follow the system refresh rate.
  static const String adaptive = 'adaptive';

  /// Preference value: prefer 60 Hz at the current resolution.
  static const String standard = 'standard';

  /// Preference value: prefer the highest refresh rate at the current
  /// resolution.
  static const String high = 'high';

  static final DisplayModeService _instance = DisplayModeService._internal();
  factory DisplayModeService() => _instance;
  DisplayModeService._internal();

  List<DisplayMode> _availableModes = [];
  DisplayMode? _currentMode;
  DisplayMode? _preferredMode;

  List<DisplayMode> get availableModes => _availableModes;
  DisplayMode? get currentMode => _currentMode;
  DisplayMode? get preferredMode => _preferredMode;

  bool get isSupported => defaultTargetPlatform == TargetPlatform.android;

  /// How long to wait before checking that a forced mode was accepted.
  @visibleForTesting
  Duration verificationDelay = const Duration(milliseconds: 1500);

  /// Last mode id handed to the platform; lets mounts and resumes skip
  /// redundant requests.
  int? _lastRequestedModeId;

  /// True once a forced mode was rejected. Automatic applies then leave the
  /// system alone until the app restarts or the user picks a mode explicitly.
  bool _forceSuppressed = false;

  /// Invalidates a pending verification when a newer request takes over.
  int _verificationToken = 0;

  static String _describe(DisplayMode? mode) {
    if (mode == null) return 'unknown';
    if (mode.id == 0) return 'auto';
    return '#${mode.id} ${mode.width}x${mode.height}@${mode.refreshRate}Hz';
  }

  Future<void> _logState(String tag) async {
    try {
      _currentMode = await FlutterDisplayMode.active;
      _preferredMode = await FlutterDisplayMode.preferred;
    } catch (e) {
      devLog('DisplayMode[$tag]: failed to read state: $e');
      return;
    }
    devLog(
      'DisplayMode[$tag]: active=${_describe(_currentMode)} '
      'preferred=${_describe(_preferredMode)}',
    );
  }

  Future<void> initialize() async {
    if (!isSupported) return;
    try {
      _availableModes = await FlutterDisplayMode.supported;
      _currentMode = await FlutterDisplayMode.active;
      _preferredMode = await FlutterDisplayMode.preferred;
      devLog(
        'DisplayMode[init]: supported='
        '${_availableModes.map(_describe).join(', ')}',
      );
      devLog(
        'DisplayMode[init]: active=${_describe(_currentMode)} '
        'preferred=${_describe(_preferredMode)}',
      );
    } catch (e) {
      devLog('Failed to initialize display modes: $e');
    }
  }

  /// Applies the refresh-rate [mode] preference.
  ///
  /// [reason] is used for logging and to distinguish automatic applies
  /// ('mount', 'resume') from an explicit user selection ('preference').
  Future<void> applyRefreshRateMode(
    String mode, {
    String reason = 'apply',
  }) async {
    if (!isSupported) return;

    final requested = await _resolveTargetMode(mode);
    if (requested == null) return;

    final isForced = requested.id != DisplayMode.auto.id;
    if (isForced && _forceSuppressed && reason != 'preference') {
      devLog(
        'DisplayMode[apply]: forced modes suppressed for this session, '
        'skipping $mode ($reason)',
      );
      return;
    }

    if (_lastRequestedModeId == requested.id) {
      devLog(
        'DisplayMode[apply]: ${_describe(requested)} already requested, '
        'skipping ($reason)',
      );
      return;
    }

    _verificationToken++;
    try {
      await FlutterDisplayMode.setPreferredMode(requested);
    } catch (e) {
      devLog('DisplayMode[apply]: failed to set ${_describe(requested)}: $e');
      return;
    }
    _lastRequestedModeId = requested.id;
    await _logState('apply $mode ($reason)');
    if (isForced) {
      _scheduleVerification(requested);
    }
  }

  /// Clears any forced display mode so the system decides again.
  Future<void> resetToAuto({String reason = 'resetAuto'}) async {
    if (!isSupported) return;
    _verificationToken++;
    if (_lastRequestedModeId == DisplayMode.auto.id) {
      devLog('DisplayMode[resetAuto]: already auto ($reason)');
      return;
    }
    try {
      await FlutterDisplayMode.setPreferredMode(DisplayMode.auto);
      _lastRequestedModeId = DisplayMode.auto.id;
      await _logState('resetAuto ($reason)');
    } catch (e) {
      devLog('Failed to reset display mode: $e');
    }
  }

  /// Picks the platform mode matching [mode] at the current resolution,
  /// mirroring the plugin's high/low refresh-rate helpers.
  Future<DisplayMode?> _resolveTargetMode(String mode) async {
    if (mode == adaptive) return DisplayMode.auto;

    var effectiveMode = mode;
    if (effectiveMode != standard && effectiveMode != high) {
      devLog(
        'DisplayMode[apply]: unknown refreshRateMode "$mode", '
        'falling back to $high',
      );
      effectiveMode = high;
    }

    try {
      final modes = await FlutterDisplayMode.supported;
      final active = await FlutterDisplayMode.active;
      var target = active;
      for (final candidate in modes) {
        if (candidate.width != active.width ||
            candidate.height != active.height) {
          continue;
        }
        final better = effectiveMode == standard
            ? candidate.refreshRate < target.refreshRate
            : candidate.refreshRate > target.refreshRate;
        if (better) {
          target = candidate;
        }
      }
      return target;
    } catch (e) {
      devLog('DisplayMode[apply]: failed to resolve the $mode mode: $e');
      return null;
    }
  }

  void _scheduleVerification(DisplayMode requested) {
    final token = ++_verificationToken;
    Future<void>.delayed(verificationDelay, () async {
      if (token != _verificationToken || !isSupported) return;
      final DisplayMode active;
      try {
        active = await FlutterDisplayMode.active;
      } catch (e) {
        devLog('DisplayMode[verify]: failed to read the active mode: $e');
        return;
      }
      if (token != _verificationToken) return;
      _currentMode = active;
      if (active.id == requested.id) {
        devLog('DisplayMode[verify]: ${_describe(requested)} is active');
        return;
      }
      devLog(
        'DisplayMode[verify]: requested ${_describe(requested)} but '
        '${_describe(active)} is active; reverting to auto and suppressing '
        'forced modes for this session',
      );
      _forceSuppressed = true;
      await resetToAuto(reason: 'verifyFallback');
    });
  }

  /// Clears session state; call between tests.
  @visibleForTesting
  void debugReset() {
    _availableModes = [];
    _currentMode = null;
    _preferredMode = null;
    _lastRequestedModeId = null;
    _forceSuppressed = false;
    _verificationToken = 0;
    verificationDelay = const Duration(milliseconds: 1500);
  }

  DisplayMode? get highestRefreshRateMode {
    if (_availableModes.isEmpty) return null;
    return _availableModes.reduce(
      (a, b) => a.refreshRate > b.refreshRate ? a : b,
    );
  }

  DisplayMode? get highestResolutionMode {
    if (_availableModes.isEmpty) return null;
    return _availableModes.reduce((a, b) {
      final aPixels = (a.width * a.height);
      final bPixels = (b.width * b.height);
      return aPixels > bPixels ? a : b;
    });
  }

  DisplayMode? get optimalMode {
    if (_availableModes.isEmpty) return null;
    return _availableModes.reduce((a, b) {
      final aScore = a.refreshRate * (a.width * a.height);
      final bScore = b.refreshRate * (b.width * b.height);
      return aScore > bScore ? a : b;
    });
  }
}
