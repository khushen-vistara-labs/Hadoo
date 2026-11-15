import 'dart:math';
import 'package:flutter/foundation.dart';

/// Short-lived in-memory progressive HTTP media descriptors. Only opaque
/// tokens enter the queue/history: signed source URLs and tokens are never
/// serialized into a Song or displayed in UI/logs.
class DiscoveryProgressiveStreams {
  DiscoveryProgressiveStreams._();
  static final instance = DiscoveryProgressiveStreams._();

  final _entries = <String, ({Uri url, DateTime created})>{};
  final _random = Random.secure();
  static const _lifetime = Duration(minutes: 40);

  String register(Uri url) {
    if (url.scheme != 'https' || url.userInfo.isNotEmpty || url.host.isEmpty) {
      throw ArgumentError('Invalid progressive media URL');
    }
    prune();
    final token = List.generate(16,
        (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    final handle = 'lokal-progressive://audio/$token';
    _entries[handle] = (url: url, created: DateTime.now());
    return handle;
  }

  Uri? resolve(String? handle) {
    if (handle == null) return null;
    final entry = _entries[handle];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.created) > _lifetime) {
      _entries.remove(handle);
      return null;
    }
    return entry.url;
  }

  bool contains(String? handle) => resolve(handle) != null;

  void prune() {
    final now = DateTime.now();
    _entries.removeWhere((_, value) =>
      now.difference(value.created) > _lifetime);
  }

  @visibleForTesting
  void clear() => _entries.clear();
}
