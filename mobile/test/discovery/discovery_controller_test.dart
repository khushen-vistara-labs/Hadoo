import 'dart:async';

import 'package:flick/features/discovery/discovery_controller.dart';
import 'package:flick/features/discovery/discovery_models.dart';
import 'package:flutter_test/flutter_test.dart';

DiscoverySearchResults result(String title) => DiscoverySearchResults(
  tracks: [
    DiscoveryTrack(
      id: title,
      title: title,
      artist: 'Fixture artist',
      source: DiscoverySource.youtubeMusic,
    ),
  ],
);

void main() {
  testWidgets('debounces typing and immediately invalidates stale successes', (
    tester,
  ) async {
    final calls = <String>[];
    final pending = <String, Completer<DiscoverySearchResults>>{};
    final controller = DiscoveryController(
      search: (q) {
        calls.add(q);
        return (pending[q] = Completer<DiscoverySearchResults>()).future;
      },
    );
    addTearDown(controller.dispose);
    controller.updateQuery('a');
    await tester.pump(const Duration(milliseconds: 200));
    controller.updateQuery('ab');
    await tester.pump(const Duration(milliseconds: 400));
    expect(calls, ['ab']);
    controller.updateQuery('abc');
    pending['ab']!.complete(result('old'));
    await tester.pump();
    expect(controller.results.tracks, isEmpty);
    expect(controller.loading, isTrue);
    await tester.pump(const Duration(milliseconds: 400));
    pending['abc']!.complete(result('new'));
    await tester.pump();
    expect(controller.results.tracks.single.title, 'new');
    expect(controller.loading, isFalse);
  });

  testWidgets('late failure cannot overwrite newer results', (tester) async {
    final old = Completer<DiscoverySearchResults>();
    final controller = DiscoveryController(
      search: (q) => q == 'old' ? old.future : Future.value(result('new')),
    );
    addTearDown(controller.dispose);
    controller.updateQuery('old', immediate: true);
    controller.updateQuery('new', immediate: true);
    await tester.pump();
    old.completeError(const DiscoveryException('old error'));
    await tester.pump();
    expect(controller.results.tracks.single.title, 'new');
    expect(controller.results.errors, isEmpty);
  });

  testWidgets('clear, opt-out reconfiguration and dispose invalidate work', (
    tester,
  ) async {
    final pending = Completer<DiscoverySearchResults>();
    final controller = DiscoveryController(search: (_) => pending.future);
    controller.updateQuery('query', immediate: true);
    controller.updateQuery('');
    expect(controller.loading, isFalse);
    pending.complete(result('old'));
    await tester.pump();
    expect(controller.results.tracks, isEmpty);
    final second = Completer<DiscoverySearchResults>();
    controller.configure((_) => second.future);
    controller.updateQuery('query', immediate: true);
    controller.configure((_) async => const DiscoverySearchResults());
    second.complete(result('disabled source'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(controller.results.tracks, isEmpty);
    controller.updateQuery('pending timer');
    controller.dispose();
    await tester.pump(const Duration(seconds: 1));
  });
}
