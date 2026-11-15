import 'dart:convert';

import 'package:flick/features/playlist_links/playlist_link_http.dart';
import 'package:flick/features/playlist_links/playlist_link_importers.dart';
import 'package:flick/features/playlist_links/playlist_link_models.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTransport implements PlaylistLinkTransport {
  final Map<String, List<PlaylistLinkHttpResponse>> responses;
  final List<Uri> requests = [];

  FakeTransport(this.responses);

  @override
  Future<PlaylistLinkHttpResponse> request(
    String method,
    Uri url, {
    Map<String, String> headers = const {},
    String? body,
    required int maxBytes,
    required Duration timeout,
    PlaylistLinkCancellationToken? cancellation,
  }) async {
    cancellation?.throwIfCancelled();
    requests.add(url);
    final queue = responses[url.toString()];
    if (queue == null || queue.isEmpty) {
      throw StateError('No fake response for $url');
    }
    return queue.removeAt(0);
  }

  @override
  void close() {}
}

Map<String, dynamic> _ytPage({
  required List<Map<String, Object?>> entries,
  String? continuation,
  String title = 'YT Mix',
}) {
  final contents = entries
      .map(
        (entry) => {
          'musicResponsiveListItemRenderer': {
            'playlistItemData': {'videoId': entry['id']},
            'flexColumns': [
              {
                'musicResponsiveListItemFlexColumnRenderer': {
                  'text': {
                    'runs': [
                      {'text': entry['title']},
                    ],
                  },
                },
              },
              {
                'musicResponsiveListItemFlexColumnRenderer': {
                  'text': {
                    'runs': [
                      {'text': entry['artist']},
                      if (entry['duration'] != null) ...[
                        {'text': ' • '},
                        {'text': entry['duration']},
                      ],
                    ],
                  },
                },
              },
            ],
          },
        },
      )
      .toList();
  final shelf = <String, Object?>{
    'contents': contents,
    if (continuation != null)
      'continuationItemRenderer': {
        'continuationEndpoint': {
          'continuationCommand': {'token': continuation},
        },
      },
  };
  return {
    'contents': {
      'twoColumnBrowseResultsRenderer': {
        'secondaryContents': {'musicPlaylistShelfRenderer': shelf},
        'tabs': [
          {
            'tabRenderer': {
              'content': {
                'sectionListRenderer': {
                  'contents': [
                    {
                      'musicImmersiveHeaderRenderer': {
                        'title': {
                          'runs': [
                            {'text': title},
                          ],
                        },
                      },
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
}

PlaylistLinkHttpResponse _json(Map<String, dynamic> value) =>
    PlaylistLinkHttpResponse(statusCode: 200, body: jsonEncode(value));

void main() {
  test('YouTube importer follows continuations in order', () async {
    final firstUrl = Uri.parse(
      'https://music.youtube.com/youtubei/v1/browse?prettyPrint=false',
    ).toString();
    final transport = FakeTransport({
      firstUrl: [
        _json(
          _ytPage(
            entries: [
              {
                'id': 'video00001',
                'title': 'One',
                'artist': 'A',
                'duration': '3:00',
              },
            ],
            continuation: 'next-token',
          ),
        ),
        _json(
          _ytPage(
            entries: [
              {
                'id': 'video00002',
                'title': 'Two',
                'artist': 'B',
                'duration': '4:00',
              },
            ],
          ),
        ),
      ],
    });
    final importer = YoutubePlaylistImporter(transport);
    final result = await importer.fetch(
      const ParsedPlaylistLink(
        source: PlaylistLinkSource.youtube,
        remoteId: 'PL_abc-12345',
        canonicalUrl: 'https://www.youtube.com/playlist?list=PL_abc-12345',
      ),
    );

    expect(result.complete, isTrue);
    expect(result.entries.map((entry) => entry.title), ['One', 'Two']);
    expect(transport.requests, hasLength(2));
  });

  test(
    'YouTube importer reports truncation instead of pretending complete',
    () async {
      final url = Uri.parse(
        'https://music.youtube.com/youtubei/v1/browse?prettyPrint=false',
      ).toString();
      final pages = <PlaylistLinkHttpResponse>[];
      for (var index = 0; index < YoutubePlaylistImporter.maxPages; index++) {
        pages.add(
          _json(
            _ytPage(
              entries: [
                {
                  'id': 'video${index.toString().padLeft(5, '0')}',
                  'title': 'Track $index',
                  'artist': 'Artist',
                },
              ],
              continuation: 'token-$index',
            ),
          ),
        );
      }
      final result = await YoutubePlaylistImporter(FakeTransport({url: pages}))
          .fetch(
            const ParsedPlaylistLink(
              source: PlaylistLinkSource.youtube,
              remoteId: 'PL_abc-12345',
              canonicalUrl:
                  'https://www.youtube.com/playlist?list=PL_abc-12345',
            ),
          );

      expect(result.complete, isFalse);
      expect(result.truncationReason, contains('cap'));
      expect(result.entries, hasLength(YoutubePlaylistImporter.maxPages));
    },
  );


  test('regular YouTube web playlist imports playlistVideoRenderer and continuation', () async {
    const apiKey = 'AIzaSyFakeValidTestPlaylistKey123';
    final first = {
      'header': {'playlistHeaderRenderer': {'title': {'simpleText': 'Regular Mix'}}},
      'contents': {'playlistVideoListRenderer': {'contents': [
        {'playlistVideoRenderer': {
          'videoId': 'abcdefghijk',
          'title': {'simpleText': 'First'},
          'shortBylineText': {'simpleText': 'Uploader A'},
          'lengthText': {'simpleText': '3:22'},
        }},
        {'continuationItemRenderer': {'continuationEndpoint': {
          'continuationCommand': {'token': 'WEB_NEXT'},
        }}},
      ]}},
    };
    final next = {'onResponseReceivedActions': [
      {'appendContinuationItemsAction': {'continuationItems': [
        {'playlistVideoRenderer': {
          'videoId': 'lmnopqrstuv',
          'title': {'simpleText': 'Second'},
          'shortBylineText': {'simpleText': 'Uploader B'},
        }},
      ]}},
    ]};
    final html = '<script>var ytInitialData = ${jsonEncode(first)};</script>'
        '<script>ytcfg.set({"INNERTUBE_API_KEY":"$apiKey",'
        '"INNERTUBE_CLIENT_VERSION":"2.20261020.00.00"});</script>';
    final webUrl = Uri.https('www.youtube.com', '/playlist', {
      'list': 'PL_abc-12345', 'hl': 'en',
    }).toString();
    final continuationUrl = Uri.https('www.youtube.com', '/youtubei/v1/browse', {
      'key': apiKey, 'prettyPrint': 'false',
    }).toString();
    final transport = FakeTransport({
      webUrl: [PlaylistLinkHttpResponse(statusCode: 200, body: html)],
      continuationUrl: [_json(next)],
    });
    final result = await YoutubePlaylistImporter(transport).fetch(
      const ParsedPlaylistLink(
        source: PlaylistLinkSource.youtube,
        remoteId: 'PL_abc-12345',
        canonicalUrl: 'https://www.youtube.com/playlist?list=PL_abc-12345',
      ),
    );
    expect(result.title, 'Regular Mix');
    expect(result.complete, true);
    expect(result.entries.map((entry) => entry.title), ['First', 'Second']);
    expect(result.entries.map((entry) => entry.remoteId), ['abcdefghijk', 'lmnopqrstuv']);
    expect(result.entries.first.duration, const Duration(minutes: 3, seconds: 22));
    expect(transport.requests.map((request) => request.host),
        ['music.youtube.com', 'www.youtube.com', 'www.youtube.com']);
  });

  test('regular YouTube pagination failures keep a partial listing', () async {
    final first = {'contents': {'playlistVideoListRenderer': {'contents': [
      {'playlistVideoRenderer': {
        'videoId': 'abcdefghijk', 'title': {'simpleText': 'First'},
      }},
      {'continuationItemRenderer': {'continuationEndpoint': {
        'continuationCommand': {'token': 'NEXT'},
      }}},
    ]}}};
    final webUrl = Uri.https('www.youtube.com', '/playlist', {
      'list': 'PL_abc-12345', 'hl': 'en',
    }).toString();
    final transport = FakeTransport({
      webUrl: [PlaylistLinkHttpResponse(
        statusCode: 200,
        body: '<script>var ytInitialData = ${jsonEncode(first)};</script>',
      )],
    });
    final result = await YoutubePlaylistImporter(transport).fetch(
      const ParsedPlaylistLink(
        source: PlaylistLinkSource.youtube,
        remoteId: 'PL_abc-12345',
        canonicalUrl: 'https://www.youtube.com/playlist?list=PL_abc-12345',
      ),
    );
    expect(result.entries.single.title, 'First');
    expect(result.complete, false);
    expect(result.truncationReason, contains('continuation'));
  });

  test('Spotify embed importer is always explicitly partial', () async {
    const id = '0123456789abcdefghijkl';
    final html =
        '''<script id="__NEXT_DATA__" type="application/json">${jsonEncode({
          'props': {
            'pageProps': {
              'entity': {
                'name': 'Public Set',
                'tracks': [
                  {'title': 'Song', 'subtitle': 'Artist'},
                ],
              },
            },
          },
        })}</script>''';
    final url = 'https://open.spotify.com/embed/playlist/$id';
    final result =
        await SpotifyPlaylistImporter(
          FakeTransport({
            url: [PlaylistLinkHttpResponse(statusCode: 200, body: html)],
          }),
        ).fetch(
          const ParsedPlaylistLink(
            source: PlaylistLinkSource.spotify,
            remoteId: id,
            canonicalUrl:
                'https://open.spotify.com/playlist/0123456789abcdefghijkl',
          ),
        );

    expect(result.title, 'Public Set');
    expect(result.complete, isFalse);
    expect(result.truncationReason, contains('partial'));
  });
}
