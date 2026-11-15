import 'package:flick/data/repositories/recently_played_repository.dart';
import 'package:flick/features/konnekted/lokal_home_greeting.dart';
import 'package:flick/models/song.dart';
import 'package:flutter_test/flutter_test.dart';

// The same cases as desktop's scripts/home-greeting.test.mjs.
final _now = DateTime(2026, 10, 19, 12);

List<RecentlyPlayedEntry> _rows(
  int count, {
  String genre = '',
  int playedHour = 12,
  bool sameTrack = false,
  int? artistCount,
}) => [
  for (var i = 0; i < count; i++)
    _entry(
      id: sameTrack ? 'same-id' : 'track-$i',
      artist: 'Private artist name ${i % (artistCount ?? count)}',
      genre: genre,
      playedAt: DateTime(
        _now.year,
        _now.month,
        _now.day - (i * 7 ~/ count) - 1,
        playedHour,
      ),
    ),
];

List<RecentlyPlayedEntry> _rowsOnDays(
  List<int> daysAgo, {
  int playedHour = 11,
  int? artistCount,
}) => [
  for (var i = 0; i < daysAgo.length; i++)
    _entry(
      id: 'dated-track-$i',
      artist: 'Private dated artist ${i % (artistCount ?? daysAgo.length)}',
      playedAt: DateTime(
        _now.year,
        _now.month,
        _now.day - daysAgo[i],
        playedHour,
      ),
    ),
];

RecentlyPlayedEntry _entry({
  required String id,
  required String artist,
  required DateTime playedAt,
  String genre = '',
}) => RecentlyPlayedEntry(
  song: Song(
    id: id,
    title: 'Private track name $id',
    artist: artist,
    duration: const Duration(minutes: 3),
    fileType: 'FLAC',
    genre: genre,
  ),
  playedAt: playedAt,
);

String _greet(List<RecentlyPlayedEntry> history, {int hour = 12}) =>
    lokalHomeGreeting(
      history,
      now: DateTime(_now.year, _now.month, _now.day, hour),
    );

void main() {
  test('salutation follows the hour', () {
    expect(lokalHomeSalutation(9), 'Good morning');
    expect(lokalHomeSalutation(14), 'Good afternoon');
    expect(lokalHomeSalutation(21), 'Good evening');
  });

  test('time-of-day fallback with too little history', () {
    expect(_greet([], hour: 9), 'Ready for a fresh soundtrack?');
    expect(_greet([], hour: 23), 'Keeping the late hours company?');
  });

  test('repeated track, without naming it', () {
    final message = _greet(_rows(8, sameTrack: true, artistCount: 1));
    expect(message, 'The repeat button has been getting a workout.');
    expect(message, isNot(contains('Private')));
  });

  test('mellow and high-energy profiles', () {
    expect(
      _greet(_rows(12, genre: 'Ambient', artistCount: 10)),
      'Your mellow side has been getting more play.',
    );
    expect(
      _greet(_rows(12, genre: 'Techno', artistCount: 10)),
      'High-energy listening has been winning lately.',
    );
  });

  test('late-night listening', () {
    expect(
      _greet(_rows(10, playedHour: 23, artistCount: 10)),
      'Your after-dark listening rhythm is holding steady.',
    );
  });

  test('five plays are needed before a pattern', () {
    expect(
      _greet(_rows(4, sameTrack: true, artistCount: 1)),
      'What sounds good this afternoon?',
    );
    expect(
      _greet(_rows(5, sameTrack: true, artistCount: 1)),
      'The repeat button has been getting a workout.',
    );
  });

  test('early-morning listening', () {
    expect(
      _greet(
        _rowsOnDays([1, 2, 3, 4, 5, 6, 6, 6], playedHour: 6, artistCount: 8),
      ),
      'You have a soundtrack for the early hours.',
    );
  });

  test('a streak counts distinct days, not plays', () {
    expect(
      _greet(_rowsOnDays([1, 1, 1, 3, 3, 3, 5, 5], artistCount: 3)),
      'What sounds good this afternoon?',
    );
    expect(
      _greet(_rowsOnDays([1, 1, 3, 3, 5, 5, 6, 6], artistCount: 3)),
      'Your listening streak has some momentum.',
    );
  });

  test('many different artists', () {
    expect(
      _greet(_rowsOnDays(List.filled(10, 1), artistCount: 10)),
      'Lots of different sounds in your rotation lately.',
    );
  });
}
