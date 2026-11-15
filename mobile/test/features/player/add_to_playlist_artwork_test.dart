import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/features/discovery/youtube_music_account.dart';
import 'package:flick/features/discovery/youtube_music_playlist_cache.dart';
import 'package:flick/features/hadoo/youtube_library_provider.dart';
import 'package:flick/features/konnekted/konnekted_discovery.dart';
import 'package:flick/features/player/widgets/add_to_playlist_sheet.dart';
import 'package:flick/models/song.dart';
import 'package:flick/providers/playlist_provider.dart';
import 'package:flick/widgets/lokal/lokal_toast.dart';

const session = YoutubeMusicSession(cookies: {'SAPISID': 'fake-widget-cookie'});
const song = Song(
  id: 'pending:one',
  title: 'Song',
  artist: 'Artist',
  duration: Duration(minutes: 3),
  fileType: 'OPUS',
  remoteId: 'yt:abcdefghijk',
);

class SignedIn extends KonnektedYoutubeMusicNotifier {
  @override
  Future<YoutubeMusicSession?> build() async => session;
}

Map<String, Object?> library() => {
  'gridRenderer': {
    'items': [
      {
        'musicTwoRowItemRenderer': {
          'title': {
            'runs': [
              {'text': 'My YouTube playlist'},
            ],
          },
          'navigationEndpoint': {
            'browseEndpoint': {
              'browseId': 'VLPLmine',
              'browseEndpointContextSupportedConfigs': {
                'browseEndpointContextMusicConfig': {
                  'pageType': 'MUSIC_PAGE_TYPE_PLAYLIST',
                },
              },
            },
          },
        },
      },
    ],
  },
  'musicPlaylistShelfRenderer': {'contents': []},
};

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(LokalToast.dismiss);
  Future<void> mount(WidgetTester tester, http.Client client) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          konnektedYoutubeMusicSessionProvider.overrideWith(SignedIn.new),
          konnektedYoutubeMusicAccountProvider.overrideWith(
            (_) => YoutubeMusicAccount(client, session),
          ),
          youtubePlaylistCacheProvider.overrideWith(
            (_) => YoutubeMusicPlaylistCache(),
          ),
          playlistServiceProvider.overrideWith(
            (_) => throw StateError('Local playlist backend must not be used'),
          ),
        ],
        child: MaterialApp(
          theme: LokalTheme.build(LokalTokens.resolve(LokalThemeId.dark)),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => AddToPlaylistSheet.show(context, song),
                child: const Text('Open picker'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'picker loads YouTube playlists and only closes after an acknowledged write',
    (tester) async {
      final acknowledged = Completer<http.Response>();
      Map<String, dynamic>? sent;
      final client = MockClient((r) async {
        if (r.url.path.endsWith('browse/edit_playlist')) {
          sent = jsonDecode(r.body);
          return acknowledged.future;
        }
        return http.Response(jsonEncode(library()), 200);
      });
      addTearDown(client.close);
      await mount(tester, client);
      expect(find.text('My YouTube playlist'), findsOneWidget);
      await tester.tap(find.text('My YouTube playlist'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(sent!['playlistId'], 'PLmine');
      expect((sent!['actions'] as List).single['addedVideoId'], 'abcdefghijk');
      acknowledged.complete(
        http.Response('{"status":"STATUS_SUCCEEDED"}', 200),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('Saved to your YouTube playlist.'), findsOneWidget);
      LokalToast.dismiss();
    },
  );

  testWidgets(
    'permission failure stays visible and does not claim a local save',
    (tester) async {
      final client = MockClient(
        (r) async => r.url.path.endsWith('browse/edit_playlist')
            ? http.Response('{}', 403)
            : http.Response(jsonEncode(library()), 200),
      );
      addTearDown(client.close);
      await mount(tester, client);
      await tester.tap(find.text('My YouTube playlist'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.textContaining('own or collaborate'), findsOneWidget);
      expect(find.text('Saved to your YouTube playlist.'), findsNothing);
      LokalToast.dismiss();
    },
  );

  testWidgets('duplicate song shows already present and sends no edit', (
    tester,
  ) async {
    var edits = 0;
    final client = MockClient((r) async {
      if (r.url.path.endsWith('browse/edit_playlist')) edits++;
      final data = library();
      data['musicPlaylistShelfRenderer'] = {
        'contents': [
          {
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
            },
          },
        ],
      };
      return http.Response(jsonEncode(data), 200);
    });
    addTearDown(client.close);
    await mount(tester, client);
    await tester.tap(find.text('My YouTube playlist'));
    await tester.pumpAndSettle();
    expect(edits, 0);
    expect(
      find.text('This song is already in this YouTube playlist.'),
      findsOneWidget,
    );
    expect(find.text('Saved to your YouTube playlist.'), findsNothing);
    LokalToast.dismiss();
  });

  testWidgets(
    'create from the song picker creates a private remote playlist with that exact recording',
    (tester) async {
      Map<String, dynamic>? created;
      final client = MockClient((r) async {
        if (r.url.path.endsWith('playlist/create')) {
          created = jsonDecode(r.body);
          return http.Response('{"playlistId":"PLnew"}', 200);
        }
        return http.Response(jsonEncode(library()), 200);
      });
      addTearDown(client.close);
      await mount(tester, client);
      await tester.tap(find.text('New YouTube playlist'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Created in Hadoo');
      await tester.tap(find.text('Create on YouTube'));
      await tester.pumpAndSettle();
      expect(created!['title'], 'Created in Hadoo');
      expect(created!['privacyStatus'], 'PRIVATE');
      expect(created!['videoIds'], ['abcdefghijk']);
      expect(find.byType(BottomSheet), findsNothing);
      LokalToast.dismiss();
    },
  );
}
