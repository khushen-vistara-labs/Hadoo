import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'marquee_widget.dart';

/// Horizontally pans only if the title is wider than its available space.
/// Uses the same animation in the full player and both mini-player layouts.
/// Respects reduced motion and pauses when the subtree is offstage.
class OverflowMarqueeTitle extends StatelessWidget {
  const OverflowMarqueeTitle({
    super.key,
    required this.title,
    required this.style,
    this.enabled = true,
  });

  final String title;
  final TextStyle style;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final normal = Text(title,
        maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
    if (!enabled || MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) return normal;
    return LayoutBuilder(builder: (context, constraints) {
      if (!constraints.hasBoundedWidth || constraints.maxWidth <= 0) {
        return normal;
      }
      final painter = TextPainter(
        text: TextSpan(text: title, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      final overflow = painter.width - constraints.maxWidth;
      final height = painter.height + 2;
      painter.dispose();
      if (overflow <= 1) return normal;
      // Constant perceptual scrolling speed, regardless of title length.
      final travelMs = math.max(2200, (overflow / 35 * 1000).round());
      return SizedBox(
        width: constraints.maxWidth,
        height: height,
        child: ClipRect(
          child: MarqueeWidget(
            key: ValueKey(title),
            animationDuration: Duration(milliseconds: travelMs),
            pauseDuration: const Duration(milliseconds: 1200),
            backDuration: const Duration(milliseconds: 900),
            child: Text(title, maxLines: 1, softWrap: false, style: style),
          ),
        ),
      );
    });
  }
}
