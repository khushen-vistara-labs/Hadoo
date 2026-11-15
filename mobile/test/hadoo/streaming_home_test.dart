import 'package:flutter/material.dart';
import 'package:flick/features/discovery/discovery_artwork.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flick/features/konnekted/konnekted_data.dart';
import 'package:flick/features/konnekted/konnekted_discovery.dart';
import 'package:flick/features/discovery/youtube_music_account.dart';
import 'package:flick/features/discovery/lastfm_discovery.dart';
import 'package:flick/features/hadoo/youtube_library_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/features/hadoo/hadoo_streaming_home.dart';
import 'package:flick/features/hadoo/hadoo_welcome.dart';
import 'package:flick/features/konnekted/konnekted_destination.dart';
import 'package:flick/providers/onboarding_provider.dart';

class NoArtwork implements DiscoveryArtworkResolver {
  @override
  Future<String> resolve(DiscoveryArtworkRequest request) async => '';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget app(Widget child, {double scale = 1}) => ProviderScope(
  overrides: [
    konnektedLibraryProvider.overrideWithValue(const AsyncData([])),
    discoveryArtworkResolverProvider.overrideWithValue(NoArtwork()),
  ],
  child: MaterialApp(
    theme: LokalTheme.build(LokalTokens.resolve(LokalThemeId.dark)),
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: Scaffold(body: child),
    ),
  ),
);

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('home searches the streaming source and keeps the latest query', (
    tester,
  ) async {
    final queries = <String>[];
    final destinations = <KonnektedDestination>[];
    await tester.pumpWidget(
      app(
        HadooStreamingHome(
          onNavigate: destinations.add,
          onPlay: (_, __) {},
          resultsBuilder: (query) {
            queries.add(query);
            return SliverToBoxAdapter(child: Text('Online results: $query'));
          },
        ),
      ),
    );
    expect(find.text('Search YouTube Music'), findsOneWidget);
    expect(find.text('Local'), findsNothing);
    expect(find.textContaining('Lokal'), findsNothing);
    expect(find.textContaining('Prism'), findsNothing);
    await tester.enterText(find.byType(TextField), 'first');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'Daft Punk');
    await tester.pump(const Duration(milliseconds: 351));
    expect(queries, ['Daft Punk']);
    expect(find.text('Online results: Daft Punk'), findsOneWidget);
    await tester.tap(find.text('/downloads'));
    expect(destinations, [KonnektedDestination.downloads]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('streaming home fits a narrow phone at 200 percent text size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(HadooStreamingHome(onNavigate: (_) {}, onPlay: (_, __) {}), scale: 2),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'signed-in Home shows real YouTube shelves and its playlist entry',
    (tester) async {
      const session = YoutubeMusicSession(
        cookies: {'SAPISID': 'fake-home-cookie'},
      );
      final client = http.Client();
      addTearDown(client.close);
      final destinations = <KonnektedDestination>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            konnektedLibraryProvider.overrideWithValue(const AsyncData([])),
            konnektedYoutubeMusicAccountProvider.overrideWith(
              (_) => YoutubeMusicAccount(client, session),
            ),
            hadooYoutubeHomeProvider.overrideWith(
              (_) async => (
                account: session.accountKey,
                data: const LokalDiscovery(
                  account: 'fixture',
                  page: 0,
                  freshFinds: [
                    LokalDiscoveryTrack(
                      title: 'Personal recommendation',
                      artist: 'Recommended artist',
                    ),
                  ],
                ),
              ),
            ),
          ],
          child: app(
            HadooStreamingHome(
              onNavigate: destinations.add,
              onPlay: (_, __) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('FOR YOU // YOUTUBE'), findsOneWidget);
      expect(find.text('Personal recommendation'), findsOneWidget);
      await tester.tap(find.text('Your YouTube playlists'));
      expect(destinations, [KonnektedDestination.playlists]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('welcome starts Hadoo without folder or desktop setup', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: app(const HadooWelcome()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Stream YouTube Music.'), findsOneWidget);
    expect(find.text('Choose Folder'), findsNothing);
    expect(find.textContaining('Lokal'), findsNothing);
    expect(find.textContaining('Prism'), findsNothing);
    await tester.tap(find.text('Start listening'));
    await tester.pumpAndSettle();
    expect(container.read(onboardingCompletedProvider), isTrue);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(OnboardingCompletedNotifier.prefKey), isTrue);
  });
}
