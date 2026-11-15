import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flick/models/mini_player_config.dart';
import 'package:flick/models/nav_bar_config.dart';
import 'package:flick/providers/providers.dart';
import 'package:flick/providers/mini_player_config_provider.dart';
import 'package:flick/features/settings/widgets/mini_player_customization.dart';
import 'package:flick/widgets/common/mini_player_bar.dart';
import 'package:flick/widgets/common/marquee_widget.dart';
import 'package:flick/widgets/navigation/bottom_bar_geometry.dart';
import 'package:flick/widgets/navigation/flick_nav_bar.dart';

Widget _host(
  Widget child, {
  double width = 375,
  double textScale = 1,
  bool reducedMotion = true,
  EdgeInsets padding = EdgeInsets.zero,
}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(
      size: Size(width, 800),
      padding: padding,
      textScaler: TextScaler.linear(textScale),
      disableAnimations: reducedMotion,
    ),
    child: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(width: width, child: child),
      ),
    ),
  ),
);

MiniPlayerBar _bar(
  MiniPlayerConfig config, {
  bool separated = false,
  bool collapsed = false,
}) => MiniPlayerBar(
  config: config,
  songId: 'test',
  title: 'A very long song title that should remain readable on a small phone',
  artist: 'An artist with a long name',
  progress: 0.42,
  enableHero: false,
  separated: separated,
  collapsed: collapsed,
  onPlayPause: () {},
  onPrevious: () {},
  onNext: () {},
);

