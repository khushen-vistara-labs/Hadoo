import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flick/features/discovery/lastfm_discovery.dart';
import 'package:flick/features/discovery/youtube_music_account.dart';
import 'package:flick/features/discovery/youtube_music_playlist_writes.dart';

const session = YoutubeMusicSession(cookies: {'SAPISID': 'fake-test-cookie'});

void main() {
  test(
    'suggested songs are never treated as playlist contents or paged',
    () async {
      var requests = 0;
      final client = MockClient((_) async {
        requests++;
        return http.Response(
          jsonEncode({
            'musicShelfRenderer': {
              'title': {
                'runs': [
                  {'text': 'You might also like'},
                ],
              },
              'contents': [
                {
                  'musicResponsiveListItemRenderer': {
                    'playlistItemData': {'videoId': 'abcdefghijk'},
                    'flexColumns': [
                      {
                        'musicResponsiveListItemFlexColumnRenderer': {
                          'text': {
                            'runs': [
                              {'text': 'Suggested song'},
                            ],
                          },
                        },
                      },
                    ],
                  },
                },
              ],
              'continuations': [
                {
                  'nextContinuationData': {'continuation': 'suggestions-page'},
                },
              ],
            },
            'musicPlaylistShelfRenderer': {'contents': []},
          }),
          200,
        );
      });
      addTearDown(client.close);
      final details = await YoutubeMusicAccount(
        client,
        session,
      ).libraryPlaylistDetails('PLempty');
      expect(details.tracks, isEmpty);
      expect(requests, 1);
    },
  );
  test(
    'create is private on YouTube and requires a confirmed remote ID',
    () async {
      final requests = <Map<String, dynamic>>[];
      final client = MockClient((request) async {
        expect(request.url.host, 'music.youtube.com');
        expect(request.url.path, '/youtubei/v1/playlist/create');
        expect(request.headers['Authorization'], isNotEmpty);
        requests.add(jsonDecode(request.body));
        return http.Response(jsonEncode({'playlistId': 'PLremote123'}), 200);
      });
      addTearDown(client.close);
      final writes = YoutubeMusicPlaylistWrites(
        YoutubeMusicAccount(client, session),
      );
      expect(
        await writes.create('  My playlist  ', tracks: ['abcdefghijk']),
        'PLremote123',
      );
      expect(requests.single['title'], 'My playlist');
      expect(requests.single['privacyStatus'], 'PRIVATE');
      expect(requests.single['videoIds'], ['abcdefghijk']);
      for (final title in ['', '<bad>', 'x' * 151]) {
        await expectLater(
          writes.create(title),
          throwsA(isA<LokalDiscoveryFailure>()),
        );
      }
      expect(requests.length, 1);
    },
  );

  test(
    'edit actions preserve recording IDs and remove one duplicate occurrence',
    () async {
      final requests = <Map<String, dynamic>>[];
      final client = MockClient((request) async {
        requests.add(jsonDecode(request.body));
        return http.Response('{"status":"STATUS_SUCCEEDED"}', 200);
      });
      addTearDown(client.close);
      final writes = YoutubeMusicPlaylistWrites(
        YoutubeMusicAccount(client, session),
      );
      await writes.add('PLtest', ['abcdefghijk', 'abcdefghijk']);
      expect(requests.last['actions'], [
        {'action': 'ACTION_ADD_VIDEO', 'addedVideoId': 'abcdefghijk'},
      ]);
      await writes.remove(
        'PLtest',
        const LokalDiscoveryTrack(
          title: 'Song',
          artist: 'Artist',
          videoId: 'abcdefghijk',
          setVideoId: 'second-occurrence',
        ),
      );
      expect(requests.last['actions'], [
        {
          'action': 'ACTION_REMOVE_VIDEO',
          'removedVideoId': 'abcdefghijk',
          'setVideoId': 'second-occurrence',
        },
      ]);
      await writes.rename('PLtest', 'Renamed');
      expect(requests.last['actions'], [
        {'action': 'ACTION_SET_PLAYLIST_NAME', 'playlistName': 'Renamed'},
      ]);
      await writes.delete('PLtest');
      expect(requests.last['playlistId'], 'PLtest');
    },
  );

  test(
    'HTTP 200 rejection and missing acknowledgements never count as success',
    () async {
      for (final body in [
        '{}',
        '{"status":"STATUS_FAILED"}',
        '{"error":{"code":400}}',
      ]) {
        final client = MockClient((_) async => http.Response(body, 200));
        final writes = YoutubeMusicPlaylistWrites(
          YoutubeMusicAccount(client, session),
        );
        await expectLater(
          writes.create('Test'),
          throwsA(isA<LokalDiscoveryFailure>()),
        );
        await expectLater(
          writes.add('PLtest', ['abcdefghijk']),
          throwsA(isA<LokalDiscoveryFailure>()),
        );
        client.close();
      }
    },
  );

  test(
    'editing a read-only playlist does not invalidate a valid sign-in',
    () async {
      final client = MockClient((_) async => http.Response('{}', 403));
      addTearDown(client.close);
      final account = YoutubeMusicAccount(client, session);
      await expectLater(
        YoutubeMusicPlaylistWrites(account).add('PLtest', ['abcdefghijk']),
        throwsA(
          isA<LokalDiscoveryFailure>().having(
            (e) => e.message,
            'permission message',
            contains('own or collaborate'),
          ),
        ),
      );
      expect(account.session.signedIn, true);
    },
  );

  test(
    'playlist parsing keeps set IDs and duplicate recording occurrences',
    () async {
      Map<String, Object?> row(String setId) => {
        'musicResponsiveListItemRenderer': {
          'playlistItemData': {'videoId': 'abcdefghijk'},
          'flexColumns': [
            {
              'musicResponsiveListItemFlexColumnRenderer': {
                'text': {
                  'runs': [
                    {'text': 'Song'},
                  ],
                },
              },
            },
          ],
          'menu': {
            'items': [
              {
                'menuServiceItemRenderer': {
                  'serviceEndpoint': {
                    'playlistEditEndpoint': {
                      'actions': [
                        {
                          'action': 'ACTION_REMOVE_VIDEO',
                          'setVideoId': setId,
                          'removedVideoId': 'abcdefghijk',
                        },
                      ],
                    },
                  },
                },
              },
            ],
          },
        },
      };
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'header': {'musicEditablePlaylistDetailHeaderRenderer': {}},
            'musicPlaylistShelfRenderer': {
              'contents': [row('one'), row('two')],
            },
          }),
          200,
        ),
      );
      addTearDown(client.close);
      final details = await YoutubeMusicAccount(
        client,
        session,
      ).libraryPlaylistDetails('PLtest');
      expect(details.editable, true);
      expect(details.tracks.map((t) => t.videoId), [
        'abcdefghijk',
        'abcdefghijk',
      ]);
      expect(details.tracks.map((t) => t.setVideoId), ['one', 'two']);
    },
  );
}
