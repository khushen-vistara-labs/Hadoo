import 'dart:math';

import 'package:flick/models/song.dart';

/// Your Mixes and Made for you, ported from desktop Lokal
/// (`electron/ipc/mixes.js` and `src/madeForYou.js`).
///
/// Desktop shuffles with `RANDOM()` and caches each mix for a day (Discovery
/// for a week) while the app runs. Here the shuffles are seeded by the day
/// (Discovery by the week), so the mixes stay the same across restarts and
/// change on the same cadence.

enum LokalMixType { daily, recent, top, discovery, genre, artist }

class LokalMix {
  const LokalMix({
    required this.id,
    required this.name,
    required this.type,
    required this.tracks,
  });

  final String id;
  final String name;
  final LokalMixType type;
  final List<Song> tracks;

  /// The card title: an artist's mix reads "`artist` Mix", as on desktop.
  String get title => type == LokalMixType.artist ? '$name Mix' : name;
}

/// One of Made for you's songs and the mix it came from.
class LokalMadeForYouPick {
  const LokalMadeForYouPick({required this.song, required this.mix});

  final Song song;
  final LokalMix mix;
}

List<String> _genres(String? raw) => [
  for (final part in (raw ?? '').split(RegExp('[,;|]')))
    if (part.trim().isNotEmpty) part.trim(),
];

List<T> _shuffled<T>(Iterable<T> items, Random random) {
  final out = List<T>.of(items);
  for (var i = out.length - 1; i > 0; i--) {
    final j = random.nextInt(i + 1);
    final swap = out[i];
    out[i] = out[j];
    out[j] = swap;
  }
  return out;
}

int _daySeed(DateTime day) => day.year * 10000 + day.month * 100 + day.day;

int _weekSeed(DateTime day) {
  final monday = DateTime(day.year, day.month, day.day - (day.weekday - 1));
  return _daySeed(monday) * 7;
}

/// Your Mixes, in desktop's order: Daily Mix, New Arrivals, Most Played,
/// Discovery Weekly, then a mix for each of your four top genres and three
/// top artists. A mix needs at least three songs.
///
/// [liked] is your favourites, [history] your plays newest first, and
/// [playCounts] how often each song id has been played.
List<LokalMix> lokalMixes({
  required List<Song> library,
  required List<Song> liked,
  required List<Song> history,
  required Map<String, int> playCounts,
  DateTime? now,
  int refreshSeed = 0,
}) {
  final day = now ?? DateTime.now();
  Random daily(String salt) =>
      Random(_daySeed(day) ^ salt.hashCode ^ refreshSeed);
  final mixes = <LokalMix>[];
  if (library.isEmpty) return mixes;

  final favourites = liked.take(50).toList();
  if (favourites.length >= 3) {
    mixes.add(
      LokalMix(
        id: 'daily',
        name: 'Daily Mix',
        type: LokalMixType.daily,
        tracks: _shuffled(favourites, daily('daily')).take(30).toList(),
      ),
    );
  } else {
    final fallback = _shuffled(library, daily('daily')).take(30).toList();
    if (fallback.length >= 3) {
      mixes.add(
        LokalMix(
          id: 'daily',
          name: 'Daily Mix',
          type: LokalMixType.daily,
          tracks: fallback,
        ),
      );
    }
  }

  final added = library.where((song) => song.dateAdded != null).toList()
    ..sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
  if (added.length >= 3) {
    mixes.add(
      LokalMix(
        id: 'recent',
        name: 'New Arrivals',
        type: LokalMixType.recent,
        tracks: _shuffled(added.take(50), daily('recent')).take(30).toList(),
      ),
    );
  }

  final played =
      library.where((song) => (playCounts[song.id] ?? 0) > 0).toList()
        ..sort((a, b) => playCounts[b.id]!.compareTo(playCounts[a.id]!));
  if (played.length >= 3) {
    mixes.add(
      LokalMix(
        id: 'top',
        name: 'Most Played',
        type: LokalMixType.top,
        tracks: _shuffled(played.take(50), daily('top')).take(30).toList(),
      ),
    );
  }

  final unplayed = library.where((song) => !playCounts.containsKey(song.id));
  final discovery = _shuffled(
    unplayed,
    Random(_weekSeed(day) ^ refreshSeed),
  ).take(30).toList();
  if (discovery.length >= 3) {
    mixes.add(
      LokalMix(
        id: 'discovery',
        name: 'Discovery Weekly',
        type: LokalMixType.discovery,
        tracks: discovery,
      ),
    );
  }

  // Your taste: genres and artists across your favourites and recent plays.
  final genreCounts = <String, int>{};
  final artistCounts = <String, int>{};
  for (final song in [...favourites, ...history.take(50)]) {
    for (final genre in _genres(song.genre)) {
      genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
    }
    if (song.artist.isNotEmpty) {
      artistCounts[song.artist] = (artistCounts[song.artist] ?? 0) + 1;
    }
  }
  List<String> top(Map<String, int> counts, int n) {
    final entries = counts.entries.toList();
    // List.sort isn't stable; ties keep first-seen order, as desktop's does.
    final order = {for (final (i, e) in entries.indexed) e.key: i};
    entries.sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : order[a.key]!.compareTo(order[b.key]!);
    });
    return [for (final e in entries.take(n)) e.key];
  }

  LokalMix? genreMix(String genre, int limit) {
    final lower = genre.toLowerCase();
    final tracks = _shuffled(
      library.where((song) {
        final tag = (song.genre ?? '').toLowerCase();
        return tag == lower || tag.contains(lower);
      }),
      daily('g:$genre'),
    ).take(limit).toList();
    if (tracks.length < 3) return null;
    return LokalMix(
      id: 'mix-g-$genre',
      name: '$genre Mix',
      type: LokalMixType.genre,
      tracks: tracks,
    );
  }

  for (final genre in top(genreCounts, 4)) {
    if (genreMix(genre, 30) case final mix?) mixes.add(mix);
  }
  for (final artist in top(artistCounts, 3)) {
    final lower = artist.toLowerCase();
    final tracks = _shuffled(
      library.where((song) => song.artist.toLowerCase().contains(lower)),
      daily('a:$artist'),
    ).take(25).toList();
    if (tracks.length >= 3) {
      mixes.add(
        LokalMix(
          id: 'mix-a-$artist',
          name: artist,
          type: LokalMixType.artist,
          tracks: tracks,
        ),
      );
    }
  }

  // Nothing to go on yet: a few genre mixes from whatever is tagged.
  if (mixes.isEmpty) {
    final tagged = _shuffled(
      library.where((song) => _genres(song.genre).isNotEmpty),
      daily('fallback'),
    ).take(120);
    final genres = <String>{for (final song in tagged) ..._genres(song.genre)}
        .take(4);
    for (final genre in genres) {
      if (genreMix(genre, 25) case final mix?) mixes.add(mix);
    }
  }
  return mixes;
}

