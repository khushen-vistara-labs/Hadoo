import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flick/features/settings/library_scan/library_scan_sheet.dart';
import 'package:flick/services/library_scanner_service.dart' show ScanProgress;
import 'package:flick/services/scan_session_controller.dart';

int _generation = -1;

/// The app's shape: pages live in a nested navigator under the root one, and
/// the scan sheet goes on the root navigator.
Widget _app() => MaterialApp(
  home: Navigator(
    onGenerateRoute: (_) => MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => Scaffold(
                    body: Center(
                      child: TextButton(
                        onPressed: () {
                          _generation = ScanSessionController.instance.begin(
                            title: 'Music',
                            kind: ScanSessionKind.scan,
                            onCancel: () {},
                          );
                          LibraryScanSheet.show(
                            context,
                            generation: _generation,
                          );
                        },
                        child: const Text('Folders page'),
                      ),
                    ),
                  ),
                ),
              ),
              child: const Text('Settings'),
            ),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  final controller = ScanSessionController.instance;

  setUp(() {
    controller.end();
    controller.dismiss();
  });

  tearDown(() {
    controller.end();
    controller.dismiss();
  });

  Future<int> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Folders page'));
    // The progress bar spins until the first count: no settling.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    return _generation;
  }

  testWidgets('shows progress, then the outcome in place, and Done closes it', (
    tester,
  ) async {
    final generation = await openSheet(tester);

    controller.update(
      generation,
      ScanProgress(songsFound: 3, totalFiles: 10, filesProcessed: 3),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('scan-sheet-running')), findsOneWidget);
    expect(find.text('3 / 10'), findsOneWidget);
    expect(find.textContaining('Initializing'), findsNothing);

    controller.finish(
      generation,
      const ScanSessionResult(
        kind: ScanSessionKind.scan,
        title: 'Music',
        newSongs: 12,
        totalSongs: 340,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('12 songs added'), findsOneWidget);
    expect(find.text('SCAN COMPLETE'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // The sheet is gone and the page underneath was not popped.
    expect(find.text('12 songs added'), findsNothing);
    expect(find.text('Folders page'), findsOneWidget);
    expect(controller.status.value, ScanSessionStatus.idle);
  });

  testWidgets('Hide hands a running scan to the pill', (tester) async {
    final generation = await openSheet(tester);

    await tester.tap(find.text('Hide'));
    await tester.pumpAndSettle();

    expect(find.text('Folders page'), findsOneWidget);
    expect(controller.isCurrent(generation), isTrue);
    expect(controller.isVisible, isTrue);
    expect(controller.status.value, ScanSessionStatus.running);
  });

  testWidgets('Stop cancels and closes only the sheet', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();

    expect(controller.isActive, isFalse);
    // Cancelled, then cleared once its sheet closed.
    expect(controller.status.value, ScanSessionStatus.idle);
    expect(find.text('Stop'), findsNothing);
    expect(find.text('Folders page'), findsOneWidget);
  });
}