void main() {
  testWidgets('combined bar handles small phones, large text and every control', (
    tester,
  ) async {
    for (final width in [320.0, 375.0, 600.0]) {
      for (final scale in [1.0, 2.0, 3.0]) {
        for (final separated in [false, true]) {
          for (final collapsed in [false, true]) {
            final config = MiniPlayerConfig.defaultConfig.copyWith(
              widthMode: MiniPlayerWidthMode.custom,
              widthFraction: 0.7,
              height: 48,
              cornerRadius: 32,
              navigationGap: 24,
              showPrevious: true,
              showNext: true,
              textScale: 1.3,
            );
            await tester.pumpWidget(
              _host(
                FlickNavBar(
                  config: NavBarConfig.defaultConfig,
                  currentIndex: 1,
                  onTap: (_) {},
                  collapsed: collapsed,
                  separateMiniPlayer: separated,
                  showMiniPlayer: true,
                  miniPlayerWidget: _bar(
                    config,
                    separated: separated,
                    collapsed: collapsed,
                  ),
                ),
                width: width,
                textScale: scale,
                padding: const EdgeInsets.only(left: 20, right: 10, bottom: 24),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason:
                  'width=$width scale=$scale separate=$separated collapsed=$collapsed',
            );
            for (final label in ['Previous song', 'Play', 'Next song']) {
              final size = tester.getSize(find.byTooltip(label));
              expect(size.width, greaterThanOrEqualTo(48));
              expect(size.height, greaterThanOrEqualTo(48));
            }
            final surface = tester.getRect(
              find.byKey(const ValueKey('mini_player_surface')),
            );
            expect(surface.left, greaterThanOrEqualTo((800 - width) / 2 + 20));
            expect(surface.width, lessThanOrEqualTo(width - 30));
            expect(surface.height, greaterThanOrEqualTo(48));
          }
        }
      }
    }
  });

  testWidgets('navigation-matched width stays stable on collapse', (
    tester,
  ) async {
    Future<double> render(bool collapsed) async {
      await tester.pumpWidget(
        _host(
          FlickNavBar(
            config: NavBarConfig.defaultConfig,
            currentIndex: 1,
            onTap: (_) {},
            showMiniPlayer: true,
            separateMiniPlayer: true,
            collapsed: collapsed,
            miniPlayerWidget: _bar(
              MiniPlayerConfig.defaultConfig,
              separated: true,
              collapsed: collapsed,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return tester
          .getSize(find.byKey(const ValueKey('mini_player_surface')))
          .width;
    }

    final expanded = await render(false);
    expect(await render(true), expanded);
    expect(expanded, 327);
  });

  testWidgets(
    'custom width can be wider and narrower and is ignored when joined',
    (tester) async {
      Future<double> render(double fraction, bool separated) async {
        await tester.pumpWidget(
          _host(
            _bar(
              MiniPlayerConfig.defaultConfig.copyWith(
                widthMode: MiniPlayerWidthMode.custom,
                widthFraction: fraction,
              ),
              separated: separated,
            ),
          ),
        );
        await tester.pumpAndSettle();
        return tester
            .getSize(find.byKey(const ValueKey('mini_player_surface')))
            .width;
      }

      expect(await render(1, true), 375);
      expect(await render(0.7, true), 262.5);
      expect(await render(0.7, false), 351);
      expect(await render(1, false), 351);
    },
  );

  testWidgets(
    'controls invoke only their own action and visibility is applied',
    (tester) async {
      final actions = <String>[];
      await tester.pumpWidget(
        _host(
          MiniPlayerBar(
            config: MiniPlayerConfig.defaultConfig.copyWith(
              showArtwork: false,
              showArtist: false,
              showProgress: false,
              showPrevious: true,
              showNext: true,
            ),
            songId: 'actions',
            title: 'Song',
            artist: 'Artist',
            progress: 0.8,
            onOpen: () => actions.add('open'),
            onPlayPause: () => actions.add('play'),
            onPrevious: () => actions.add('previous'),
            onNext: () => actions.add('next'),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Previous song'));
      await tester.tap(find.byTooltip('Play'));
      await tester.tap(find.byTooltip('Next song'));
      expect(actions, ['previous', 'play', 'next']);
      expect(find.text('Artist'), findsNothing);
      expect(find.byType(Hero), findsNothing);
      expect(find.byKey(const ValueKey('mini_player_progress')), findsNothing);
      await tester.tap(find.text('Song'));
      expect(actions.last, 'open');
    },
  );

  testWidgets(
    'scrolling titles honor reduced motion and only scroll overflow',
    (tester) async {
      final config = MiniPlayerConfig.defaultConfig.copyWith(
        titleMode: MiniPlayerTitleMode.scroll,
      );
      await tester.pumpWidget(_host(_bar(config), reducedMotion: false));
      await tester.pump();
      expect(find.byType(MarqueeWidget), findsOneWidget);
      await tester.pumpWidget(_host(_bar(config)));
      await tester.pumpAndSettle();
      expect(find.byType(MarqueeWidget), findsNothing);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpWidget(
        _host(
          MiniPlayerBar(
            config: config,
            songId: 'short',
            title: 'Song',
            artist: 'Artist',
          ),
          reducedMotion: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MarqueeWidget), findsNothing);
    },
  );

  testWidgets('clearance includes added height, gap and accessibility growth', (
    tester,
  ) async {
    late double extra;
    final config = MiniPlayerConfig.defaultConfig.copyWith(
      height: 88,
      navigationGap: 24,
    );
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) {
            extra = BottomBarGeometry.extraClearance(context, config, true);
            return _bar(config);
          },
        ),
      ),
    );
    expect(extra, 48);
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) {
            extra = BottomBarGeometry.extraClearance(context, config, false);
            return _bar(config);
          },
        ),
      ),
    );
    expect(extra, 32);
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) {
            extra = BottomBarGeometry.extraClearance(
              context,
              MiniPlayerConfig.defaultConfig,
              false,
            );
            return _bar(MiniPlayerConfig.defaultConfig);
          },
        ),
        textScale: 3,
      ),
    );
    expect(extra, greaterThan(0));
  });

  testWidgets(
    'preview is isolated, uses sample data, and collapses without changing settings',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(
        overrides: [
          currentSongProvider.overrideWith((ref) => null),
          isPlayingProvider.overrideWith(
            (ref) => throw StateError('Preview accessed playback'),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _host(const MiniPlayerPreview()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sample song · preview only'), findsOneWidget);
      final renderer = tester.widget<MiniPlayerBar>(find.byType(MiniPlayerBar));
      expect(renderer.enableHero, isFalse);
      final before = container.read(miniPlayerConfigProvider).toJson();
      await tester.tap(find.byTooltip('Play'), warnIfMissed: false);
      await tester.tap(find.text('Collapsed'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<FlickNavBar>(find.byType(FlickNavBar)).collapsed,
        isTrue,
      );
      expect(container.read(miniPlayerConfigProvider).toJson(), before);
      expect(
        container.read(appPreferencesProvider).separateMiniPlayerFromNavBar,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
