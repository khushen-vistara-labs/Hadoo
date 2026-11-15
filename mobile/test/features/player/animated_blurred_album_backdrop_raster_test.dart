import 'package:flick/features/player/widgets/animated_blurred_album_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('classic background blurs stable artwork before moving it',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(
          child: AnimatedBlurredAlbumBackdrop(),
        ),
      ),
    ));

    final blurred = find.byKey(const ValueKey('cached-backdrop-blur'));
    final moved = find.byKey(const ValueKey('animated-backdrop-motion'));
    expect(blurred, findsOneWidget);
    expect(moved, findsOneWidget);
    expect(
      find.descendant(of: blurred, matching: find.byType(ImageFiltered)),
      findsOneWidget,
    );
    expect(
      find.ancestor(of: blurred, matching: moved),
      findsOneWidget,
      reason: 'The blur is inside the animated transform, not recomputed '
          'over the moving full-screen image on every raster frame.',
    );

    final before = tester.widget<Transform>(moved).transform.clone();
    await tester.pump(const Duration(seconds: 1));
    final after = tester.widget<Transform>(moved).transform;
    expect(after, isNot(before),
        reason: 'The animated blurred artwork must still drift.');
  });
}
