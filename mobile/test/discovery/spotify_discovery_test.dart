import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'package:flick/features/discovery/spotify_discovery.dart';
import 'package:flick/features/spotify/spotify_api.dart';
import 'package:flick/features/spotify/spotify_oauth.dart';
import 'package:flick/features/spotify/spotify_storage.dart';

class _MemoryTokens implements SpotifyTokenStore {
  SpotifyTokens? value = SpotifyTokens(
    accessToken: 'access',
    refreshToken: null,
    expiresAt: DateTime.utc(2030),
    sessionCookie: 'session-cookie',
  );

  @override
  Future<SpotifyTokens?> readTokens() async => value;

  @override
  Future<void> writeTokens(SpotifyTokens tokens) async => value = tokens;

  @override
  Future<void> clearTokens() async => value = null;
}

Map<String, dynamic> _track(String id, String title, String artist) => {
  'id': id,
  'name': title,
  'artists': [
    {'name': artist},
  ],
  'album': {
    'name': 'Album $id',
    'images': [
      {'url': 'https://i.scdn.co/image/$id'},
    ],
  },
};

void main() {
  test(
    'Spotify Discovery parses personal shelves and recommendation tracks',
    () async {
      final tokens = _MemoryTokens();
      final client = MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer access');
        switch (request.url.path) {
          case '/v1/me':
            return http.Response(
              '{"id":"listener","display_name":"Listener"}',
              200,
            );
          case '/v1/me/top/tracks':
            return http.Response(
              '{"items":[${_json(_track('top', 'Top Song', 'Artist'))}]}',
              200,
            );
          case '/v1/me/player/recently-played':
            return http.Response(
              '{"items":[{"played_at":"2026-10-20T12:00:00Z","track":${_json(_track('recent', 'Recent Song', 'Artist'))}}]}',
              200,
            );
          case '/v1/me/tracks':
            return http.Response(
              '{"items":[{"added_at":"2026-10-19T12:00:00Z","track":${_json(_track('liked', 'Liked Song', 'Artist'))}}]}',
              200,
            );
          case '/v1/me/top/artists':
            return http.Response(
              '{"items":[{"id":"artist-id","name":"Artist","images":[{"url":"https://i.scdn.co/image/artist"}]}]}',
              200,
            );
          case '/v1/artists/artist-id/albums':
            return http.Response(
              '{"items":[{"id":"album-id","name":"New Album","artists":[{"name":"Artist"}],"images":[]}]}',
              200,
            );
          case '/v1/recommendations':
            return http.Response(
              '{"tracks":[${_json(_track('fresh', 'Fresh Song', 'New Artist'))}]}',
              200,
            );
          default:
            return http.Response('{}', 404);
        }
      });
      final oauth = SpotifyOAuthService(tokenStore: tokens);
      final api = SpotifyApi(tokenStore: tokens, oauth: oauth, client: client);

      final data = await loadSpotifyDiscovery(api: api);

      expect(data.account, 'Listener');
      expect(data.quickPicks.single.title, 'Top Song');
      expect(data.recentlyPlayed.single.scrobbledAt, isNotNull);
      expect(data.likedSongs.single.title, 'Liked Song');
      expect(data.artists.single.name, 'Artist');
      expect(data.albums.single.title, 'New Album');
      expect(data.freshFinds.single.title, 'Fresh Song');
    },
  );
}

String _json(Map<String, dynamic> value) =>
    '{${value.entries.map((entry) => '"${entry.key}":${_value(entry.value)}').join(',')}}';

String _value(Object? value) {
  if (value is String) return '"${value.replaceAll('"', r'\"')}"';
  if (value is Map) return _json(Map<String, dynamic>.from(value));
  if (value is List) return '[${value.map(_value).join(',')}]';
  return '$value';
}
