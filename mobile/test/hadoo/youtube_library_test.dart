import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flick/features/discovery/lastfm_discovery.dart';
import 'package:flick/features/discovery/youtube_music_account.dart';
import 'package:flick/features/discovery/youtube_music_playlist_cache.dart';
import 'package:flick/features/hadoo/youtube_library_provider.dart';
import 'package:flick/features/konnekted/konnekted_discovery.dart';
import 'package:flick/models/song.dart';

const session = YoutubeMusicSession(cookies: {'SAPISID': 'fake-test-cookie'});

class Accounts extends Notifier<YoutubeMusicAccount?> {
  @override
  YoutubeMusicAccount? build() => null;
  void set(YoutubeMusicAccount? value) => state = value;
}

final accounts = NotifierProvider<Accounts, YoutubeMusicAccount?>(Accounts.new);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  ProviderContainer container(YoutubeMusicAccount api) => ProviderContainer(
    overrides: [
      konnektedYoutubeMusicAccountProvider.overrideWith(
        (ref) => ref.watch(accounts),
      ),
      youtubePlaylistCacheProvider.overrideWith(
        (_) => YoutubeMusicPlaylistCache(),
      ),
    ],
  )..read(accounts.notifier).set(api);

  test(
    'confirmed create appears immediately and is a cached YouTube ID',
    () async {
      final requests = <http.Request>[];
      final client = MockClient((r) async {
        requests.add(r);
        return http.Response(
          r.url.path.endsWith('playlist/create')
              ? '{"playlistId":"PLcreated"}'
              : '{}',
          200,
        );
      });
      addTearDown(client.close);
      final c = container(YoutubeMusicAccount(client, session));
      addTearDown(c.dispose);
      await c.read(youtubeLibraryProvider.future);
      final created = await c
          .read(youtubeLibraryProvider.notifier)
          .create('My YouTube list');
      expect(created.id, 'PLcreated');
      expect(
        c.read(youtubeLibraryProvider).requireValue.playlists.single.title,
        'My YouTube list',
      );
      expect(
        (await c
                .read(youtubePlaylistCacheProvider)
                .playlists(session.accountKey))!
            .single
            .id,
        'PLcreated',
      );
      expect(
        requests.where((r) => r.url.path.endsWith('playlist/create')).length,
        1,
      );
    },
  );

  test(
    'rejected writes do not create a local playlist or change cached items',
    () async {
      final client = MockClient(
        (_) async => http.Response('{"status":"STATUS_FAILED"}', 200),
      );
      addTearDown(client.close);
      final c = container(YoutubeMusicAccount(client, session));
      addTearDown(c.dispose);
      await c.read(youtubeLibraryProvider.future);
      await expectLater(
        c.read(youtubeLibraryProvider.notifier).create('Must not exist'),
        throwsA(isA<LokalDiscoveryFailure>()),
      );
      expect(c.read(youtubeLibraryProvider).requireValue.playlists, isEmpty);
      expect(
        await c
            .read(youtubePlaylistCacheProvider)
            .playlists(session.accountKey),
        isEmpty,
      );
    },
  );

  test(
    'a late create acknowledgement cannot populate a signed-out account',
    () async {
      final answer = Completer<http.Response>();
      final client = MockClient(
        (r) async => r.url.path.endsWith('playlist/create')
            ? answer.future
            : http.Response('{}', 200),
      );
      addTearDown(client.close);
      final c = container(YoutubeMusicAccount(client, session));
      addTearDown(c.dispose);
      await c.read(youtubeLibraryProvider.future);
      final creation = c
          .read(youtubeLibraryProvider.notifier)
          .create('Old account');
      final expectation = expectLater(
        creation,
        throwsA(isA<LokalDiscoveryFailure>()),
      );
      await Future<void>.delayed(Duration.zero);
      c.read(accounts.notifier).set(null);
      await c.read(youtubeLibraryProvider.future);
      answer.complete(http.Response('{"playlistId":"PLold"}', 200));
      await expectation;
      expect(c.read(youtubeLibraryProvider).requireValue.account, isNull);
      expect(c.read(youtubeLibraryProvider).requireValue.playlists, isEmpty);
    },
  );

  test('adding an unknown local recording never silently searches for a substitute', () {
    const local = Song(
      id: '1',
      title: 'Song',
      artist: 'Artist',
      duration: Duration.zero,
      fileType: 'MP3',
    );
    expect(
      () => youtubeIdsForSongs([local]),
      throwsA(isA<LokalDiscoveryFailure>()),
    );
    expect(youtubeIdsForSongs([local.copyWith(remoteId: 'yt:abcdefghijk')]), [
      'abcdefghijk',
    ]);
  });

  test(
    'duplicate adds read YouTube and write only missing recording IDs',
    () async {
      final edits = <Map>[];
      final client = MockClient((r) async {
        final body = jsonDecode(r.body) as Map;
        if (r.url.path.endsWith('browse/edit_playlist')) {
          edits.add(body);
          return http.Response('{"status":"STATUS_SUCCEEDED"}', 200);
        }
        return http.Response(
          jsonEncode({
            'musicPlaylistShelfRenderer': {
              'contents': [
                {
                  'musicResponsiveListItemRenderer': {
                    'playlistItemData': {'videoId': 'abcdefghijk'},
                    'flexColumns': [
                      {
                        'musicResponsiveListItemFlexColumnRenderer': {
                          'text': {
                            'runs': [
                              {'text': 'Existing'},
                            ],
                          },
                        },
                      },
                    ],
                  },
                },
              ],
            },
          }),
          200,
        );
      });
      addTearDown(client.close);
      final c = container(YoutubeMusicAccount(client, session));
      addTearDown(c.dispose);
      await c.read(youtubeLibraryProvider.future);
      const existing = Song(
        id: 'one',
        title: 'Existing',
        artist: 'Artist',
        duration: Duration.zero,
        fileType: 'ONLINE',
        remoteId: 'yt:abcdefghijk',
      );
      final result = await c.read(youtubeLibraryProvider.notifier).add(
        'PLmine',
        [existing],
      );
      expect(result.added, 0);
      expect(result.skipped, 1);
      expect(result.message, contains('already in'));
      expect(edits, isEmpty);
      final mixed = await c.read(youtubeLibraryProvider.notifier).add(
        'PLmine',
        [existing, existing.copyWith(id: 'two', remoteId: 'yt:lmnopqrstuv')],
      );
      expect(mixed.added, 1);
      expect(mixed.skipped, 1);
      expect(edits.single['actions'], [
        {'action': 'ACTION_ADD_VIDEO', 'addedVideoId': 'lmnopqrstuv'},
      ]);
    },
  );

  test(
    'failed duplicate check never sends an add or uses cached contents',
    () async {
      var edits = 0;
      final client = MockClient((r) async {
        if (r.url.path.endsWith('browse/edit_playlist')) edits++;
        return http.Response('{}', 200);
      });
      addTearDown(client.close);
      final c = container(YoutubeMusicAccount(client, session));
      addTearDown(c.dispose);
      await c.read(youtubeLibraryProvider.future);
      await expectLater(
        c.read(youtubeLibraryProvider.notifier).add('PLmine', [
          const Song(
            id: 'one',
            title: 'Song',
            artist: 'Artist',
            duration: Duration.zero,
            fileType: 'ONLINE',
            remoteId: 'yt:abcdefghijk',
          ),
        ]),
        throwsA(isA<LokalDiscoveryFailure>()),
      );
      expect(edits, 0);
    },
  );
}
