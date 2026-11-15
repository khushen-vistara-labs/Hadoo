import 'dart:async';

import 'package:flick/data/repositories/recently_played_repository.dart';
import 'package:flick/features/konnekted/konnekted_data.dart';
import 'package:flick/models/song.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Song _song(String id, {DateTime? added}) => Song(
  id: id,
  title: id,
  artist: 'Test artist',
  duration: const Duration(minutes: 3),
  fileType: 'FLAC',
  dateAdded: added,
);

class _History implements RecentlyPlayedRepository {
  final changes = StreamController<void>.broadcast();
  List<Song> songs = [];
  int reads = 0;

  @override
  Stream<void> watchHistory() => changes.stream;

  @override
  Future<List<RecentlyPlayedEntry>> getRecentHistory({int limit = 50}) async {
    reads++;
    return songs
        .take(limit)
        .map(
          (song) => RecentlyPlayedEntry(song: song, playedAt: DateTime(2026)),
        )
        .toList();
  }

  @override
  Future<Map<String, int>> getPlayCounts() async {
    counts++;
    return {for (final song in songs) song.id: 1};
  }

  int counts = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('recent shelf loads immediately, deduplicates, follows history, and detaches', () async {
    final history = _History()..songs = [_song('a'), _song('a'), _song('b')];
    final container = ProviderContainer(
      overrides: [
        konnektedHistoryRepositoryProvider.overrideWithValue(history),
      ],
    );
    final updates = <List<Song>>[];
    final subscription = container.listen(konnektedRecentSongsProvider, (
      _,
      next,
    ) {
      if (next.hasValue) updates.add(next.requireValue);
    });
    expect(
      (await container.read(konnektedRecentSongsProvider.future))
          .map((song) => song.id),
      ['a', 'b'],
    );
    expect(history.reads, 1);
    history.songs = [_song('c')];
    history.changes.add(null);
    await Future<void>.delayed(Duration.zero);
    await container.pump();
    expect(updates.last.single.id, 'c');
    subscription.close();
    container.dispose();
    expect(history.changes.hasListener, isFalse);
    await history.changes.close();
  });

  test('recently added uses dates and never mutates the source collection', () {
    final songs = [
      _song('old', added: DateTime(2020)),
      _song('new', added: DateTime(2026)),
      _song('undated'),
    ];
    final container = ProviderContainer(
      overrides: [konnektedLibraryProvider.overrideWithValue(AsyncData(songs))],
    );
    addTearDown(container.dispose);
    expect(
      container
          .read(konnektedRecentlyAddedProvider)
          .requireValue
          .map((song) => song.id),
      ['new', 'old', 'undated'],
    );
    expect(songs.map((song) => song.id), ['old', 'new', 'undated']);
  });

  test('mixes are built once for the day, not on every rebuild', () async {
    resetKonnektedMixes();
    addTearDown(resetKonnektedMixes);
    final library = [
      for (var i = 0; i < 10; i++) _song('$i', added: DateTime(2026, 1, i + 1)),
    ];
    final history = _History()..songs = library.take(4).toList();
    ProviderContainer container() => ProviderContainer(
      overrides: [
        konnektedHistoryRepositoryProvider.overrideWithValue(history),
        konnektedLibraryProvider.overrideWithValue(AsyncData(library)),
        konnektedFavoritesProvider.overrideWithValue(const AsyncData([])),
      ],
    );
    final first = container();
    final mixes = await first.read(konnektedMixesProvider.future);
    expect(mixes.map((m) => m.id), containsAll(['daily', 'recent', 'top']));
    // Discovery Weekly leaves out what was played.
    final discovery = mixes.firstWhere((m) => m.id == 'discovery');
    expect(discovery.tracks.map((s) => s.id), isNot(contains('0')));
    first.dispose();

    final second = container();
    expect(await second.read(konnektedMixesProvider.future), same(mixes));
    expect(history.counts, 1);
    second.dispose();
  });
}
