import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flick/models/mini_player_config.dart';

class MiniPlayerConfigNotifier extends Notifier<MiniPlayerConfig> {
  static const preferencesKey = 'mini_player_config';
  late Future<void> _ready;
  Future<void> _writes = Future.value();
  bool _loaded = false;
  final _pending = <MiniPlayerConfig Function(MiniPlayerConfig)>[];

  @override
  MiniPlayerConfig build() {
    _ready = Future<void>.microtask(_load);
    return MiniPlayerConfig.defaultConfig;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    var config = MiniPlayerConfig.defaultConfig;
    final raw = prefs.get(preferencesKey);
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          config = MiniPlayerConfig.fromJson(decoded);
        }
      } on FormatException {
        // Keep defaults when an old or damaged value cannot be read.
      }
    }
    if (!ref.mounted) return;
    for (final change in _pending) {
      config = change(config);
    }
    _pending.clear();
    _loaded = true;
    state = config;
  }

  Future<void> update(
    MiniPlayerConfig Function(MiniPlayerConfig) change,
  ) async {
    if (!_loaded) _pending.add(change);
    state = change(state);
    await _ready;
    if (!ref.mounted) return;
    final snapshot = jsonEncode(state.toJson());
    final write = _writes.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(preferencesKey, snapshot);
    });
    _writes = write.catchError((Object _) {});
    await write;
  }

  Future<void> reset() => update((_) => MiniPlayerConfig.defaultConfig);
}

final miniPlayerConfigProvider =
    NotifierProvider<MiniPlayerConfigNotifier, MiniPlayerConfig>(
      MiniPlayerConfigNotifier.new,
    );
