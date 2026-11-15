import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'package:flick/features/spotify/spotify_api.dart';
import 'package:flick/features/spotify/spotify_http.dart';
import 'package:flick/features/spotify/spotify_models.dart';
import 'package:flick/features/spotify/spotify_oauth.dart';
import 'package:flick/features/spotify/spotify_storage.dart';
import 'package:flick/features/spotify/spotify_sync.dart';
import 'package:flick/models/song.dart';

class _MemoryPreferences implements SpotifyPreferenceStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

class _MemoryTokens implements SpotifyTokenStore {
  SpotifyTokens? value;

  @override
  Future<SpotifyTokens?> readTokens() async => value;

  @override
  Future<void> clearTokens() async => value = null;

  @override
  Future<void> writeTokens(SpotifyTokens tokens) async => value = tokens;
}

class _Browser implements SpotifyOAuthBrowser {
  var authenticateCount = 0;
  String? sessionCookie = 'session-cookie';
  SpotifyTokens? minted = SpotifyTokens(
    accessToken: 'access',
    refreshToken: null,
    expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
  );

  @override
  Future<String?> authenticate() async {
    authenticateCount++;
    return sessionCookie;
  }

  @override
  Future<SpotifyTokens?> mintTokens(String sessionCookie) async => minted;

  @override
  Future<void> cancel() async {}

  @override
  Future<void> clearSession() async {}
}

Song _song(String id, String title, String artist, int seconds) => Song(
      id: id,
      title: title,
      artist: artist,
      duration: Duration(seconds: seconds),
      fileType: 'FLAC',
    );

void main() {
  test('BitChord-style web session is stored after in-app sign-in', () async {
    final tokens = _MemoryTokens();
    final browser = _Browser();
    final oauth = SpotifyOAuthService(
      tokenStore: tokens,
      browser: browser,
    );

    final result = await oauth.signIn();

    expect(result.accessToken, 'access');
    expect(browser.authenticateCount, 1);
    expect((await tokens.readTokens())?.sessionCookie, 'session-cookie');
  });

  test('Spotify API follows same-origin pages and parses real metadata', () async {
    final tokens = _MemoryTokens()
      ..value = SpotifyTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
        expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        clientToken: 'client-token',
      );
    final oauth = SpotifyOAuthService(tokenStore: tokens);
    final client = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer access');
      expect(request.headers['client-token'], 'client-token');
      expect(request.headers['app-platform'], 'WebPlayer');
      if (request.url.queryParameters['offset'] == '0') {
        return http.Response(
          '{"items":[{"id":"p1","name":"Road trip","tracks":{"total":2},"owner":{"display_name":"Me"}}],"next":"https://api.spotify.com/v1/me/playlists?limit=50&offset=50"}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response(
        '{"items":[{"id":"p2","name":"Second"}],"next":null}',
        200,
      );
    });
    final api = SpotifyApi(
      tokenStore: tokens,
      oauth: oauth,
      client: client,
    );

    final playlists = await api.getPlaylists();

    expect(playlists.map((playlist) => playlist.id), ['p1', 'p2']);
    expect(playlists.first.tracksTotal, 2);
  });

  test('Spotify liked sync is one-way, strict and idempotent', () async {
    final preferences = _MemoryPreferences();
    final metadata = SpotifyMetadataStore(preferences);
    final local = <Song>[
      _song('local-1', 'Track', 'Artist', 180),
      _song('local-ambiguous', 'Track', 'Artist', 181),
    ];
    final api = _FakeApi([
      SpotifyTrack(
        id: 'spotify-1',
        title: 'Track',
        artist: 'Artist',
        album: null,
        durationMs: 180000,
      ),
      SpotifyTrack(
        id: 'spotify-2',
        title: 'Missing',
        artist: 'Nobody',
        album: null,
        durationMs: 200000,
      ),
    ]);
    final favorites = _FakeFavorites({'existing'});
    final service = SpotifySyncService(
      api: api,
      metadata: metadata,
      library: _FakeLibrary(local),
      favorites: favorites,
    );

    final report = await service.syncLikedSongs();

    expect(report.totalTracks, 2);
    expect(report.matchedTracks, 1);
    expect(report.addedCount, 1);
    expect(report.unmatchedTracks.single.title, 'Missing');
    expect(report.readbackVerified, isTrue);
    expect(favorites.ids, contains('local-1'));
    expect(favorites.ids, contains('existing'));
    expect((await metadata.load()).lastLikedSync, isNotNull);
  });
}

class _FakeApi implements SpotifyLibraryApi {
  _FakeApi(this.liked);

  final List<SpotifyTrack> liked;

  @override
  Future<List<SpotifyPlaylist>> getPlaylists({
    void Function(int loaded)? onProgress,
    SpotifyCancellation? cancellation,
  }) async => const [];

  @override
  Future<List<SpotifyTrack>> getPlaylistTracks(
    String playlistId, {
    void Function(int loaded)? onProgress,
    SpotifyCancellation? cancellation,
  }) async => const [];

  @override
  Future<List<SpotifyTrack>> getLikedSongs({
    void Function(int loaded)? onProgress,
    SpotifyCancellation? cancellation,
  }) async => liked;
}

class _FakeLibrary implements SpotifyLocalLibrary {
  _FakeLibrary(this.songs);
  final List<Song> songs;

  @override
  Future<List<Song>> allSongs() async => songs;
}

class _FakeFavorites implements SpotifyFavoritesSink {
  _FakeFavorites(Iterable<String> ids) : ids = {...ids};
  final Set<String> ids;

  @override
  Future<void> addFavorite(String songId) async => ids.add(songId);

  @override
  Future<List<Song>> readFavorites() async => [
        for (final id in ids)
          _song(id, 'Saved', 'Artist', 1),
      ];

  @override
  Future<bool> isFavorite(String songId) async => ids.contains(songId);
}
