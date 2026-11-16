import 'package:flutter/material.dart';

import 'package:flick/l10n/l10n.dart';

import 'full_player_visuals.dart';

/// The title gets its own space on phones, and the controls wrap at their
/// normal touch size when the available width cannot fit a single action row.
class FullPlayerLyricsToolbar extends StatelessWidget {
  const FullPlayerLyricsToolbar({
    super.key,
    required this.actions,
    this.timing,
  });

  final List<Widget> actions;
  final String? timing;

  @override
  Widget build(BuildContext context) {
    final heading = Row(
      children: [
        Expanded(
          child: Text(
            l10n.lyrics,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'HadooMono',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FullPlayerVisuals.primaryText,
            ),
          ),
        ),
        if (timing case final label?)
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                color: FullPlayerVisuals.secondaryText,
              ),
            ),
          ),
      ],
    );
    final controls = IconTheme.merge(
      data: const IconThemeData(color: FullPlayerVisuals.primaryText),
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: actions,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 500) {
            return Row(
              children: [
                Expanded(child: heading),
                const SizedBox(width: 12),
                controls,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [heading, const SizedBox(height: 4), controls],
          );
        },
      ),
    );
  }
}
