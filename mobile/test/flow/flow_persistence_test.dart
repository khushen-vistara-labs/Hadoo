import 'dart:async';
import 'dart:convert';

import 'package:flick/features/flow/domain/flow_codec.dart';
import 'package:flick/features/flow/domain/flow_models.dart';
import 'package:flick/features/flow/flow_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'settings, bans, history, skip signals and resumable session round trip',
    () {
      final data = FlowData(
        config: FlowConfig(
          mood: FlowMood.chill,
          discovery: .8,
          memory: .2,
          excludedGenres: ['ROCK', 'hip hop'],
        ),
        bannedIds: ['a;=\u001e', 'b'],
        skipCounts: {'c': 2},
        recentIds: ['b', 'c'],
        session: FlowSession(
          trackIds: ['c', 'd'],
          seed: 123,
          builtAtMs: 1791849600000,
          currentId: 'd',
        ),
      );
      final decoded = FlowCodec.decode(FlowCodec.encode(data));
      expect(decoded.config, data.config);
      expect(decoded.bannedIds, data.bannedIds);
      expect(decoded.skipCounts, data.skipCounts);
      expect(decoded.recentIds, data.recentIds);
      expect(decoded.session.trackIds, ['c', 'd']);
      expect(decoded.session.currentId, 'd');
      expect(decoded.session.seed, 123);
      expect(decoded.session.builtAtMs, data.session.builtAtMs);
    },
  );

  test(
    'corrupt documents recover; unknown versions cannot be overwritten silently',
    () {
      for (final text in ['{', 'null', '[]', '42', '{"version":"bad"}']) {
        final decoded = FlowCodec.decode(text);
        expect(decoded.config, FlowConfig());
        expect(decoded.notice, isNotNull);
      }
      expect(() => FlowCodec.decode('{"version":2}'), throwsFormatException);
      expect(FlowCodec.decode(null).notice, isNull);
    },
  );

  test(
    'malformed fields are safely defaulted, bounded, filtered and deduplicated',
    () {
      final data = FlowCodec.decode(
        jsonEncode({
          'version': 1,
          'config': {
            'mood': 'unknown',
            'discovery': 8,
            'memory': -3,
            'excludedGenres': [' Rock ', null, 7],
          },
          'bannedIds': ['ok', 'ok', '', null, 3],
          'skipCounts': {
            'ok': 3,
            'negative': -1,
            'fraction': 1.5,
            'wrong': '3',
          },
          'recentIds': 'bad',
          'session': {
            'trackIds': ['a', 'a', 1, 'b'],
            'seed': -1,
            'builtAtMs': 'yesterday',
            'currentId': 'absent',
          },
        }),
      );
      expect(data.config.discovery, 1);
      expect(data.config.memory, 0);
      expect(data.config.excludedGenres, {'rock'});
      expect(data.bannedIds, {'ok'});
      expect(data.skipCounts, {'ok': 3});
      expect(data.session.trackIds, ['a', 'b']);
      expect(data.session.currentId, isNull);
      expect(data.session.seed, 1);
      expect(data.session.builtAtMs, 0);
      expect(
        FlowConfig(discovery: double.nan, memory: double.infinity),
        FlowConfig(),
      );
    },
  );

  test(
    'IO round trip serializes overlapping writes and recovers after failure',
    () async {
      String? stored;
      final gate = Completer<void>();
      var calls = 0;
      final store = FlowStore(
        read: () async => stored,
        write: (value) async {
          calls++;
          if (calls == 1) await gate.future;
          if (calls == 3) return false;
          stored = value;
          return true;
        },
      );
      final first = store.save(FlowData(config: FlowConfig(memory: .1)));
      final second = store.save(FlowData(config: FlowConfig(memory: .9)));
      await Future<void>.delayed(Duration.zero);
      expect(calls, 1);
      gate.complete();
      await Future.wait([first, second]);
      expect((await store.load()).config.memory, .9);
      await expectLater(store.save(FlowData()), throwsStateError);
      await store.save(FlowData(bannedIds: ['kept']));
      expect((await store.load()).bannedIds, {'kept'});
    },
  );

  test(
    'tuner mutations and cancellation never change committed configuration',
    () {
      final committed = FlowConfig(excludedGenres: ['metal']);
      final draft = FlowTunerDraft(committed);
      draft.value = draft.value.copyWith(
        mood: FlowMood.party,
        discovery: 1,
        memory: 0,
      );
      draft.setGenreEnabled('Jazz', false);
      draft.setGenreEnabled('metal', true);
      expect(committed, FlowConfig(excludedGenres: ['metal']));
      expect(draft.isDirty, isTrue);
      expect(draft.cancel(), committed);
      expect(draft.isDirty, isFalse);
      draft.value = draft.value.copyWith(mood: FlowMood.focus);
      final applied = draft.apply();
      expect(applied.mood, FlowMood.focus);
      expect(committed.mood, FlowMood.flow);
      expect(() => applied.excludedGenres.add('pop'), throwsUnsupportedError);
    },
  );
}
