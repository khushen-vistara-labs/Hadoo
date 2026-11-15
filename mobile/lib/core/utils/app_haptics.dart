import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Centralized haptic patterns used across Flick interactions.
class AppHaptics {
  AppHaptics._();

  static bool _enabled = true;
  static const MethodChannel _patternChannel = MethodChannel('lokal/haptics');

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Wraps a callback so it fires [tap] haptic before executing.
  static VoidCallback wrap(VoidCallback callback) {
    return () {
      tap();
      callback();
    };
  }

  /// Wraps an async callback so it fires [tap] haptic before executing.
  static Future<void> Function() wrapAsync(Future<void> Function() callback) {
    return () async {
      tap();
      await callback();
    };
  }

  static void tap() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  static void selection() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  static void confirm() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  static void emphasis() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }
  /// Rapid two-pulse confirmation for play/pause, navigation and seek release.
  static void doublePulse() => _pulsePattern(2);

  /// Rapid three-pulse confirmation for skip gestures and track controls.
  static void triplePulse() => _pulsePattern(3);

  static void _pulsePattern(int count) {
    if (!_enabled) return;
    unawaited(_playPattern(count));
  }

  static Future<void> _playPattern(int count) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _patternChannel.invokeMethod<void>('pulsePattern', {'pulses': count});
        return;
      } on MissingPluginException {
        // Supports older installs and Flutter widget tests.
      } on PlatformException {
        // A device may not expose the vibrator service.
      }
    }
    for (var i = 0; i < count; i++) {
      if (!_enabled) break;
      await HapticFeedback.lightImpact();
      if (i + 1 < count) {
        await Future<void>.delayed(const Duration(milliseconds: 48));
      }
    }
  }
}
