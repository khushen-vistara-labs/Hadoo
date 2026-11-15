import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flick/features/spotify/spotify_oauth.dart';
import 'package:flick/features/settings/widgets/spotify_cookie_dialog.dart';

void main() {
  testWidgets(
    'failed verification retains the entered cookie and allows retry',
    (tester) async {
      var attempts = 0;
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (_) => SpotifyCookieDialog(
                    onConnect: (value) async {
                      expect(value, 'fixture-cookie');
                      if (++attempts == 1)
                        throw const SpotifyOAuthException(
                          'Web player could not load.',
                        );
                    },
                    onCancel: () async {},
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'fixture-cookie');
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();
      expect(find.text('Web player could not load.'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'fixture-cookie',
      );
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(result, true);
    },
  );
  testWidgets(
    'pending verification can be cancelled without reporting success',
    (tester) async {
      final pending = Completer<void>();
      var cancelled = false;
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (_) => SpotifyCookieDialog(
                    onConnect: (_) => pending.future,
                    onCancel: () async {
                      cancelled = true;
                    },
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'fixture-cookie');
      await tester.tap(find.text('Connect'));
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      pending.complete();
      await tester.pumpAndSettle();
      expect(cancelled, true);
      expect(result, false);
      expect(tester.takeException(), isNull);
    },
  );
}
