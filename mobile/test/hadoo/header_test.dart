import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/features/hadoo/hadoo_header.dart';

void main() {
  testWidgets('terminal actions work at narrow width and large text size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var search = 0, downloads = 0, settings = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: LokalTheme.build(LokalTokens.resolve(LokalThemeId.dark)),
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: SingleChildScrollView(
              child: HadooHeader(
                onSearch: () => search++,
                onDownloads: () => downloads++,
                onSettings: () => settings++,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('/search'));
    await tester.tap(find.text('/downloads'));
    await tester.tap(find.byTooltip('Settings'));
    expect([search, downloads, settings], [1, 1, 1]);
  });

  testWidgets('render Hadoo terminal header with its bundled typeface', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 430);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final loader = FontLoader('HadooMono')
      ..addFont(rootBundle.load('assets/fonts/JetBrainsMono-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/JetBrainsMono-Bold.ttf'));
    await loader.load();
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
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: LokalTheme.build(LokalTokens.resolve(LokalThemeId.dark)),
        home: Scaffold(
          body: RepaintBoundary(
            key: const ValueKey('hadoo-preview'),
            child: ColoredBox(
              color: LokalTokens.resolve(LokalThemeId.dark).bg,
              child: HadooHeader(
                onSearch: () {},
                onDownloads: () {},
                onSettings: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => precacheImage(
        const AssetImage('assets/branding/hadoo-mark.png'),
        tester.element(find.byType(HadooHeader)),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('hadoo-preview')),
      // Font rasterization differs between the macOS development host and CI.
      // Keep exact comparisons against the reviewed image for this host.
      matchesGoldenFile(
        'goldens/${Platform.operatingSystem}/terminal-header.png',
      ),
    );
  });
}
