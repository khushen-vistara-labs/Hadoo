import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flick/services/lyrics_sources.dart';
import 'package:flick/widgets/lokal/settings/lokal_settings_kit.dart';

class LyricsSourcesPanel extends ConsumerWidget {
  const LyricsSourcesPanel({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(lyricsSourcesProvider);
    final notifier = ref.read(lyricsSourcesProvider.notifier);
    return Column(
      children: [
        const LokalSettingRow(
          label: 'Lyrics sources',
          description: 'Your own lyrics come first. Online sources are tried in this order when automatic lookup is enabled. You can also pick a source in the player.',
        ),
        LokalSettingRow.toggle(
          label: 'Prefer word timing',
          description:
              'Keep searching after a line-timed match for word-timed lyrics.',
          value: settings.preferWords,
          onChanged: (value) => unawaited(notifier.set(preferWords: value)),
        ),
        for (var i = 0; i < settings.order.length; i++)
          LokalSettingRow(
            label: lyricsSources[settings.order[i]]!,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch.adaptive(
                  value: !settings.disabled.contains(settings.order[i]),
                  onChanged: (on) {
                    final next = {...settings.disabled};
                    if (on) {
                      next.remove(settings.order[i]);
                    } else {
                      next.add(settings.order[i]);
                    }
                    unawaited(notifier.set(disabled: next));
                  },
                ),
                IconButton(
                  tooltip: 'Move source up',
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                  onPressed: i == 0
                      ? null
                      : () {
                          final order = [...settings.order];
                          final value = order.removeAt(i);
                          order.insert(i - 1, value);
                          unawaited(notifier.set(order: order));
                        },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
