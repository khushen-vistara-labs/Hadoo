import 'package:flick/features/discovery/lastfm_discovery.dart';
import 'package:flick/services/lastfm/lastfm_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime.utc(2026, 10, 20, 12);
int get _nowSeconds => _now.millisecondsSinceEpoch ~/ 1000;

Map<String, dynamic> _scrobble(String artist, String title, int agoHours) => {
  'name': title,
  'artist': {'name': artist},
  'album': {'#text': '$title album'},
  'image': [
    {'size': 'small', '#text': 'http://img/$title-s.jpg'},
    {'size': 'extralarge', '#text': 'http://img/$title-xl.jpg'},
  ],
  'date': {'uts': '${_nowSeconds - agoHours * 3600}'},
};

Map<String, dynamic> _similar(String artist, String title) => {
  'name': title,
  'artist': {'name': artist},
  'image': [
    {
      'size': 'extralarge',
      '#text': 'https://lastfm/2a96cbd8b46e442fc41c2b86b821562f.png',
    },
  ],
};

class _FakeLastfm {
  _FakeLastfm({this.failing = const {}});

  final Set<String> failing;
  final calls = <String>[];

  Future<Map<String, dynamic>> call(
    String method,
    Map<String, String> params,
  ) async {
    calls.add(method);
    if (failing.contains(method)) throw const LastFmApiException(8, 'Boom');
    switch (method) {
      case 'user.getRecentTracks':
        if (params.containsKey('from')) {
          return {
            'recenttracks': {
              'track': [
                {
                  ..._scrobble('A', 'Now', 0),
                  '@attr': {'nowplaying': 'true'},
                },
                _scrobble('A', 'One', 1),
                _scrobble('A', 'One', 30),
                _scrobble('B', 'Two', 2),
                _scrobble('C', 'Old', 24 * 9),
              ],
              '@attr': {'totalPages': '1'},
            },
          };
        }
        return {
          'recenttracks': {
            'track': [_scrobble('A', 'One', 1), _scrobble('B', 'Two', 2)],
          },
        };
      case 'user.getTopTracks':
        return {
          'toptracks': {
            'track': [_similar('D', 'Monthly')],
          },
        };
      case 'user.getTopArtists':
        return {
          'topartists': {
            'artist': [
              {'name': 'A', 'playcount': '12', 'image': []},
            ],
          },
        };
      case 'user.getTopAlbums':
        return {
          'topalbums': {
            'album': {
              'name': 'Record',
              'artist': {'name': 'A'},
              'playcount': '4',
            },
          },
        };
      case 'track.getSimilar':
        if (params['track'] == 'Two') {
          throw const LastFmApiException(6, 'Track not found');
        }
        return {
          'similartracks': {
            'track': [_similar('E', 'Similar'), _similar('B', 'Two')],
          },
        };
      case 'artist.getSimilar':
        return {
          'similarartists': {
            'artist': [
              {'name': 'F'},
            ],
          },
        };
      case 'artist.getTopTracks':
        return {
          'toptracks': {
            'track': [_similar(params['artist']!, '${params['artist']} hit')],
          },
        };
    }
    throw StateError(method);
  }
}

void main() {
  setUp(forgetLastfmSeeds);

  test('quick picks rank the week by plays, then the latest', () {
    final picks = quickPicksFromHistory([
      LokalDiscoveryTrack(
        title: 'B',
        artist: 'X',
        scrobbledAt: _nowSeconds - 10,
      ),
      LokalDiscoveryTrack(
        title: 'A',
        artist: 'X',
        scrobbledAt: _nowSeconds - 50,
      ),
      LokalDiscoveryTrack(
        title: 'a ',
        artist: 'x',
        scrobbledAt: _nowSeconds - 40,
      ),
      LokalDiscoveryTrack(
        title: 'Old',
        artist: 'X',
        scrobbledAt: _nowSeconds - 8 * 86400,
      ),
    ], _now);
    expect(picks.map((t) => t.title), ['a ', 'B']);
    expect(picks.first.scrobbleCount, 2);
    expect(picks.first.reason, 'Scrobbled most often · past week');
  });

  test('loads every shelf, with Fresh Finds you haven\'t heard', () async {
    final lastfm = _FakeLastfm();
    final result = await loadLastfmDiscovery(
      username: 'me',
      call: lastfm.call,
      now: _now,
    );
    expect(result.quickPicks!.map((t) => t.title), ['One', 'Two']);
    expect(result.history!.map((t) => t.title), ['One', 'Two']);
    expect(result.history!.first.artworkUrl, 'https://img/One-xl.jpg');
    expect(result.artists!.single.name, 'A');
    expect(result.albums!.single.title, 'Record');
    final fresh = result.freshFinds!.map((t) => t.title).toList();
    expect(fresh, contains('Similar'));
    expect(fresh, isNot(contains('Two')), reason: 'already scrobbled');
    expect(fresh, contains('F hit'));
    expect(result.freshFinds!.first.artworkUrl, isEmpty, reason: 'placeholder');
    // An uncatalogued song isn't a failure.
    expect(result.warnings, isEmpty);
  });

  test('a failed shelf is null so the last one stays', () async {
    final result = await loadLastfmDiscovery(
      username: 'me',
      call: _FakeLastfm(failing: {'user.getTopAlbums'}).call,
      now: _now,
    );
    expect(result.albums, isNull);
    expect(result.warnings.single, startsWith('user.getTopAlbums'));
    final previous = LokalDiscovery(
      account: 'me',
      page: 0,
      albums: const [LokalDiscoveryAlbum(title: 'Kept', artist: 'A')],
    );
    expect(result.keeping(previous).albums!.single.title, 'Kept');
  });

  test('nothing answering at all is a failure', () async {
    final everything = {
      'user.getRecentTracks',
      'user.getTopTracks',
      'user.getTopArtists',
      'user.getTopAlbums',
    };
    expect(
      loadLastfmDiscovery(
        username: 'me',
        call: _FakeLastfm(failing: everything).call,
        now: _now,
      ),
      throwsA(isA<LokalDiscoveryFailure>()),
    );
    expect(
      loadLastfmDiscovery(username: ' ', call: _FakeLastfm().call),
      throwsA(isA<LokalDiscoveryFailure>()),
    );
  });

  test('refreshing within five minutes reuses the account requests', () async {
    final lastfm = _FakeLastfm();
    await loadLastfmDiscovery(username: 'me', call: lastfm.call, now: _now);
    final first = lastfm.calls.where((m) => m.startsWith('user.')).length;
    lastfm.calls.clear();
    await loadLastfmDiscovery(
      username: 'me',
      call: lastfm.call,
      page: 1,
      now: _now.add(const Duration(minutes: 2)),
    );
    expect(lastfm.calls.where((m) => m.startsWith('user.')), isEmpty);
    lastfm.calls.clear();
    await loadLastfmDiscovery(
      username: 'me',
      call: lastfm.call,
      page: 2,
      now: _now.add(const Duration(minutes: 6)),
    );
    expect(lastfm.calls.where((m) => m.startsWith('user.')).length, first);
  });
}
