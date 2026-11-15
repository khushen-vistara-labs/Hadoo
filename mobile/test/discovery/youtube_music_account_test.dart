import 'dart:convert';

import 'package:flick/features/discovery/youtube_music_account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('YoutubeMusicSession', () {
    test('round-trips cookies and Innertube page context', () {
      const session = YoutubeMusicSession(
        cookies: {'SAPISID': 'secret-cookie', 'SID': 'identity-cookie'},
        sessionIndex: '2',
        delegatedSessionId: 'delegated',
        visitorData: 'visitor',
        clientVersion: '1.2.3',
      );

      final decoded = YoutubeMusicSession.fromJson(
        jsonDecode(jsonEncode(session.toJson())),
      );

      expect(decoded?.signedIn, isTrue);
      expect(decoded?.cookies, session.cookies);
      expect(decoded?.sessionIndex, '2');
      expect(decoded?.delegatedSessionId, 'delegated');
      expect(decoded?.visitorData, 'visitor');
      expect(decoded?.clientVersion, '1.2.3');
    });

    test('parses a Cookie header without splitting values at extra equals', () {
      expect(YoutubeMusicSession.parseCookieHeader('SID=one; SAPISID=a=b=c'), {
        'SID': 'one',
        'SAPISID': 'a=b=c',
      });
    });

    test('signs the account request for a fixed timestamp', () {
      const session = YoutubeMusicSession(cookies: {'SAPISID': 'test-sapisid'});
      final headers = youtubeMusicHeaders(
        session,
        now: DateTime.fromMillisecondsSinceEpoch(1735689600000),
      );

      expect(
        headers?['Authorization'],
        'SAPISIDHASH 1735689600_5fdedf5901c66032a6fb19716048f68d712f8f74',
      );
      expect(headers?['Cookie'], 'SAPISID=test-sapisid');
      expect(headers?['X-YouTube-Client-Name'], '67');
    });

    test('does not make authenticated headers without a signing cookie', () {
      const session = YoutubeMusicSession(cookies: {'SID': 'not-sapisid'});
      expect(youtubeMusicHeaders(session), isNull);
      expect(session.signedIn, isFalse);
    });
  });

  test('detects YouTube Music responses that report a logged-out session', () {
    expect(
      youtubeMusicLoggedOut({
        'responseContext': {
          'mainAppWebResponseContext': {'loggedOut': true},
        },
      }),
      isTrue,
    );
    expect(
      youtubeMusicLoggedOut({
        'responseContext': {
          'mainAppWebResponseContext': {'loggedOut': false},
          'serviceTrackingParams': [
            {
              'params': [
                {'key': 'logged_in', 'value': '1'},
              ],
            },
          ],
        },
      }),
      isFalse,
    );
  });

  test(
    'parses an account song row with video ID, artist, album and length',
    () {
      final root = {
        'musicResponsiveListItemRenderer': {
          'playlistItemData': {'videoId': 'abcdefghijk'},
          'flexColumns': [
            {
              'musicResponsiveListItemFlexColumnRenderer': {
                'text': {
                  'runs': [
                    {
                      'text': 'Track One',
                      'navigationEndpoint': {
                        'watchEndpoint': {'videoId': 'abcdefghijk'},
                      },
                    },
                  ],
                },
              },
            },
            {
              'musicResponsiveListItemFlexColumnRenderer': {
                'text': {
                  'runs': [
                    {
                      'text': 'Artist One',
                      'navigationEndpoint': {
                        'browseEndpoint': {'browseId': 'UCartist'},
                      },
                    },
                    {'text': ' • '},
                    {
                      'text': 'Album One',
                      'navigationEndpoint': {
                        'browseEndpoint': {'browseId': 'MPREalbum'},
                      },
                    },
                  ],
                },
              },
            },
          ],
          'fixedColumns': [
            {
              'musicResponsiveListItemFixedColumnRenderer': {
                'text': {
                  'runs': [
                    {'text': '3:21'},
                  ],
                },
              },
            },
          ],
          'thumbnail': {
            'thumbnails': [
              {
                'url': 'https://img.example/cover=w120-h120-l90-rj',
                'width': 120,
                'height': 120,
              },
            ],
          },
        },
      };

      final tracks = parseYoutubeMusicTracks(root);

      expect(tracks, hasLength(1));
      expect(tracks.single.title, 'Track One');
      expect(tracks.single.artist, 'Artist One');
      expect(tracks.single.album, 'Album One');
      expect(tracks.single.videoId, 'abcdefghijk');
      expect(tracks.single.duration, const Duration(minutes: 3, seconds: 21));
      expect(
        tracks.single.url,
        'https://music.youtube.com/watch?v=abcdefghijk',
      );
      expect(tracks.single.artworkUrl, contains('w544-h544'));
    },
  );

  test(
    'recognizes localized mixed-for-you shelves and responsive playlist cards',
    () {
      final root = {
        'musicCarouselShelfRenderer': {
          'header': {
            'musicCarouselShelfBasicHeaderRenderer': {
              'title': {'simpleText': 'Mix pour vous'},
            },
          },
          'contents': [
            {
              'musicResponsiveListItemRenderer': {
                'playlistId': 'PL123456789',
                'flexColumns': [
                  {
                    'musicResponsiveListItemFlexColumnRenderer': {
                      'text': {
                        'runs': [
                          {'text': 'Supermix'},
                        ],
                      },
                    },
                  },
                ],
              },
            },
          ],
        },
      };
      final mixes = parseYoutubeMusicMixes(root);
      expect(mixes.single.title, 'Supermix');
      expect(mixes.single.id, 'PL123456789');
    },
  );

  test('parses provider-owned mixes from the Mixed for you shelf', () {
    final root = {
      'musicCarouselShelfRenderer': {
        'header': {
          'musicCarouselShelfBasicHeaderRenderer': {
            'title': {'simpleText': 'Mixed for you'},
          },
        },
        'contents': [
          {
            'musicTwoRowItemRenderer': {
              'playlistId': 'RDTMAKABCDE123456',
              'title': {
                'runs': [
                  {'text': 'My Supermix'},
                ],
              },
              'thumbnailRenderer': {
                'musicThumbnailRenderer': {
                  'thumbnail': {
                    'thumbnails': [
                      {
                        'url': 'https://img.example/mix=w120-h120-l90-rj',
                        'width': 120,
                        'height': 120,
                      },
                    ],
                  },
                },
              },
            },
          },
        ],
      },
    };

    final mixes = parseYoutubeMusicMixes(root);

    expect(mixes, hasLength(1));
    expect(mixes.single.id, 'RDTMAKABCDE123456');
    expect(mixes.single.title, 'My Supermix');
    expect(mixes.single.artworkUrl, contains('w544-h544'));
  });
}
