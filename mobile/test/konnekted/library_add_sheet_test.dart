import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/features/konnekted/konnekted_data.dart';
import 'package:flick/features/konnekted/konnekted_destination.dart';
import 'package:flick/features/konnekted/konnekted_library.dart';
import 'package:flick/features/konnekted/library/lokal_library_add_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ThemeData get _theme =>
    LokalTheme.build(LokalTokens.resolve(LokalThemeId.dark));

void main() {
  testWidgets('Library actions dismiss root modal, not nested page', (
    tester,
  ) async {
    final root = GlobalKey<NavigatorState>();
    final nested = GlobalKey<NavigatorState>();
    LokalLibraryAddAction? selected;
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: root,
        theme: _theme,
        home: Navigator(
          key: nested,
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => Scaffold(
              body: Builder(
                builder: (innerContext) => TextButton(
                  onPressed: () async {
                    selected = await showLokalLibraryAddSheet(innerContext);
                  },
                  child: const Text('Open add menu'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    for (final (label, action) in [
      ('New playlist', LokalLibraryAddAction.playlist),
      ('Add a music folder', LokalLibraryAddAction.folder),
    ]) {
      selected = null;
      await tester.tap(find.text('Open add menu'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(selected, action);
      expect(find.byType(BottomSheet), findsNothing);
      expect(root.currentState!.canPop(), isFalse);
      expect(nested.currentState!.canPop(), isFalse);
      expect(find.text('Open add menu'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'Library only offers YouTube playlist creation and the folder picker',
    (tester) async {
      tester.view
        ..physicalSize = const Size(393, 852)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final opened = <KonnektedDestination>[];
      var foldersPicked = 0;
      final nested = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            konnektedLibraryProvider.overrideWithValue(const AsyncData([])),
          ],
          child: MaterialApp(
            theme: _theme,
            home: Navigator(
              key: nested,
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  body: KonnektedLibrary(
                    onNavigate: opened.add,
                    onAddFolder: (_) => foldersPicked++,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      Future<void> openMenu() async {
        await tester.tap(
          find.bySemanticsLabel('Add music, playlists and folders'),
        );
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsOneWidget);
        expect(find.text('Import M3U'), findsNothing);
        expect(find.text('Import a playlist link'), findsNothing);
      }

      await openMenu();
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Add a music folder'),
        ),
      );
      await tester.pumpAndSettle();
      expect(foldersPicked, 1);
      expect(
        opened,
        isEmpty,
        reason: 'Adding a folder must open the picker, not Settings.',
      );
      expect(nested.currentState!.canPop(), isFalse);

      expect(tester.takeException(), isNull);
    },
  );
}
