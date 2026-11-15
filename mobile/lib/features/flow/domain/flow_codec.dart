import 'dart:convert';

import 'flow_models.dart';

/// A single versioned document keeps settings, bans and session consistent.
/// Unknown versions are refused rather than silently overwritten on downgrade.
class FlowCodec {
  static const version = 1;
  static const maxDocumentLength = 2 * 1024 * 1024;

  static String encode(FlowData data) => jsonEncode({
    'version': version,
    'config': {
      'mood': data.config.mood.name,
      'discovery': data.config.discovery,
      'memory': data.config.memory,
      'excludedGenres': data.config.excludedGenres.toList()..sort(),
    },
    'bannedIds': data.bannedIds.toList()..sort(),
    'skipCounts': data.skipCounts,
    'recentIds': data.recentIds,
    'session': {
      'trackIds': data.session.trackIds,
      'seed': data.session.seed,
      'builtAtMs': data.session.builtAtMs,
      'currentId': data.session.currentId,
    },
  });

  static FlowData decode(String? text) {
    if (text == null || text.trim().isEmpty) return FlowData();
    if (text.length > maxDocumentLength) return _recovered();
    Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      return _recovered();
    }
    if (decoded is! Map<String, dynamic>) return _recovered();
    final rawVersion = decoded['version'];
    if (rawVersion is num && rawVersion != version) {
      throw const FormatException(
        'This Flow data uses an unsupported version.',
      );
    }
    if (rawVersion != version) return _recovered();
    final config = _map(decoded['config']);
    final session = _map(decoded['session']);
    final ids = _strings(session['trackIds'], FlowRules.maxSessionTracks);
    final current = session['currentId'];
    final skips = <String, int>{};
    for (final entry in _map(
      decoded['skipCounts'],
    ).entries.take(FlowRules.maxSignals)) {
      if (_validId(entry.key) && entry.value is int && entry.value > 0) {
        skips[entry.key] = (entry.value as int).clamp(1, 1000);
      }
    }
    final mood = FlowMood.values
        .where((m) => m.name == config['mood'])
        .firstOrNull;
    return FlowData(
      config: FlowConfig(
        mood: mood ?? FlowMood.flow,
        discovery: _number(config['discovery'], .35),
        memory: _number(config['memory'], .5),
        excludedGenres: _strings(config['excludedGenres'], 200),
      ),
      bannedIds: _strings(decoded['bannedIds'], FlowRules.maxBans),
      skipCounts: skips,
      recentIds: _strings(decoded['recentIds'], FlowRules.maxSignals),
      session: FlowSession(
        trackIds: ids,
        seed: _integer(session['seed'], 1, 0x7fffffff),
        builtAtMs: _integer(session['builtAtMs'], 0, 8640000000000000),
        currentId: current is String && ids.contains(current) ? current : null,
      ),
    );
  }

  static FlowData _recovered() => FlowData(
    notice:
        'Saved Flow data could not be read. Default settings were restored.',
  );
  static Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : const {};
  static bool _validId(String id) => id.trim().isNotEmpty && id.length <= 1024;
  static List<String> _strings(Object? value, int limit) {
    if (value is! List) return const [];
    return value
        .whereType<String>()
        .where(_validId)
        .toSet()
        .take(limit)
        .toList();
  }

  static double _number(Object? value, double fallback) =>
      value is num && value.isFinite ? value.toDouble() : fallback;
  static int _integer(Object? value, int fallback, int max) =>
      value is int && value >= 0 && value <= max ? value : fallback;
}
