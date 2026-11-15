import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flick/core/theme/lokal_appearance.dart';
import 'package:flick/core/theme/lokal_tokens.dart';

/// Keeps the launcher icon's sticker in the accent colour, like desktop's
/// Dock and taskbar icon.
///
/// Android uses prebuilt assets for every preset and distinct theme color.
/// Native code stages the requested alias and applies it only after the
/// activity is backgrounded and playback is idle.
abstract final class LokalLauncherIcon {
  static const _channel = MethodChannel('lokal/launcher_icon');
  static String? _last;
  static String? _wanted;
  static Future<void> _tail = Future<void>.value();

  /// Theme colors have exact assets, including colors outside accent presets.
  static String iconNameFor(LokalAppearance appearance) {
    if (appearance.accent != null) return appearance.accent!.name.toLowerCase();
    return switch (appearance.theme) {
      LokalThemeId.dark || LokalThemeId.oled => 'chartreuse',
      LokalThemeId.light => 'purple',
      LokalThemeId.midnight => 'midnight',
      LokalThemeId.warm => 'orange',
      LokalThemeId.ocean => 'blue',
      LokalThemeId.forest => 'teal',
      LokalThemeId.cyberpunk => 'neon',
      LokalThemeId.rosegold => 'rosegold',
      LokalThemeId.deepContrast => 'white',
    };
  }

  static Future<void> sync(LokalAppearance appearance) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android)
      return Future.value();
    final name = iconNameFor(appearance);
    _wanted = name;
    final next = _tail.then((_) => _apply(name));
    _tail = next;
    return next;
  }

  static Future<void> setBusy(bool busy) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('setBusy', {'busy': busy});
    } on PlatformException {
      /* Native guard still checks Android music activity. */
    } on MissingPluginException {
      /* Unsupported host. */
    }
  }

  static Future<void> _apply(String name) async {
    if (name != _wanted || name == _last) return;
    try {
      await _channel.invokeMethod<void>('setAccent', {'accent': name});
      _last = name;
    } on PlatformException catch (e) {
      debugPrint('[LauncherIcon] not updated: ${e.message}');
    } on MissingPluginException {
      // Tests and other hosts without the native side.
    }
  }
}
