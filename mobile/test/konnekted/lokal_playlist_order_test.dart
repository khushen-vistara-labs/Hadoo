import 'package:flutter_test/flutter_test.dart';
import 'package:flick/features/konnekted/library/lokal_playlist_order.dart';
import 'package:flick/models/playlist.dart';
import 'package:flick/models/song.dart';

Song song(String id, String title, String artist) => Song(
  id: id,
  title: title,
  artist: artist,
  duration: const Duration(minutes: 3),
  fileType: 'FLAC',
);

void main() {
  final playlist = Playlist(
    id: 'p',
    name: 'Big playlist',
    createdAt: DateTime(2026),
    songIds: const ['b', 'missing', 'a', 'c', 'duplicate', 'duplicate'],
    songAddedAt: {
      'b': DateTime(2026, 1, 3),
      'a': DateTime(2026, 1, 1),
      'c': DateTime(2026, 1, 2),
      'duplicate': DateTime(2026, 1, 4),
    },
  );
  final byId = {
    'a': song('a', 'alpha', 'Zulu'),
    'b': song('b', 'Beta', 'Alpha'),
    'c': song('c', 'Beta', 'Omega'),
    'duplicate': song('duplicate', 'Same', 'Alpha'),
  };

  test('title sort is case-insensitive, stable on ties and retains missing tracks', () {
    expect(
      lokalOrderedPlaylistIds(playlist, byId, LokalPlaylistOrder.titleAscending),
      ['a', 'b', 'c', 'duplicate', 'duplicate', 'missing'],
    );
    expect(
      lokalOrderedPlaylistIds(playlist, byId, LokalPlaylistOrder.titleDescending),
      ['duplicate', 'duplicate', 'b', 'c', 'a', 'missing'],
    );
  });

  test('artist sorting works in both directions', () {
    expect(
      lokalOrderedPlaylistIds(playlist, byId, LokalPlaylistOrder.artistAscending),
      ['b', 'duplicate', 'duplicate', 'c', 'a', 'missing'],
    );
    expect(
      lokalOrderedPlaylistIds(playlist, byId, LokalPlaylistOrder.artistDescending),
      ['a', 'c', 'b', 'duplicate', 'duplicate', 'missing'],
    );
  });

  test('date sort keeps undated entries, reverse preserves duplicates', () {
    expect(
      lokalOrderedPlaylistIds(playlist, byId, LokalPlaylistOrder.dateAscending),
      ['a', 'c', 'b', 'duplicate', 'duplicate', 'missing'],
    );
    expect(
      lokalOrderedPlaylistIds(playlist, byId, LokalPlaylistOrder.dateDescending),
      ['duplicate', 'duplicate', 'b', 'c', 'a', 'missing'],
    );
    expect(
      lokalOrderedPlaylistIds(playlist, byId, LokalPlaylistOrder.reverse),
      ['duplicate', 'duplicate', 'c', 'a', 'missing', 'b'],
    );
    // The existing list is never mutated by a preview.
    expect(playlist.songIds, ['b', 'missing', 'a', 'c', 'duplicate', 'duplicate']);
  });

  test('very large sort returns every ID and does not drop duplicates', () {
    final ids = List.generate(8000, (i) => 'song_$i');
    final large = playlist.copyWith(songIds: ids);
    final names = {
      for (final id in ids) id: song(id, id, 'Artist'),
    };
    final result = lokalOrderedPlaylistIds(
      large, names, LokalPlaylistOrder.titleDescending,
    );
    expect(result, hasLength(8000));
    expect(result.toSet(), ids.toSet());
    expect(result.first, 'song_999');
  });
}
