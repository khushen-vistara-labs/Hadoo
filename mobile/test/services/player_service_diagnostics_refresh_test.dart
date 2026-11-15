import 'dart:async';

import 'package:flick/services/player_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('continuous progress does not starve diagnostics refresh', (
    tester,
  ) async {
    Timer? pending;
    var latestTick = 0;
    final snapshots = <int>[];

    for (var tick = 1; tick <= 12; tick++) {
      latestTick = tick;
      pending = coalescePlaybackDiagnosticsRefresh(
        pending: pending,
        interval: const Duration(milliseconds: 300),
        refresh: () {
          pending = null;
          snapshots.add(latestTick);
        },
      );
      await tester.pump(const Duration(milliseconds: 50));
    }

    pending?.cancel();
    expect(snapshots, [6, 12]);
  });

  testWidgets('a cancelled diagnostics deadline can be replaced', (tester) async {
    var oldRefreshes = 0;
    var newRefreshes = 0;
    final cancelled = coalescePlaybackDiagnosticsRefresh(
      pending: null,
      interval: const Duration(milliseconds: 300),
      refresh: () => oldRefreshes++,
    );
    cancelled.cancel();
    final replacement = coalescePlaybackDiagnosticsRefresh(
      pending: cancelled,
      interval: const Duration(milliseconds: 300),
      refresh: () => newRefreshes++,
    );

    await tester.pump(const Duration(milliseconds: 300));
    replacement.cancel();
    expect(identical(cancelled, replacement), isFalse);
    expect(oldRefreshes, 0);
    expect(newRefreshes, 1);
  });
}
