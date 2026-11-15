import 'package:flick/core/constants/app_constants.dart';
import 'package:flick/core/theme/app_theme.dart';
import 'package:flick/features/songs/widgets/sort_filter_bottom_sheet.dart';
import 'package:flick/providers/songs_provider.dart';
import 'package:flick/widgets/common/glass_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _systemInset = EdgeInsets.only(bottom: 34);

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(padding: _systemInset),
        child: Scaffold(body: child),
      ),
    ),
  );
}

Container _surfaceContainer(WidgetTester tester) {
  final finder = find.byWidgetPredicate(
    (widget) =>
        widget is Container &&
        widget.decoration == AppBottomSheetSurface.decoration,
  );
  expect(finder, findsOneWidget);
  return tester.widget<Container>(finder);
}

void main() {
  group('AppBottomSheetSurface', () {
    testWidgets(
      'paints to the bottom edge and keeps the system inset as content padding',
      (tester) async {
        await tester.pumpWidget(
          _host(const AppBottomSheetSurface(child: SizedBox(height: 100))),
        );

        final container = _surfaceContainer(tester);
        final padding = container.padding! as EdgeInsets;
        expect(padding.bottom, AppConstants.spacingLg + _systemInset.bottom);

        final surfaceRect = tester.getRect(find.byWidget(container));
        final screenRect = tester.getRect(find.byType(Scaffold));
        expect(surfaceRect.bottom, screenRect.bottom);
      },
    );

    testWidgets('respects a custom padding and still adds the system inset', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const AppBottomSheetSurface(
            padding: EdgeInsets.zero,
            child: SizedBox(height: 100),
          ),
        ),
      );

      final container = _surfaceContainer(tester);
      final padding = container.padding! as EdgeInsets;
      expect(padding, EdgeInsets.only(bottom: _systemInset.bottom));
    });
  });

  group('GlassBottomSheet', () {
    testWidgets('adds the system inset to its default bottom padding', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const GlassBottomSheet(content: SizedBox(height: 100))),
      );

      final container = _surfaceContainer(tester);
      final padding = container.padding! as EdgeInsets;
      expect(padding.bottom, AppConstants.spacingLg + _systemInset.bottom);
    });
  });

  group('standalone sheets', () {
    testWidgets('use the shared bottom sheet material', (tester) async {
      await tester.pumpWidget(
        _host(
          SortFilterBottomSheet(
            currentSort: SongSortOption.title,
            currentFilter: SongFileTypeFilter.all,
            onSortChanged: (_) {},
            onFilterChanged: (_) {},
          ),
        ),
      );

      _surfaceContainer(tester);
    });
  });
}
