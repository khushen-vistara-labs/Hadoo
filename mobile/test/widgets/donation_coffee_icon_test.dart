import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flick/core/theme/adaptive_color_provider.dart';
import 'package:flick/features/settings/widgets/donation_coffee_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const _captureKey = ValueKey('coffee-capture');

Future<void> _mount(
  WidgetTester tester, {
  bool disableAnimations = false,
  bool dark = true,
  bool tickerEnabled = true,
}) async {
  final background = dark ? const Color(0xFF121212) : Colors.white;
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: AdaptiveColorProvider(
          backgroundColor: background,
          child: TickerMode(
            enabled: tickerEnabled,
            child: Center(
              child: RepaintBoundary(
                key: _captureKey,
                child: ColoredBox(
                  color: background,
                  child: const DonationCoffeeIcon(),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<Uint8List> _pixels(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  final pixels = await tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      return Uint8List.fromList(data!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
  return pixels!;
}

void main() {
  testWidgets('mug pours, steams, resets, and repeats without changing size', (
    tester,
  ) async {
    await _mount(tester);
    final empty = await _pixels(tester);
    final size = tester.getSize(find.byType(DonationCoffeeIcon));

    await tester.pump(const Duration(milliseconds: 1800));
    final pouring = await _pixels(tester);
    expect(pouring, isNot(orderedEquals(empty)));

    await tester.pump(const Duration(seconds: 3));
    final steaming = await _pixels(tester);
    expect(steaming, isNot(orderedEquals(pouring)));

    await tester.pump(const Duration(milliseconds: 400));
    expect(await _pixels(tester), isNot(orderedEquals(steaming)));

    await tester.pump(const Duration(milliseconds: 2800));
    expect(await _pixels(tester), orderedEquals(empty));
    expect(tester.getSize(find.byType(DonationCoffeeIcon)), size);
    expect(tester.binding.hasScheduledFrame, isTrue);

    await tester.pump(const Duration(milliseconds: 1800));
    expect(await _pixels(tester), orderedEquals(pouring));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final dark in [true, false]) {
    testWidgets('reduced motion shows the resting full mug (dark: $dark)', (
      tester,
    ) async {
      await _mount(tester, dark: dark);
      final empty = await _pixels(tester);

      await tester.pumpWidget(const SizedBox.shrink());
      await _mount(tester, dark: dark, disableAnimations: true);
      await tester.pumpAndSettle();
      final full = await _pixels(tester);
      expect(full, isNot(orderedEquals(empty)));
      await tester.pump(const Duration(seconds: 10));
      expect(await _pixels(tester), orderedEquals(full));
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'reduced motion stops the loop and re-enabling motion resumes it',
    (tester) async {
      await _mount(tester);
      await tester.pump(const Duration(seconds: 1));
      await _mount(tester, disableAnimations: true);
      await tester.pumpAndSettle();
      final full = await _pixels(tester);
      expect(tester.binding.hasScheduledFrame, isFalse);

      await _mount(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(await _pixels(tester), isNot(orderedEquals(full)));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('hidden icon pauses and resumes when visible', (tester) async {
    await _mount(tester);
    await tester.pump(const Duration(milliseconds: 1800));
    final pouring = await _pixels(tester);

    await _mount(tester, tickerEnabled: false);
    await tester.pump(const Duration(seconds: 2));
    expect(await _pixels(tester), orderedEquals(pouring));
    expect(tester.binding.hasScheduledFrame, isFalse);

    await _mount(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(await _pixels(tester), isNot(orderedEquals(pouring)));
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('backgrounding the app pauses the loop', (tester) async {
    void resumeApp() {
      if (tester.binding.lifecycleState == AppLifecycleState.paused) {
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      }
      if (tester.binding.lifecycleState == AppLifecycleState.hidden) {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
      }
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    }

    await _mount(tester);
    await tester.pump(const Duration(milliseconds: 1800));
    final pouring = await _pixels(tester);

    try {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 2));
      expect(await _pixels(tester), orderedEquals(pouring));

      resumeApp();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(await _pixels(tester), isNot(orderedEquals(pouring)));
      expect(tester.binding.hasScheduledFrame, isTrue);
    } finally {
      resumeApp();
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('disposing during the pour cancels the ticker', (tester) async {
    await _mount(tester);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}
