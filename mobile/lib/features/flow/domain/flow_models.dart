/// Flow's domain deliberately has no Flutter, database, or player dependency.
enum FlowMood {
  flow('Flow', []),
  love('Love', ['r&b', 'soul', 'pop', 'acoustic']),
  workout('Workout', ['hip-hop', 'electronic', 'dance', 'edm', 'metal']),
  chill('Chill', ['ambient', 'chill', 'acoustic', 'jazz', 'lo-fi']),
  sad('Sad', ['acoustic', 'indie', 'soul', 'folk', 'piano']),
  focus('Focus', ['classical', 'ambient', 'jazz', 'lo-fi', 'soundtrack']),
  party('Party', ['dance', 'pop', 'latin', 'hip-hop', 'edm']);

  const FlowMood(this.label, this.genreHints);
  final String label;
  final List<String> genreHints;
}

String normalizeFlowText(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String normalizeFlowGenre(String value) => switch (normalizeFlowText(value)) {
  'hip hop' || 'hiphop' => 'hip-hop',
  'rnb' || 'r & b' || 'rhythm and blues' => 'r&b',
  'lofi' || 'lo fi' => 'lo-fi',
  final genre => genre,
};

Set<String> flowGenres(String? value) => {
  for (final part in (value ?? '').split(RegExp(r'[;,/|]')))
    if (normalizeFlowGenre(part).isNotEmpty) normalizeFlowGenre(part),
};

class FlowRules {
  static const favoriteThreshold = 16;
  static const initialTracks = 24;
  static const topUpTracks = 10;
  static const maxSessionTracks = 200;
  static const maxSignals = 500;
  static const maxBans = 10000;
  static const sessionTtl = Duration(hours: 24);

  // The host has track favorites only. Artist affinity is never a follow.
  static bool isUnlocked(int favoriteCount) =>
      favoriteCount >= favoriteThreshold;
  static int needed(int favoriteCount) =>
      (favoriteThreshold - favoriteCount).clamp(0, favoriteThreshold);
}

class FlowConfig {
  FlowConfig({
    this.mood = FlowMood.flow,
    double discovery = .35,
    double memory = .5,
    Iterable<String> excludedGenres = const [],
  }) : discovery = _axis(discovery, .35),
       memory = _axis(memory, .5),
       excludedGenres = Set.unmodifiable(
         excludedGenres.map(normalizeFlowGenre).where((g) => g.isNotEmpty),
       );

  final FlowMood mood;
  final double discovery;
  final double memory;
  final Set<String> excludedGenres;

  static double _axis(double value, double fallback) =>
      value.isFinite ? value.clamp(0, 1).toDouble() : fallback;

  FlowConfig copyWith({
    FlowMood? mood,
    double? discovery,
    double? memory,
    Iterable<String>? excludedGenres,
  }) => FlowConfig(
    mood: mood ?? this.mood,
    discovery: discovery ?? this.discovery,
    memory: memory ?? this.memory,
    excludedGenres: excludedGenres ?? this.excludedGenres,
  );

  @override
  bool operator ==(Object other) =>
      other is FlowConfig &&
      mood == other.mood &&
      discovery == other.discovery &&
      memory == other.memory &&
      excludedGenres.length == other.excludedGenres.length &&
      excludedGenres.containsAll(other.excludedGenres);

  @override
  int get hashCode => Object.hash(
    mood,
    discovery,
    memory,
    Object.hashAllUnordered(excludedGenres),
  );
}

/// A tuner transaction owns its immutable draft; dismissal returns no value.
class FlowTunerDraft {
  FlowTunerDraft(this.original) : value = original;
  final FlowConfig original;
  FlowConfig value;
  bool get isDirty => value != original;
  void setGenreEnabled(String genre, bool enabled) {
    final excluded = {...value.excludedGenres};
    if (enabled) {
      excluded.remove(normalizeFlowGenre(genre));
    } else {
      excluded.add(normalizeFlowGenre(genre));
    }
    value = value.copyWith(excludedGenres: excluded);
  }

  FlowConfig apply() => value;
  FlowConfig cancel() {
    value = original;
    return original;
  }
}

/// Only metadata needed to recommend. Playback always resolves the real Song.
class FlowTrack {
  FlowTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.durationMs = 0,
    this.album = '',
    Iterable<String> genres = const [],
  }) : genres = Set.unmodifiable(genres.map(normalizeFlowGenre));

  final String id;
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final Set<String> genres;
  String get artistKey => normalizeFlowText(artist);

  /// Conservative duplicate recording identity, retaining live/remix titles.
  /// Missing metadata cannot collapse unrelated unknown tracks.
  String get recordingKey => title.trim().isEmpty || artist.trim().isEmpty
      ? 'id:$id'
      : '${normalizeFlowText(title)}\u001f$artistKey\u001f'
            '${normalizeFlowText(album)}\u001f${durationMs ~/ 1000}';
}

class FlowSession {
  FlowSession({
    Iterable<String> trackIds = const [],
    this.seed = 1,
    this.builtAtMs = 0,
    this.currentId,
  }) : trackIds = List.unmodifiable(
         trackIds.toSet().take(FlowRules.maxSessionTracks),
       );
  final List<String> trackIds;
  final int seed;
  final int builtAtMs;
  final String? currentId;

  bool isFresh(DateTime now) {
    final age = now.millisecondsSinceEpoch - builtAtMs;
    return builtAtMs > 0 &&
        age >= 0 &&
        age < FlowRules.sessionTtl.inMilliseconds;
  }
}

class FlowData {
  FlowData({
    FlowConfig? config,
    Iterable<String> bannedIds = const [],
    Map<String, int> skipCounts = const {},
    Iterable<String> recentIds = const [],
    FlowSession? session,
    this.notice,
  }) : config = config ?? FlowConfig(),
       bannedIds = Set.unmodifiable(bannedIds),
       skipCounts = Map.unmodifiable(skipCounts),
       recentIds = List.unmodifiable(
         recentIds.toSet().take(FlowRules.maxSignals),
       ),
       session = session ?? FlowSession();

  final FlowConfig config;
  final Set<String> bannedIds;
  final Map<String, int> skipCounts;

  /// Newest first. These are actual starts observed from the host player.
  final List<String> recentIds;
  final FlowSession session;
  final String? notice;

  FlowData copyWith({
    FlowConfig? config,
    Iterable<String>? bannedIds,
    Map<String, int>? skipCounts,
    Iterable<String>? recentIds,
    FlowSession? session,
  }) => FlowData(
    config: config ?? this.config,
    bannedIds: bannedIds ?? this.bannedIds,
    skipCounts: skipCounts ?? this.skipCounts,
    recentIds: recentIds ?? this.recentIds,
    session: session ?? this.session,
    notice: notice,
  );
}
