import 'dart:math';

import 'package:flick/features/konnekted/lokal_mixes.dart';
import 'package:flick/models/song.dart';
import 'package:flutter_test/flutter_test.dart';

Song _song(
  String id, {
  String artist = 'Artist',
  String? genre,
  DateTime? added,
}) => Song(
  id: id,
  title: 'Song $id',
  artist: artist,
  genre: genre,
  duration: const Duration(minutes: 3),
  fileType: 'FLAC',
  dateAdded: added,
);

void main() {
  final day = DateTime(2026, 10, 19, 9);

  test('explicit refresh rerolls mixes without changing library ownership', () {
    final library = [for (var i = 0; i < 60; i++) _song('$i')];
    List<String> daily(int seed) => lokalMixes(
      library: library,
      liked: [],
      history: [],
      playCounts: {},
      now: day,
      refreshSeed: seed,
    ).first.tracks.map((song) => song.id).toList();
    expect(daily(0), daily(0));
    expect(daily(1), isNot(daily(0)));
    expect(
      daily(1).every((id) => library.any((song) => song.id == id)),
      isTrue,
    );
    expect(library, hasLength(60));
  });

  test('an empty library has no mixes', () {
    expect(
      lokalMixes(library: [], liked: [], history: [], playCounts: {}),
      isEmpty,
    );
  });

  test('builds desktop\'s mixes in desktop\'s order', () {
    final library = [
      for (var i = 0; i < 40; i++)
        _song(
          '$i',
          artist: i < 10 ? 'Burial' : 'Other $i',
          genre: i.isEven ? 'Ambient, Electronic' : 'Jazz',
          added: DateTime(2026, 1, 1 + i),
        ),
    ];
    final liked = library.take(6).toList();
    final history = [for (var i = 0; i < 8; i++) library[i]];
    final counts = {for (var i = 0; i < 8; i++) '$i': 8 - i};

    final mixes = lokalMixes(
      library: library,
      liked: liked,
      history: history,
      playCounts: counts,
      now: day,
    );
    expect(mixes.map((m) => m.id).take(4), [
      'daily',
      'recent',
      'top',
      'discovery',
    ]);
    // Daily Mix comes from favourites.
    expect(mixes[0].tracks.toSet(), liked.toSet());
    // New Arrivals: the 30 of the newest 50 (all 40 here), shuffled.
    expect(mixes[1].tracks, hasLength(30));
    // Most Played: only songs with plays.
    expect(mixes[2].tracks.map((s) => s.id).toSet(), counts.keys.toSet());
    // Discovery Weekly: never-played songs only.
    expect(mixes[3].tracks.any((s) => counts.containsKey(s.id)), isFalse);
    // Taste mixes: genres from the tags, then the artist (an artist's mix
    // reads "<artist> Mix").
    final genre = mixes.where((m) => m.type == LokalMixType.genre).toList();
    expect(genre.first.name, 'Ambient Mix');
    expect(
      genre.first.tracks.every((s) => s.genre!.contains('Ambient')),
      isTrue,
    );
    final artist = mixes.firstWhere((m) => m.type == LokalMixType.artist);
    expect(artist.title, 'Burial Mix');
    expect(artist.tracks.every((s) => s.artist == 'Burial'), isTrue);
  });

  test('without favourites, Daily Mix samples the library', () {
    final library = [for (var i = 0; i < 5; i++) _song('$i')];
    final mixes = lokalMixes(
      library: library,
      liked: [],
      history: [],
      playCounts: {},
      now: day,
    );
    expect(mixes.first.name, 'Daily Mix');
    expect(mixes.first.tracks, hasLength(5));
  });

  test('a mix needs three songs', () {
    final library = [_song('a'), _song('b')];
    expect(
      lokalMixes(library: library, liked: [], history: [], playCounts: {}),
      isEmpty,
    );
  });

  test('the same day gives the same mixes; the next day reshuffles', () {
    final library = [for (var i = 0; i < 60; i++) _song('$i')];
    List<String> daily(DateTime when) => lokalMixes(
      library: library,
      liked: [],
      history: [],
      playCounts: {},
      now: when,
    ).first.tracks.map((s) => s.id).toList();
    expect(daily(day), daily(day.add(const Duration(hours: 10))));
    expect(daily(day), isNot(daily(day.add(const Duration(days: 1)))));
  });

  test('Made for you: four per mix, six mixes, no song twice', () {
    final shared = _song('shared');
    final mixes = [
      for (var m = 0; m < 8; m++)
        LokalMix(
          id: 'm$m',
          name: 'Mix $m',
          type: LokalMixType.genre,
          tracks: [shared, for (var i = 0; i < 5; i++) _song('$m-$i')],
        ),
    ];
    final picks = pickMadeForYou(mixes, random: Random(1));
    expect(picks, hasLength(24));
    expect(picks.map((p) => p.song.id).toSet(), hasLength(24));
    expect(picks.map((p) => p.mix.id).toSet(), {
      for (var m = 0; m < 6; m++) 'm$m',
    });
    // In mix order.
    expect(picks.first.mix.id, 'm0');
    expect(picks.last.mix.id, 'm5');
  });

  test('Made for you is picked once per run', () {
    forgetLokalMadeForYou();
    addTearDown(forgetLokalMadeForYou);
    expect(lokalMadeForYou(const []), isEmpty);
    final mix = LokalMix(
      id: 'daily',
      name: 'Daily Mix',
      type: LokalMixType.daily,
      tracks: [for (var i = 0; i < 6; i++) _song('$i')],
    );
    final first = lokalMadeForYou([mix]);
    expect(first, hasLength(4));
    expect(
      lokalMadeForYou([mix, mix]).map((p) => p.song.id),
      first.map((p) => p.song.id),
    );
    final all = [
      mix,
      for (var m = 1; m < 6; m++)
        LokalMix(
          id: 'm$m',
          name: 'Mix $m',
          type: LokalMixType.genre,
          tracks: [for (var i = 0; i < 4; i++) _song('$m-$i')],
        ),
    ];
    final filled = lokalMadeForYou(all);
    expect(filled, hasLength(24));
    for (final mix in all) {
      expect(filled.where((p) => p.mix.id == mix.id), hasLength(4));
    }
    expect(filled.take(4).map((p) => p.song.id), first.map((p) => p.song.id));
  });
}
