import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flick/features/discovery/discovery_http.dart';
import 'package:flick/features/discovery/discovery_models.dart';
import 'package:flick/features/discovery/discovery_sources.dart';
import 'package:flick/features/hadoo/youtube_public_playlist_provider.dart';

Map<String, Object?> track(String id) => {
  'musicResponsiveListItemRenderer': {
    'playlistItemData': {'videoId': id},
    'flexColumns': [
      {
        'musicResponsiveListItemFlexColumnRenderer': {
          'text': {
            'runs': [
              {'text': 'Recording $id'},
            ],
          },
        },
      },
    ],
  },
};

void main() {
  test(
    'playlist filter parses playlists without mistaking recordings for lists',
    () async {
      final client = MockClient((r) async {
        final body = jsonDecode(r.body) as Map;
        expect(body['params'], YoutubeMusicCatalog.playlistsFilter);
        expect(
          r.headers.keys.map((s) => s.toLowerCase()),
          isNot(contains('cookie')),
        );
        return http.Response(
          jsonEncode({
            'contents': {
              'musicShelfRenderer': {
                'contents': [
                  {
                    'musicResponsiveListItemRenderer': {
                      'navigationEndpoint': {
                        'browseEndpoint': {
                          'browseId': 'VLPLexample',
                          'browseEndpointContextSupportedConfigs': {
                            'browseEndpointContextMusicConfig': {
                              'pageType': 'MUSIC_PAGE_TYPE_PLAYLIST',
                            },
                          },
                        },
                      },
                      'flexColumns': [
                        {
                          'musicResponsiveListItemFlexColumnRenderer': {
                            'text': {
                              'runs': [
                                {'text': 'Road trip'},
                              ],
                            },
                          },
                        },
                        {
                          'musicResponsiveListItemFlexColumnRenderer': {
                            'text': {
                              'runs': [
                                {'text': 'A listener'},
                              ],
                            },
                          },
                        },
                      ],
                    },
                  },
                  track('abcdefghijk'),
                ],
              },
            },
          }),
          200,
        );
      });
      addTearDown(client.close);
      final results = await YoutubeMusicCatalog(DiscoveryHttp(client))
          .searchPlaylists('road trip');
      expect(results.single.id, 'PLexample');
      expect(results.single.title, 'Road trip');
      expect(results.single.author, 'A listener');
    },
  );

  test(
    'video filter preserves a video type through artwork and quality copies',
    () async {
      final client = MockClient((r) async {
        expect(
          (jsonDecode(r.body) as Map)['params'],
          YoutubeMusicCatalog.videosFilter,
        );
        return http.Response(
          jsonEncode({
            'contents': {
              'musicShelfRenderer': {
                'contents': [track('abcdefghijk')],
              },
            },
          }),
          200,
        );
      });
      addTearDown(client.close);
      final result = (await YoutubeMusicCatalog(
        DiscoveryHttp(client),
      ).searchVideos('song')).single;
      expect(result.kind, DiscoveryTrackKind.video);
      expect(
        result.withArtwork('https://example.org/cover.jpg').kind,
        DiscoveryTrackKind.video,
      );
      expect(result.requestAtmos().kind, DiscoveryTrackKind.video);
    },
  );

  test('public playlist browsing needs no account and follows only its own continuation', () async {
    var calls = 0;
    final client = MockClient((r) async {
      calls++;
      expect(
        r.headers.keys.map((s) => s.toLowerCase()),
        isNot(contains('authorization')),
      );
      final body = jsonDecode(r.body) as Map;
      if (calls == 1) {
        return http.Response(
          jsonEncode({
            'musicPlaylistShelfRenderer': {
              'contents': [track('abcdefghijk')],
              'continuations': [
                {
                  'nextContinuationData': {'continuation': 'playlist-page'},
                },
              ],
            },
            'musicShelfRenderer': {
              'contents': [track('zzzzzzzzzzz')],
              'continuations': [
                {
                  'nextContinuationData': {'continuation': 'suggestions'},
                },
              ],
            },
          }),
          200,
        );
      }
      expect(body['continuation'], 'playlist-page');
      expect(r.url.queryParameters['continuation'], 'playlist-page');
      return http.Response(
        jsonEncode({
          'musicPlaylistShelfContinuation': {
            'contents': [track('lmnopqrstuv')],
          },
        }),
        200,
      );
    });
    addTearDown(client.close);
    final reader = PublicYoutubePlaylistReader(
      YoutubeMusicCatalog(DiscoveryHttp(client)),
    );
    final result = await reader.libraryPlaylistDetails('PLexample');
    expect(result.tracks.map((t) => t.videoId), ['abcdefghijk', 'lmnopqrstuv']);
    expect(calls, 2);
  });
}
