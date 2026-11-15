import 'package:flick/data/repositories/recently_played_repository.dart';

/// Home's greeting, ported from desktop Lokal (`src/homeGreeting.mjs`):
/// a salutation for the time of day, then one short line drawn from the
/// listener's own recent plays. Only the pattern is ever named, never a
/// track, artist, album or genre, and nothing is stored.

const _calmGenres = [
  'ambient', 'chill', 'lo-fi', 'lofi', 'slowcore', 'acoustic', 'classical', //
  'jazz', 'dream pop', 'downtempo', 'instrumental', 'new age', 'soft rock',
];
const _energyGenres = [
  'techno', 'trance', 'drum and bass', 'dnb', 'metal', 'hardcore', 'punk', //
  'hardstyle', 'dance', 'edm', 'breakbeat', 'electro', 'industrial',
];

/// "Good morning", "Good afternoon" or "Good evening", as on desktop.
String lokalHomeSalutation(int hour) => hour < 12
    ? 'Good morning'
    : hour < 18
    ? 'Good afternoon'
    : 'Good evening';

String _timeOfDay(int hour) {
  if (hour < 12) return 'Ready for a fresh soundtrack?';
  if (hour < 18) return 'What sounds good this afternoon?';
  if (hour < 23) return 'Settling into your evening soundtrack?';
  return 'Keeping the late hours company?';
}

List<String> _genres(String? raw) => {
  for (final part in (raw ?? '').split(RegExp('[,;|]')))
    if (part.trim().isNotEmpty) part.trim().toLowerCase(),
}.toList();

bool _matches(List<String> genres, List<String> hints) =>
    genres.any((genre) => hints.any(genre.contains));

/// One short line from the latest 40 plays in [history], newest first or
/// not. Falls back to a time-of-day line when there is too little to go on.
class LokalHomeMessages {
  const LokalHomeMessages(this.headline, this.subheader);
  final String headline, subheader;
}

LokalHomeMessages lokalHomeMessages(
  List<RecentlyPlayedEntry> history, {
  DateTime? now,
}) {
  final at = now ?? DateTime.now();
  final subheader = lokalHomeGreeting(history, now: at);
  final headline = switch (subheader) {
    'The repeat button has been getting a workout.' => 'On repeat',
    'Your mellow side has been getting more play.' => 'Taking it easy',
    'High-energy listening has been winning lately.' => 'High energy',
    'Your after-dark listening rhythm is holding steady.' => 'Night owl',
    'You have a soundtrack for the early hours.' => 'Early bird',
    'Your listening streak has some momentum.' => 'In a groove',
    'Lots of different sounds in your rotation lately.' => 'Wide rotation',
    _ => lokalHomeSalutation(at.hour),
  };
  return LokalHomeMessages(headline, subheader);
}

String lokalHomeGreeting(List<RecentlyPlayedEntry> history, {DateTime? now}) {
  final at = now ?? DateTime.now();
  final recent =
      history
          .where(
            (entry) =>
                entry.playedAt.millisecondsSinceEpoch > 0 &&
                !entry.playedAt.isAfter(at.add(const Duration(minutes: 5))),
          )
          .toList()
        ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
  if (recent.length > 40) recent.removeRange(40, recent.length);

  if (recent.length < 5) return _timeOfDay(at.hour);

  final counts = <String, int>{};
  for (final entry in recent.take(8)) {
    counts.update(entry.song.id, (n) => n + 1, ifAbsent: () => 1);
  }
  if (counts.values.any((n) => n >= 3)) {
    return 'The repeat button has been getting a workout.';
  }

  final tagged = [
    for (final entry in recent)
      if (_genres(entry.song.genre) case final genres when genres.isNotEmpty)
        genres,
  ];
  if (tagged.length >= 6) {
    final calm = tagged.where((g) => _matches(g, _calmGenres)).length;
    final energetic = tagged.where((g) => _matches(g, _energyGenres)).length;
    if (calm / tagged.length >= .55) {
      return 'Your mellow side has been getting more play.';
    }
    if (energetic / tagged.length >= .55) {
      return 'High-energy listening has been winning lately.';
    }
  }

  final hours = [for (final entry in recent.take(30)) entry.playedAt.hour];
  final night = hours.where((h) => h >= 22 || h < 5).length;
  final morning = hours.where((h) => h >= 5 && h < 9).length;
  if (hours.length >= 6 && night / hours.length >= .5) {
    return 'Your after-dark listening rhythm is holding steady.';
  }
  if (hours.length >= 6 && morning / hours.length >= .5) {
    return 'You have a soundtrack for the early hours.';
  }

  final activeDays = {
    for (final entry in recent)
      if (at.difference(entry.playedAt) < const Duration(days: 7))
        DateTime(entry.playedAt.year, entry.playedAt.month, entry.playedAt.day),
  };
  if (activeDays.length >= 4) return 'Your listening streak has some momentum.';

  final artists = [
    for (final entry in recent)
      if (entry.song.artist.trim().isNotEmpty)
        entry.song.artist.trim().toLowerCase(),
  ];
  if (artists.length >= 8 && artists.toSet().length / artists.length >= .8) {
    return 'Lots of different sounds in your rotation lately.';
  }

  return _timeOfDay(at.hour);
}