/// Made for you / Home Cover Flow: four songs per mix, first six mixes (desktop parity).
const lokalMadeForYouPerMix = 4;
const lokalMadeForYouMixes = 6;

/// Four songs from each of the first six [mixes], no song twice (a mix whose
/// songs are already picked gives others), in mix order.
List<LokalMadeForYouPick> pickMadeForYou(
  List<LokalMix> mixes, {
  Random? random,
  int perMix = lokalMadeForYouPerMix,
  int count = lokalMadeForYouMixes,
}) {
  final rng = random ?? Random();
  final seen = <String>{};
  final picks = <LokalMadeForYouPick>[];
  for (final mix in mixes.take(count)) {
    var taken = 0;
    for (final song in _shuffled(mix.tracks, rng)) {
      if (taken >= perMix) break;
      if (song.id.isEmpty || !seen.add(song.id)) continue;
      picks.add(LokalMadeForYouPick(song: song, mix: mix));
      taken++;
    }
  }
  return picks;
}

List<LokalMadeForYouPick>? _picked;

/// Explicit Home refresh also replaces the normally session-stable cover picks.
void refreshLokalMadeForYou() => _picked = null;

/// Keep this run's valid picks, filling newly available mixes as the library
/// loads. A partial initial snapshot must not freeze Cover Flow at four songs.
List<LokalMadeForYouPick> lokalMadeForYou(
  List<LokalMix> mixes, {
  Random? random,
}) {
  final rng = random ?? Random();
  final seen = <String>{};
  final picks = <LokalMadeForYouPick>[];
  for (final mix in {
    for (final mix in mixes) mix.id: mix,
  }.values.take(lokalMadeForYouMixes)) {
    final available = {for (final song in mix.tracks) song.id: song};
    final kept = (_picked ?? const <LokalMadeForYouPick>[])
        .where(
          (pick) =>
              pick.mix.id == mix.id && available.containsKey(pick.song.id),
        )
        .map((pick) => available[pick.song.id]!)
        .toList();
    var count = 0;
    for (final song in [...kept, ..._shuffled(mix.tracks, rng)]) {
      if (count >= lokalMadeForYouPerMix) break;
      if (!seen.add(song.id)) continue;
      picks.add(LokalMadeForYouPick(song: song, mix: mix));
      count++;
    }
  }
  if (picks.isNotEmpty) _picked = picks;
  return picks;
}

/// Forgets this run's picks (tests, or a cleared library).
void forgetLokalMadeForYou() => _picked = null;
