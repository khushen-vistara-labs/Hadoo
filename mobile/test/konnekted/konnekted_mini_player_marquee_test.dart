import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/features/konnekted/konnekted_dock.dart';
import 'package:flick/models/song.dart';
import 'package:flick/widgets/common/marquee_widget.dart';
import 'package:flick/widgets/common/overflow_marquee_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget miniPlayer(
  String title, {
  bool collapsed = false,
  bool reducedMotion = false,
  String trackId = 'track-1',
  double width = 320,
}) {
  return ProviderScope(
    child: MaterialApp(
      theme: LokalTheme.build(LokalTokens.resolve(LokalThemeId.dark)),
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 568),
          disableAnimations: reducedMotion,
        ),
        child: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: width,
              height: 58,
              child: KonnektedMiniPlayerScope(
                collapsed: collapsed,
                child: KonnektedMiniPlayerContent(
                  song: Song(
                    id: trackId,
                    title: title,
                    artist: 'Artist',
                    duration: const Duration(minutes: 3),
                    fileType: 'FLAC',
                  ),
                  isPlaying: true,
                  onOpen: () {},
                  onPlayPause: () {},
                  onPrevious: () {},
                  onNext: () {},
                  onQueue: () {},
                  progress: const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  const longTitle =
      'A Very Long Song Title That Cannot Fit In The Minimized Player';

  testWidgets('long dock titles use the horizontal marquee', (tester) async {
    await tester.pumpWidget(miniPlayer(longTitle));
    await tester.pump();
    final title = find.byType(OverflowMarqueeTitle);
    expect(title, findsOneWidget);
    expect(tester.widget<OverflowMarqueeTitle>(title).title, longTitle);
    expect(find.byType(MarqueeWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('short titles stay still without an unnecessary animation',
      (tester) async {
    await tester.pumpWidget(miniPlayer('Song'));
    await tester.pump();
    expect(find.byType(OverflowMarqueeTitle), findsOneWidget);
    expect(find.byType(MarqueeWidget), findsNothing);
    expect(find.text('Song'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('collapsed dock also scrolls long titles', (tester) async {
    await tester.pumpWidget(miniPlayer(longTitle, collapsed: true, width: 220));
    await tester.pump();
    expect(find.byType(MarqueeWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reduced motion uses a static truncated title', (tester) async {
    await tester.pumpWidget(miniPlayer(longTitle, reducedMotion: true));
    await tester.pump();
    expect(find.byType(MarqueeWidget), findsNothing);
    final text = tester.widget<Text>(find.text(longTitle));
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('changing tracks resets marquee to the beginning',
      (tester) async {
    await tester.pumpWidget(miniPlayer(longTitle, trackId: 'first'));
    await tester.pump();
    expect(find.byKey(const ValueKey('dock-mini-title:first')),
        findsOneWidget);
    await tester.pumpWidget(miniPlayer(longTitle, trackId: 'second'));
    await tester.pump();
    expect(find.byKey(const ValueKey('dock-mini-title:second')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('dock-mini-title:first')), findsNothing);
    expect(find.byType(MarqueeWidget), findsOneWidget);
    final scrollView = tester.widget<SingleChildScrollView>(
      find.descendant(
        of: find.byType(MarqueeWidget),
        matching: find.byType(SingleChildScrollView),
      ),
    );
    expect(scrollView.controller!.offset, 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
