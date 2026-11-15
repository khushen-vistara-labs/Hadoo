import 'dart:convert';
import 'dart:async';

import 'package:flick/features/discovery/youtube_music_account.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, Object?> signed(Map<String, Object?> body) => {
  'responseContext': {
    'mainAppWebResponseContext': {'loggedOut': false},
  },
  ...body,
};
Map<String, Object?> card(String id, String title) => {
  'musicTwoRowItemRenderer': {
    'title': {
      'runs': [
        {'text': title},
      ],
    },
    'thumbnailOverlay': {
      'musicItemThumbnailOverlayRenderer': {
        'content': {
          'musicPlayButtonRenderer': {
            'playNavigationEndpoint': {
              'watchPlaylistEndpoint': {'playlistId': id},
            },
          },
        },
      },
    },
  },
};
YoutubeMusicAccount account(http.Client client) => YoutubeMusicAccount(
  client,
  const YoutubeMusicSession(cookies: {'SAPISID': 'fixture-signing-cookie'}),
);
void main() {
  test(
    'a slow optional mix route retains cards loaded before the shared deadline',
    () async {
      final blocked = Completer<http.Response>();
      final client = MockClient((request) async {
        if (request.method == 'GET') return http.Response('', 404);
        final body = jsonDecode(request.body) as Map;
        if (body['browseId'] == 'FEslowMore') return blocked.future;
        if (body['browseId'] != 'FEmusic_home')
          return http.Response(jsonEncode(signed({})), 200);
        return http.Response(
          jsonEncode(
            signed({
              'musicCarouselShelfRenderer': {
                'header': {
                  'musicCarouselShelfBasicHeaderRenderer': {
                    'title': {'simpleText': 'Mixed for you'},
                    'moreContentButton': {
                      'buttonRenderer': {
                        'navigationEndpoint': {
                          'browseEndpoint': {'browseId': 'FEslowMore'},
                        },
                      },
                    },
                  },
                },
                'contents': [card('RDTMAKready123', 'Ready mix')],
              },
            }),
          ),
          200,
        );
      });
      addTearDown(client.close);
      final data = await account(client)
          .fetch(budget: const Duration(milliseconds: 150));
      expect(data.mixes.single.id, 'RDTMAKready123');
      expect(data.mixError, isNotNull);
    },
  );

  test(
    'later mix pages survive a large earlier response and grid wrappers',
    () {
      final mixes = parseYoutubeMusicMixes([
        {'unrelated': List.filled(41000, 0)},
        {
          'gridContinuation': {
            'items': [card('RDTMAKlate123', 'Your mix')],
          },
        },
      ]);
      expect(mixes.single.id, 'RDTMAKlate123');
    },
  );

  test(
    'empty personal-mix header does not stop home paging before cards arrive',
    () async {
      var continued = false;
      final client = MockClient((request) async {
        if (request.method == 'GET') return http.Response('', 404);
        final body = jsonDecode(request.body) as Map;
        if (body['browseId'] != 'FEmusic_home')
          return http.Response(jsonEncode(signed({})), 200);
        if (body['continuation'] != null) {
          continued = true;
          return http.Response(
            jsonEncode(
              signed({
                'gridRenderer': {
                  'items': [card('RDTMAKlate123', 'Your mix')],
                },
              }),
            ),
            200,
          );
        }
        return http.Response(
          jsonEncode(
            signed({
              'sectionListRenderer': {
                'contents': [
                  {
                    'musicCarouselShelfRenderer': {
                      'header': {
                        'musicCarouselShelfBasicHeaderRenderer': {
                          'title': {'simpleText': 'Mixed for you'},
                        },
                      },
                      'contents': [],
                    },
                  },
                ],
                'continuations': [
                  {
                    'nextContinuationData': {'continuation': 'next-home'},
                  },
                ],
              },
            }),
          ),
          200,
        );
      });
      addTearDown(client.close);
      final data = await account(client).fetch();
      expect(continued, isTrue);
      expect(data.mixes.single.id, 'RDTMAKlate123');
    },
  );

  test(
    'populated first mix shelf does not hide mixes on later home pages',
    () async {
      var continued = false;
      final client = MockClient((request) async {
        if (request.method == 'GET') return http.Response('', 404);
        final body = jsonDecode(request.body) as Map;
        if (body['browseId'] != 'FEmusic_home') {
          return http.Response(jsonEncode(signed({})), 200);
        }
        if (body['continuation'] != null) {
          continued = true;
          return http.Response(
            jsonEncode(signed({
              'gridRenderer': {
                'items': [card('RDTMAKsecond456', 'Second mix')],
              },
            })),
            200,
          );
        }
        return http.Response(
          jsonEncode(signed({
            'sectionListRenderer': {
              'contents': [
                {
                  'musicCarouselShelfRenderer': {
                    'header': {
                      'musicCarouselShelfBasicHeaderRenderer': {
                        'title': {'simpleText': 'Mixed for you'},
                      },
                    },
                    'contents': [card('RDTMAKfirst123', 'First mix')],
                  },
                },
              ],
              'continuations': [
                {
                  'nextContinuationData': {'continuation': 'more-mixes'},
                },
              ],
            },
          })),
          200,
        );
      });
      addTearDown(client.close);
      final data = await account(client).fetch();
      expect(continued, isTrue);
      expect(data.mixes.map((mix) => mix.id),
          containsAll(['RDTMAKfirst123', 'RDTMAKsecond456']));
    },
  );

  test(
    'provider personal mix chip supplies its real browse route and params',
    () async {
      final client = MockClient((request) async {
        if (request.method == 'GET') return http.Response('', 404);
        final body = jsonDecode(request.body) as Map;
        Object data = signed({});
        if (body['browseId'] == 'FEmusic_home')
          data = signed({
            'chipCloudChipRenderer': {
              'text': {'simpleText': 'Mixed for you'},
              'navigationEndpoint': {
                'browseEndpoint': {
                  'browseId': 'FEprovidedMixes',
                  'params': 'profile-mix-filter',
                },
              },
            },
          });
        if (body['browseId'] == 'FEprovidedMixes') {
          expect(body['params'], 'profile-mix-filter');
          data = signed({
            'gridRenderer': {
              'items': [card('RDTMAKchip123', 'Your mix')],
            },
          });
        }
        return http.Response(jsonEncode(data), 200);
      });
      addTearDown(client.close);
      expect((await account(client).fetch()).mixes.single.id, 'RDTMAKchip123');
    },
  );

  // Native title links and dimensionless artwork from desktop's youtube-mixes fixtures.
  test('desktop native mix cards keep artwork and full browser context through home pagination', () async {
    final tokens = <String>[];
    Map<String, Object?> nativeCard(int index) => {
      'musicTwoRowItemRenderer': {
        'title': {
          'runs': [
            {
              'text': 'My Mix $index',
              'navigationEndpoint': {
                'browseEndpoint': {
                  'browseId': 'VLRDTMAKdesktop$index',
                  'browseEndpointContextSupportedConfigs': {
                    'browseEndpointContextMusicConfig': {
                      'pageType': 'MUSIC_PAGE_TYPE_PLAYLIST',
                    },
                  },
                },
              },
            },
          ],
        },
        'navigationEndpoint': {
          'watchEndpoint': {
            'playlistId': 'RDTMAKdesktop$index',
            'videoId': 'abcdefghijk',
          },
        },
        'thumbnailRenderer': {
          'musicThumbnailRenderer': {
            'thumbnail': {
              'thumbnails': [
                {'url': 'https://images.example/mix$index=w226-h226-l90-rj'},
              ],
            },
          },
        },
      },
    };
    Map<String, Object?> section(List<Object?> contents, [String? next]) =>
        signed({
          'sectionListRenderer': {
            'contents': contents,
            if (next != null)
              'continuations': [
                {
                  'nextContinuationData': {'continuation': next},
                },
              ],
          },
        });
    final client = MockClient((request) async {
      expect(request.headers['user-agent'], isNot(contains('Android WebView')));
      if (request.method == 'GET')
        return http.Response(
          'ytcfg.set({"INNERTUBE_CLIENT_VERSION":"desktop-current","INNERTUBE_CONTEXT":{"client":{"platform":"DESKTOP","clientFormFactor":"UNKNOWN_FORM_FACTOR","hl":"zh-CN"}}});',
          200,
        );
      final body = jsonDecode(request.body) as Map;
      expect(body['context']['client']['platform'], 'DESKTOP');
      expect(
        body['context']['client']['clientFormFactor'],
        'UNKNOWN_FORM_FACTOR',
      );
      expect(body['context']['client']['hl'], 'en');
      final token = body['continuation'];
      if (token != null) {
        tokens.add(token as String);
        final page = int.parse(token.toString().split('-').last);
        if (page < 11)
          return http.Response(
            jsonEncode(section([], 'home-${page + 1}')),
            200,
          );
        return http.Response(
          jsonEncode(
            section([
              {
                'musicCarouselShelfRenderer': {
                  'header': {
                    'musicCarouselShelfBasicHeaderRenderer': {
                      'title': {
                        'runs': [
                          {'text': 'Mixed for you'},
                        ],
                      },
                    },
                  },
                  'contents': List.generate(19, nativeCard),
                },
              },
            ]),
          ),
          200,
        );
      }
      if (body['browseId'] == 'FEmusic_home')
        return http.Response(
          jsonEncode(
            section([
              {
                'musicCarouselShelfRenderer': {
                  'contents': [],
                  'continuations': [
                    {
                      'nextContinuationData': {
                        'continuation': 'unrelated-shelf',
                      },
                    },
                  ],
                },
              },
            ], 'home-1'),
          ),
          200,
        );
      return http.Response(jsonEncode(signed({})), 200);
    });
    addTearDown(client.close);
    final result = await account(client).fetch();
    expect(result.mixes.length, 19);
    expect(
      result.mixes.first.artworkUrl,
      'https://images.example/mix0=w544-h544-l90-rj',
    );
    expect(result.mixes.every((mix) => mix.artworkUrl.isNotEmpty), isTrue);
    expect(tokens, List.generate(11, (index) => 'home-${index + 1}'));
    expect(result.mixError, isNull);
  });

  test('refresh reads current page context and mixes embedded in the signed-in home page', () async {
    forgetYoutubeMusicAccount();
    addTearDown(forgetYoutubeMusicAccount);
    var revision = 1, pageReads = 0;
    final client = MockClient((request) async {
      if (request.method == 'GET') {
        pageReads++;
        final initial = signed({
          'musicCarouselShelfRenderer': {
            'header': {
              'musicCarouselShelfBasicHeaderRenderer': {
                'title': {
                  'runs': [
                    {'text': 'Mixed for you'},
                  ],
                },
              },
            },
            'contents': [card('RDTMAKfixture123', 'Mix $revision { \" }')],
          },
        });
        return http.Response(
          '<script>ytcfg.set(${jsonEncode({'INNERTUBE_CLIENT_VERSION': '1.current', 'VISITOR_DATA': 'fresh-visitor'})}); var ytInitialData = ${jsonEncode(initial)};</script>',
          200,
        );
      }
      final body = jsonDecode(request.body) as Map;
      expect((body['context'] as Map)['client']['clientVersion'], '1.current');
      expect(request.headers['x-youtube-client-version'], '1.current');
      return http.Response(jsonEncode(signed({})), 200);
    });
    addTearDown(client.close);
    final source = account(client);
    final first = await loadYoutubeMusicDiscovery(source);
    expect(first.mixes!.single.title, startsWith('Mix 1'));
    revision = 2;
    final refreshed = await loadYoutubeMusicDiscovery(source, force: true);
    expect(refreshed.mixes!.single.title, startsWith('Mix 2'));
    expect(pageReads, 2);
  });

  test(
    'mix cards can expose their playlist only on the artwork play button',
    () {
      final parsed = parseYoutubeMusicMixes({
        'musicCarouselShelfRenderer': {
          'header': {
            'musicCarouselShelfBasicHeaderRenderer': {
              'title': {
                'runs': [
                  {'text': 'Mixed for you'},
                ],
              },
            },
          },
          'contents': [card('RDTMAKfixture123', 'Supermix')],
        },
      });
      expect(parsed.single.id, 'RDTMAKfixture123');
    },
  );
  test(
    'an empty mix shelf loads its own chained continuation without a header',
    () async {
      final tokens = <String>[];
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map;
        final continuation = body['continuation'];
        if (continuation != null) {
          tokens.add(continuation as String);
          if (continuation == 'first')
            return http.Response(
              jsonEncode(
                signed({
                  'continuationContents': {
                    'musicCarouselShelfContinuation': {
                      'contents': [card('RDTMAKfixture123', 'Supermix')],
                      'continuations': [
                        {
                          'nextContinuationData': {'continuation': 'second'},
                        },
                      ],
                    },
                  },
                }),
              ),
              200,
            );
          return http.Response(
            jsonEncode(
              signed({
                'onResponseReceivedActions': [
                  {
                    'appendContinuationItemsAction': {
                      'continuationItems': [
                        card('RDTMAKfixture456', 'My Mix 1'),
                      ],
                    },
                  },
                ],
              }),
            ),
            200,
          );
        }
        if (body['browseId'] == 'FEmusic_home')
          return http.Response(
            jsonEncode(
              signed({
                'musicCarouselShelfRenderer': {
                  'header': {
                    'musicCarouselShelfBasicHeaderRenderer': {
                      'title': {
                        'runs': [
                          {'text': 'Mixed for you'},
                        ],
                      },
                    },
                  },
                  'contents': [
                    {
                      'continuationItemRenderer': {
                        'continuationEndpoint': {
                          'commandExecutorCommand': {
                            'commands': [
                              {
                                'continuationCommand': {'token': 'first'},
                              },
                            ],
                          },
                        },
                      },
                    },
                  ],
                },
              }),
            ),
            200,
          );
        return http.Response(jsonEncode(signed({})), 200);
      });
      addTearDown(client.close);
      final result = await account(client).fetch();
      expect(result.mixes.map((m) => m.title), ['Supermix', 'My Mix 1']);
      expect(tokens, ['first', 'second']);
      expect(result.mixError, isNull);
    },
  );
  test(
    'More shelf continuation retains the personal mix browse parameters',
    () async {
      var continued = false;
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map;
        if (body['browseId'] == 'FEmusic_home')
          return http.Response(
            jsonEncode(
              signed({
                'musicCarouselShelfRenderer': {
                  'header': {
                    'musicCarouselShelfBasicHeaderRenderer': {
                      'title': {
                        'runs': [
                          {'text': 'Mixed for you'},
                        ],
                      },
                      'moreContentButton': {
                        'buttonRenderer': {
                          'navigationEndpoint': {
                            'browseEndpoint': {
                              'browseId': 'FEpersonal_mixes',
                              'params': 'personal-filter',
                            },
                          },
                        },
                      },
                    },
                  },
                  'contents': [],
                },
              }),
            ),
            200,
          );
        if (body['browseId'] == 'FEpersonal_mixes') {
          expect(body['params'], 'personal-filter');
          if (body['continuation'] == 'more') {
            continued = true;
            return http.Response(
              jsonEncode(
                signed({
                  'gridContinuation': {
                    'items': [card('PLpersonal123', 'Personal mix')],
                  },
                }),
              ),
              200,
            );
          }
          return http.Response(
            jsonEncode(
              signed({
                'gridRenderer': {
                  'continuations': [
                    {
                      'nextContinuationData': {'continuation': 'more'},
                    },
                  ],
                },
              }),
            ),
            200,
          );
        }
        return http.Response(jsonEncode(signed({})), 200);
      });
      addTearDown(client.close);
      final result = await account(client).fetch();
      expect(continued, isTrue);
      expect(result.mixes.single.id, 'PLpersonal123');
    },
  );
}
