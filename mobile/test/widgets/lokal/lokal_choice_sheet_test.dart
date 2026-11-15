import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/widgets/lokal/lokal_choice_sheet.dart';

void main() {
  testWidgets('Lokal choice sheet selects a value and closes', (tester) async {
    String? picked;
    final theme = LokalTheme.build(LokalTokens.themes[LokalThemeId.dark]!);
    await tester.pumpWidget(MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              picked = await showLokalChoiceSheet<String>(
                context: context,
                title: 'Sort by',
                selected: 'a',
                choices: const [
                  LokalChoice(value: 'a', label: 'Ascending',
                    icon: Icons.arrow_upward_rounded),
                  LokalChoice(value: 'z', label: 'Descending',
                    icon: Icons.arrow_downward_rounded),
                ],
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Ascending'), findsOneWidget);
    expect(find.text('Descending'), findsOneWidget);
    final inherited = theme.popupMenuTheme;
    expect(inherited.color, LokalTokens.themes[LokalThemeId.dark]!.surface2);
    await tester.tap(find.text('Descending'));
    await tester.pumpAndSettle();
    expect(picked, 'z');
    expect(find.text('Descending'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lokal choice sheet adapts to light theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: LokalTheme.build(LokalTokens.themes[LokalThemeId.light]!),
      home: Scaffold(
        body: Builder(builder: (context) => TextButton(
          onPressed: () => showLokalChoiceSheet<int>(
            context: context, title: 'Options',
            choices: const [LokalChoice(value: 1, label: 'Option 1')],
          ),
          child: const Text('Open'),
        )),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Option 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
