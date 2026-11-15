import 'dart:convert';

import 'package:flick/features/discovery/discovery_http.dart';
import 'package:flick/features/discovery/discovery_models.dart';
import 'package:flick/features/discovery/discovery_settings.dart';
import 'package:flick/features/discovery/lastfm_discovery.dart';
import 'package:flick/features/konnekted/konnekted_discovery.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flick/providers/opt_in_source_provider.dart';

class _MemorySettings extends DiscoverySettingsStore {
  _MemorySettings(this.settings);

  final DiscoverySettings settings;

  @override
  Future<DiscoverySettings> load() async => settings;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Monochrome is opt-in and remains a native source when enabled',
    () async {
      final client = MockClient(
        (_) async => fail('Listing sources must not contact a service'),
      );
      addTearDown(client.close);
      final store = _MemorySettings(const DiscoverySettings());
      final disabled = await onlineSources(client, store: store);
      expect(disabled.where((source) => source.id == 'mono'), isEmpty);
      await (await SharedPreferences.getInstance()).setBool(
        monochromeEnabledPreferenceKey,
        true,
      );
      final enabled = await onlineSources(client, store: store);
      expect(
        enabled.singleWhere((source) => source.id == 'mono').name,
        'Monochrome',
      );
      expect(
        enabled.singleWhere((source) => source.id == 'mono').addon,
        isFalse,
      );
      expect(enabled.singleWhere((source) => source.id == 'yt').addon, isFalse);
    },
  );

  for (final (enabled, available) in [
    (false, false),
    (true, false),
    (true, true),
  ]) {
    test(
      'YouTube fallback with source enabled=$enabled and readable=$available',
      () async {
        SharedPreferences.setMockInitialValues({
          monochromeEnabledPreferenceKey: enabled,
        });
        final requestedStreams = <String>[];
        final client = MockClient((request) async {
          final url = request.url;
          if (url.host == 'tracks.monochrome.st') {
            expect(enabled, isTrue);
            if (url.path == '/search/tracks') {
              return http.Response(
                jsonEncode({
                  'tracks': [
                    {
                      'trackId': '160449588548300801',
                      'title': 'O Maahi (Cover)',
                      'artistNames': ['Arijit Singh'],
                      'duration': 233535,
                    },
                    {
                      'trackId': '160449588548300802',
                      'title': 'O Maahi',
                      'artistNames': ['Arijit Singh'],
                      'duration': 100000,
                    },
                    {
                      'trackId': '160449588548300803',
                      'title': 'O Maahi',
                      'artistNames': ['Arijit Singh'],
                      'duration': 233535,
                    },
                    {
                      'trackId': '160449588548300800',
                      'title': 'O Maahi (From "Dunki")',
                      'artistNames': ['Pritam', 'Arijit Singh', 'Irshad Kamil'],
                      'duration': 233535,
                    },
                  ],
                }),
                200,
              );
            }
            requestedStreams.add(url.path);
            return available && url.path.endsWith("800")
                ? http.Response(
                    'fLaC',
                    206,
                    headers: {'content-type': 'application/octet-stream'},
                  )
                : http.Response('Forbidden', 403);
          }
          return request.method == 'POST'
              ? http.Response(
                  jsonEncode({
                    'playabilityStatus': {
                      'status': 'UNPLAYABLE',
                      'reason': 'Unavailable',
                    },
                  }),
                  200,
                )
              : http.Response('', 404);
        });
        addTearDown(client.close);
        final playback = playOnlineTrack(
          'yt',
          const DiscoveryTrack(
            id: 'abcdefghijk',
            title: 'O Maahi',
            artist: 'Arijit Singh',
            duration: Duration(seconds: 234),
            source: DiscoverySource.youtubeMusic,
          ),
          client: client,
        );
        if (available) {
          final song = await playback;
          expect(song.sourceDisplayName, 'Monochrome');
          expect(song.remoteId, 'yt:abcdefghijk');
          expect(song.filePath, startsWith('lokal-progressive://'));
        } else {
          await expectLater(playback, throwsA(isA<DiscoveryException>()));
        }
        expect(
          requestedStreams,
          enabled
              ? ['/track/160449588548300803', '/track/160449588548300800']
              : [],
        );
      },
    );
  }

  test(
    'a YouTube playlist row recovers duration by its exact video ID',
    () async {
      SharedPreferences.setMockInitialValues({
        monochromeEnabledPreferenceKey: true,
      });
      final requestedStreams = <String>[];
      var lookups = 0;
      final client = MockClient((request) async {
        if (request.url.path == '/youtubei/v1/search') {
          lookups++;
          return http.Response(
            jsonEncode({
              'contents': {
                'musicShelfRenderer': {
                  'contents': [
                    for (final (id, duration) in [
                      ('wrongvideo1', '3:15'),
                      ('vyJTAnlRHVc', '3:47'),
                    ])
                      {
                        'musicResponsiveListItemRenderer': {
                          'playlistItemData': {'videoId': id},
                          'flexColumns': [
                            for (final texts in [
                              ['Nazm Nazm'],
                              ['Arko', duration],
                            ])
                              {
                                'musicResponsiveListItemFlexColumnRenderer': {
                                  'text': {
                                    'runs': [
                                      for (final text in texts) {'text': text},
                                    ],
                                  },
                                },
                              },
                          ],
                        },
                      },
                  ],
                },
              },
            }),
            200,
          );
        }
        if (request.url.host == 'tracks.monochrome.st') {
          if (request.url.path == '/search/tracks') {
            return http.Response(
              jsonEncode({
                'tracks': [
                  {
                    'trackId': '163267787043643393',
                    'title': 'Nazm Nazm',
                    'artistNames': ['Arko'],
                    'duration': 195000,
                  },
                  {
                    'trackId': '163267787043643392',
                    'title': 'Nazm Nazm',
                    'artistNames': ['Arko'],
                    'duration': 226998,
                  },
                ],
              }),
              200,
            );
          }
          requestedStreams.add(request.url.path);
          return http.Response('fLaC', 206);
        }
        return request.method == 'POST'
            ? http.Response(
                jsonEncode({
                  'playabilityStatus': {
                    'status': 'UNPLAYABLE',
                    'reason': 'Unavailable',
                  },
                }),
                200,
              )
            : http.Response('', 404);
      });
      addTearDown(client.close);
      final song = await findDiscoverySong(
        const LokalDiscoveryTrack(
          videoId: 'vyJTAnlRHVc',
          title: 'Nazm Nazm',
          artist: 'Arko',
          album: 'Bareilly Ki Barfi',
        ),
        store: _MemorySettings(const DiscoverySettings()),
        client: client,
      );
      expect(song?.sourceDisplayName, 'Monochrome');
      expect(song?.remoteId, 'yt:vyJTAnlRHVc');
      expect(lookups, 1);
      expect(requestedStreams, ['/track/163267787043643392']);
    },
  );

  test(
    'SoundCloud is optional and disabling it removes queued access',
    () async {
      final client = MockClient(
        (_) async => fail('Disabled sources cannot contact a service'),
      );
      addTearDown(client.close);
      final store = _MemorySettings(const DiscoverySettings());
      expect(
        (await onlineSources(client, store: store)).where((s) => s.id == 'sc'),
        isEmpty,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(soundCloudEnabledPreferenceKey, true);
      final source = (await onlineSources(
        client,
        store: store,
      )).singleWhere((s) => s.id == 'sc');
      expect(source.name, 'SoundCloud');
      expect(source.addon, false);
      await prefs.setBool(soundCloudEnabledPreferenceKey, false);
      expect(
        (await onlineSources(client, store: store)).where((s) => s.id == 'sc'),
        isEmpty,
      );
      await expectLater(
        playOnlineTrack(
          'sc',
          const DiscoveryTrack(
            id: '123',
            title: 'Chosen source',
            artist: 'Artist',
            source: DiscoverySource.soundCloud,
            sourceName: 'SoundCloud',
          ),
          store: store,
          client: client,
        ),
        throwsA(isA<DiscoveryException>()),
      );
    },
  );

  test('new online Search includes saved HTTP add-ons', () async {
    final client = MockClient((_) async => fail('Search was not started'));
    addTearDown(client.close);
    final sources = await onlineSources(
      client,
      store: _MemorySettings(
        const DiscoverySettings(
          addons: [
            DiscoveryAddonConfig(
              id: 'home',
              label: 'Home music',
              endpoint: 'https://music.example/library',
              token: 'fixture-token',
              enabled: true,
            ),
          ],
        ),
      ),
    );

    expect(
      sources.where((source) => source.id == 'mono' || source.id == 'sc'),
      isEmpty,
    );

    expect(sources.singleWhere((source) => source.id == 'yt').addon, isFalse);

    expect(
      sources.where((source) => source.name == 'Home music'),
      hasLength(1),
    );
    expect(
      sources.singleWhere((source) => source.name == 'Home music').addon,
      isTrue,
    );
  });
}
