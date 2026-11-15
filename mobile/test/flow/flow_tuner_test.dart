import 'package:flick/features/flow/domain/flow_models.dart';
import 'package:flick/features/flow/flow_tuner_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('draft mood, slider and genre edits cancel without applying', (
    tester,
  ) async {
    final committed = FlowConfig();
    var applyCount = 0;
    await _host(tester, committed, (_) async {
      applyCount++;
    });
    await tester.tap(find.text('Open tuner'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Focus'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('flow-discovery')),
      const Offset(100, 0),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('flow-genre-jazz')));
    await tester.tap(find.byKey(const Key('flow-genre-jazz')));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(applyCount, 0);
    expect(committed, FlowConfig());
    await tester.tap(find.text('Open tuner'));
    await tester.pumpAndSettle();
    final slider = tester.widget<Slider>(
      find.byKey(const Key('flow-discovery')),
    );
    expect(slider.value, .35);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Flow'))
          .selected,
      isTrue,
    );
  });

  testWidgets('Apply submits all draft fields once, then closes the tuner', (
    tester,
  ) async {
    FlowConfig? applied;
    var applyCount = 0;
    await _host(tester, FlowConfig(), (config) async {
      applied = config;
      applyCount++;
    });
    await tester.tap(find.text('Open tuner'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chill'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('flow-discovery')),
      const Offset(80, 0),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('flow-memory')));
    await tester.drag(
      find.byKey(const Key('flow-memory')),
      const Offset(-80, 0),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('flow-genre-jazz')));
    await tester.tap(find.byKey(const Key('flow-genre-jazz')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('flow-apply')));
    await tester.pumpAndSettle();
    expect(applyCount, 1);
    expect(applied!.mood, FlowMood.chill);
    expect(applied!.discovery, greaterThan(.35));
    expect(applied!.memory, lessThan(.5));
    expect(applied!.excludedGenres, {'jazz'});
    expect(find.text('Tune your Flow'), findsNothing);
  });

  testWidgets('system back discards drafts and failed Apply stays editable', (
    tester,
  ) async {
    var applies = 0;
    await _host(tester, FlowConfig(), (_) async {
      applies++;
      throw StateError('Storage unavailable');
    });
    await tester.tap(find.text('Open tuner'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Party'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('flow-apply')));
    await tester.pumpAndSettle();
    expect(applies, 1);
    expect(find.text('Tune your Flow'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open tuner'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Flow'))
          .selected,
      isTrue,
    );
    expect(applies, 1);
  });
}

Future<void> _host(
  WidgetTester tester,
  FlowConfig config,
  Future<void> Function(FlowConfig) onApply,
) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          child: const Text('Open tuner'),
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => FlowTunerSheet(
              config: config,
              genres: const ['jazz', 'rock'],
              onApply: onApply,
            ),
          ),
        ),
      ),
    ),
  ),
);
