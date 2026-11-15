// Render the real Home/Library widgets with fictional local fixtures.
// Regenerate: python3 tool/render_release_banner.py --demo-covers /tmp/lokal-readme-covers
// flutter test tool/render_readme_test.dart
import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/features/konnekted/konnekted_data.dart';
import 'package:flick/features/konnekted/konnekted_home.dart';
import 'package:flick/features/konnekted/konnekted_library.dart';
import 'package:flick/features/konnekted/konnekted_dock.dart';
import 'package:flick/features/konnekted/lokal_home_greeting.dart';
import 'package:flick/features/konnekted/lokal_mixes.dart';
import 'package:flick/models/song.dart';

void main() {
  testWidgets('render fictional README library', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view
      ..physicalSize = const Size(412, 915)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final name in ['HadooMono']) {
      final file = 'JetBrainsMono-Regular';
      final loader = FontLoader(name)
        ..addFont(rootBundle.load('assets/fonts/$file.ttf'));
      await loader.load();
    }
    final material = FontLoader('MaterialIcons')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File(
              '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
            ).readAsBytesSync(),
          ),
        ),
      );
    await material.load();
    await tester.runAsync(() async {
      for (var i = 0; i < 6; i++) {
        for (var width = 64; width <= 512; width += 64) {
          final done = Completer<void>();
          final stream = ResizeImage(
            FileImage(File('/tmp/lokal-readme-covers/$i.png')),
            width: width,
          ).resolve(const ImageConfiguration());
          late ImageStreamListener listener;
          listener = ImageStreamListener(
            (_, __) {
              if (!done.isCompleted) done.complete();
            },
            onError: (Object e, StackTrace? s) {
              if (!done.isCompleted) done.completeError(e, s);
            },
          );
          stream.addListener(listener);
          await done.future;
          stream.removeListener(listener);
        }
      }
    });
    final songs = [
      for (var i = 0; i < 6; i++)
        Song(
          id: 'demo-$i',
          title: [
            'Tideline',
            'After Hours',
            'Lilac Sky',
            'Blue Room',
            'Slow Light',
            'Side Streets',
          ][i],
          artist: [
            'Mira Coast',
            'The Late Hours',
            'June & Violet',
            'Low Tide',
            'Sol Avenue',
            'Noah Park',
          ][i],
          album: [
            'Coastlines',
            'After Hours',
            'Daydreams',
            'Blue Room',
            'Slow Light',
            'Side Streets',
          ][i],
          albumArt: '/tmp/lokal-readme-covers/$i.png',
          filePath: '/demo/$i.flac',
          fileType: 'FLAC',
          sampleRate: 96000,
          bitDepth: 24,
          duration: const Duration(minutes: 3, seconds: 42),
          dateAdded: DateTime(2026, 10, 22 - i),
        ),
    ];
    final mixes = [
      for (var i = 0; i < 6; i++)
        LokalMix(
          id: 'mix-$i',
          name: [
            'Daily Mix',
            'New Arrivals',
            'Most Played',
            'Late Night',
            'Hidden Gems',
            'Your Favorites',
          ][i],
          type: LokalMixType.daily,
          tracks: [songs[i], songs[(i + 1) % 6]],
        ),
    ];
    final boundary = GlobalKey();
    for (final library in [false, true]) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            konnektedLibraryProvider.overrideWithValue(AsyncData(songs)),
            konnektedFavoritesProvider.overrideWithValue(
              AsyncData(songs.take(3).toList()),
            ),
            konnektedRecentSongsProvider.overrideWith(
              (ref) => Stream.value(songs),
            ),
            konnektedGreetingProvider.overrideWith(
              (ref) => Stream.value(
                const LokalHomeMessages(
                  'Wide rotation',
                  'Lots of different sounds in your rotation lately.',
                ),
              ),
            ),
            konnektedMixesProvider.overrideWith((ref) async => mixes),
          ],
          child: MaterialApp(
            theme: LokalTheme.build(LokalTokens.resolve(LokalThemeId.dark)),
            home: RepaintBoundary(
              key: boundary,
              child: MediaQuery(
                data: const MediaQueryData(
                  size: Size(412, 915),
                  padding: EdgeInsets.only(top: 28, bottom: 20),
                  disableAnimations: true,
                ),
                child: Scaffold(
                  body: Stack(
                    children: [
                      Positioned.fill(
                        child: library
                            ? KonnektedLibrary(onNavigate: (_) {})
                            : KonnektedHome(
                                onNavigate: (_) {},
                                onPlay: (_, __) {},
                              ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: KonnektedDock(
                          selected: library
                              ? KonnektedTab.library
                              : KonnektedTab.listen,
                          onSelect: (_) {},
                          miniPlayer: KonnektedMiniPlayerContent(
                            song: songs.first,
                            isPlaying: true,
                            onOpen: () {},
                            onPlayPause: () {},
                            onNext: () {},
                            onPrevious: () {},
                            onQueue: () {},
                            progress: const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('docs/images/${library ? 'library' : 'home'}.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
