import 'dart:convert';

import 'package:flick/features/spotify/spotify_likes_sync_service.dart';
import 'package:flick/features/spotify/spotify_web_api.dart';
import 'package:flick/features/spotify/spotify_oauth.dart';
import 'package:flick/features/spotify/spotify_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class Store implements SpotifyTokenStore {
  SpotifyTokens? value = SpotifyTokens(
    accessToken: 'test',
    refreshToken: null,
    sessionCookie: 'cookie',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
    queryHashes: {'fetchLibraryTracks': 'a' * 64},
  );
  @override
  Future<SpotifyTokens?> readTokens() async => value;
  @override
  Future<void> writeTokens(SpotifyTokens tokens) async {
    value = tokens;
  }

  @override
  Future<void> clearTokens() async {
    value = null;
  }
}

Map<String, dynamic> item(String id, String at) => {
  'addedAt': {'isoString': at},
  'track': {
    '_uri': 'spotify:track:$id',
    'data': {
      '__typename': 'Track',
      'name': id,
      'artists': {
        'items': [
          {
            'profile': {'name': 'Artist'},
          },
        ],
      },
    },
  },
};
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('activation reads one baseline; only later likes are applied; failed matches retain cursor', () async {
    final store = Store();
    final limits = <int>[];
    var phase = 0;
    var succeed = false;
    final applied = <String>[];
    final service = SpotifyLikesSyncService.testing(
      apiFactory: () => SpotifyWebApi(
        store: store,
        oauth: SpotifyOAuthService(tokenStore: store),
        client: MockClient((request) async {
          final body = jsonDecode(request.body);
          limits.add(body['variables']['limit'] as int);
          expect(body['extensions']['persistedQuery']['sha256Hash'], 'a' * 64);
          final rows = phase == 0
              ? [item('0000000000000000000000', '2026-10-20T00:00:00Z')]
              : [
                  item('1111111111111111111111', '2026-10-21T00:00:00Z'),
                  item('0000000000000000000000', '2026-10-20T00:00:00Z'),
                ];
          return http.Response(
            jsonEncode({
              'data': {
                'me': {
                  'library': {
                    'tracks': {'items': rows},
                  },
                },
              },
            }),
            200,
          );
        }),
      ),
      apply: (tracks, cancel) async {
        applied.addAll(tracks.map((t) => t.id));
        return succeed ? tracks.map((t) => t.id).toSet() : {};
      },
    );
    await service.setEnabled(true);
    expect(limits, [1]);
    expect(applied, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    final baseline = prefs.getInt(SpotifyLikesSyncService.cursorKey)!;
    phase = 1;
    await service.sync();
    expect(applied, ['1111111111111111111111']);
    expect(prefs.getInt(SpotifyLikesSyncService.cursorKey), baseline);
    succeed = true;
    await service.sync();
    expect(
      prefs.getInt(SpotifyLikesSyncService.cursorKey),
      DateTime.parse('2026-10-21T00:00:00Z').millisecondsSinceEpoch,
    );
    expect(limits, [1, 50, 50]);
    await service.setEnabled(false);
    service.pause();
  });
  test('old backfill policy upgrades by seeding a new baseline without importing anything', () async {
    SharedPreferences.setMockInitialValues({
      SpotifyLikesSyncService.enabledKey: true,
      SpotifyLikesSyncService.cursorKey: 1,
    });
    final store = Store();
    var imported = false;
    final service = SpotifyLikesSyncService.testing(
      apiFactory: () => SpotifyWebApi(
        store: store,
        oauth: SpotifyOAuthService(tokenStore: store),
        client: MockClient((request) async {
          expect(jsonDecode(request.body)['variables']['limit'], 1);
          return http.Response(
            jsonEncode({
              'data': {
                'me': {
                  'library': {
                    'tracks': {
                      'items': [
                        item('0000000000000000000000', '2026-10-20T00:00:00Z'),
                      ],
                    },
                  },
                },
              },
            }),
            200,
          );
        }),
      ),
      apply: (tracks, cancel) async {
        imported = true;
        return {};
      },
    );
    await service.sync();
    expect(imported, isFalse);
    expect(
      (await SharedPreferences.getInstance()).getInt(
        SpotifyLikesSyncService.policyKey,
      ),
      2,
    );
  });
}
