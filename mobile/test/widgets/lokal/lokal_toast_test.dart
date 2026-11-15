import 'package:flick/widgets/lokal/lokal_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => LokalToast.dismiss());

  testWidgets('in-app feedback appears as a compact pill above the footer', (tester) async {
    late BuildContext screen;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Builder(builder: (context) {
        screen = context;
        return const SizedBox.expand();
      })),
    ));
    LokalToast.show(screen, 'Playback cache has reached its limit');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    final label = find.text('Playback cache has reached its limit');
    expect(label, findsOneWidget);
    final center = tester.getCenter(label);
    final size = MediaQuery.sizeOf(screen);
    expect(center.dx, closeTo(size.width / 2, size.width * .15));
    expect(center.dy, lessThan(size.height * .25));
    await tester.pump(const Duration(seconds: 3));
    expect(label, findsNothing);
  });

  testWidgets('progress updates in place without growing a toast stack', (tester) async {
    late BuildContext screen;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Builder(builder: (context) {
        screen = context;
        return const SizedBox.expand();
      })),
    ));
    final first = Object();
    final second = Object();
    LokalToast.progress(screen, 'Loading 10%', owner: first);
    await tester.pump();
    expect(find.text('Loading 10%'), findsOneWidget);
    LokalToast.progress(screen, 'Loading 50%', owner: first);
    await tester.pump();
    expect(find.text('Loading 10%'), findsNothing);
    expect(find.text('Loading 50%'), findsOneWidget);
    LokalToast.progress(screen, 'Loading different work', owner: second);
    LokalToast.dismiss(owner: first);
    await tester.pump();
    expect(find.text('Loading different work'), findsOneWidget);
    LokalToast.dismiss(owner: second);
    await tester.pump();
    expect(find.text('Loading different work'), findsNothing);
  });

  testWidgets('sync action remains operable in the top pill', (tester) async {
    late BuildContext screen;
    var tapped = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Builder(builder: (context) {
        screen = context;
        return const SizedBox.expand();
      })),
    ));
    LokalToast.show(screen, 'Playback out of sync',
      actionLabel: 'Sync', onAction: () => tapped++);
    await tester.pump();
    await tester.tap(find.text('Sync'));
    await tester.pump();
    expect(tapped, 1);
    expect(find.text('Playback out of sync'), findsNothing);
  });
}
