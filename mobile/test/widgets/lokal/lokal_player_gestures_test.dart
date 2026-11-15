import 'package:flick/widgets/lokal/lokal_like_burst.dart';
import 'package:flick/widgets/lokal/lokal_pull_to_dismiss.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<({List<String> events})> pump(
    WidgetTester tester, {
    bool Function()? blocked,
  }) async {
    final events = <String>[];
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: LokalPullToDismiss(
          onDismiss: () => events.add('dismiss'),
          onPullUp: () => events.add('up'),
          isBlocked: blocked,
          child: const ColoredBox(
            color: Colors.blue,
            child: Center(child: Text('sheet')),
          ),
        ),
      ),
    );
    return (events: events);
  }

  double top(WidgetTester tester) => tester.getTopLeft(find.text('sheet')).dy;

  testWidgets('follows the finger and springs back on a short pull', (
    tester,
  ) async {
    final r = await pump(tester);
    final start = top(tester);
    final gesture = await tester.startGesture(const Offset(200, 300));
    await gesture.moveBy(const Offset(0, 20));
    await gesture.moveBy(const Offset(0, 100));
    await tester.pump();
    expect(top(tester), moreOrLessEquals(start + 100, epsilon: 25));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(top(tester), moreOrLessEquals(start, epsilon: .5));
    expect(r.events, isEmpty);
  });

  testWidgets('a pull past a quarter of the screen closes it', (tester) async {
    final r = await pump(tester);
    await tester.timedDrag(
      find.text('sheet'),
      const Offset(0, 260),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(r.events, ['dismiss']);
  });

  testWidgets('a fast flick down closes it', (tester) async {
    final r = await pump(tester);
    await tester.fling(find.text('sheet'), const Offset(0, 80), 1500);
    await tester.pumpAndSettle();
    expect(r.events, ['dismiss']);
  });

  testWidgets('pulling up opens what sits above, never closes', (tester) async {
    final r = await pump(tester);
    await tester.timedDrag(
      find.text('sheet'),
      const Offset(0, -140),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(r.events, ['up']);
  });

  testWidgets('drags are ignored while another gesture owns the finger', (
    tester,
  ) async {
    final r = await pump(tester, blocked: () => true);
    final start = top(tester);
    await tester.timedDrag(
      find.text('sheet'),
      const Offset(0, 300),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(r.events, isEmpty);
    expect(top(tester), start);
  });

  testWidgets('the like burst plays once and reports when it is done', (
    tester,
  ) async {
    var done = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: LokalLikeBurst(color: Colors.lime, onDone: () => done++),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 240));
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(done, 0);
    await tester.pump(const Duration(milliseconds: 400));
    expect(done, 1);
  });
}
