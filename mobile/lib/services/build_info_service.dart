import 'package:flutter/services.dart';

/// Read-only build identity of the running APK.
class BuildInfoService {
  static const _channel = MethodChannel('com.mossapps.flick/diagnostics');

  /// Gradle product flavor this build was compiled from: `full` (GitHub
  /// Releases / sideload) or `play` (Google Play). Null when unavailable.
  Future<String?> getBuildFlavor() async {
    try {
      final flavor = await _channel.invokeMethod<String>('getBuildFlavor');
      if (flavor == null || flavor.isEmpty) return null;
      return flavor;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
