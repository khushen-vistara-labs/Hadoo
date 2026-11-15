import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/features/appearance/lokal_appearance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('theme grid does not repeat the surrounding bottom inset', (
    tester,
  ) async {
    Future<double> gridHeight(double bottom) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LokalTheme.build(
            LokalTokens.resolve(LokalThemeId.values.first),
          ),
          home: MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.only(bottom: bottom)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: LokalThemeGrid(
                  selected: LokalThemeId.values.first,
                  onSelect: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      return tester.getSize(find.byType(GridView)).height;
    }

    final normal = await gridHeight(0);
    final withDockInset = await gridHeight(220);
    expect(withDockInset, normal);
    expect(tester.takeException(), isNull);
  });
}
