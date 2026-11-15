import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flick/features/player/widgets/line_seek_bar.dart';

void main() {
  testWidgets('dragging shows a floating time popup with cancel control', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: LineSeekBar(
                position: Duration.zero,
                duration: const Duration(minutes: 3),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final barRect = tester.getRect(find.byType(LineSeekBar));
    final gesture = await tester.startGesture(
      Offset(barRect.left + 60, barRect.center.dy),
    );
    await gesture.moveTo(Offset(barRect.left + 220, barRect.center.dy));
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            RegExp(r'^\d{2}:\d{2}$').hasMatch(widget.data ?? ''),
      ),
      findsOneWidget,
    );

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsNothing);
  });
}
