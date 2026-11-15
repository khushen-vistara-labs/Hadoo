import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A heart that pops and a ring of accent particles, played once over the
/// Now Playing artwork when it is double-tapped (design flow §6.2: heart
/// 1 → 1.25 → 1 plus a burst, 600 ms).
class LokalLikeBurst extends StatefulWidget {
  const LokalLikeBurst({
    super.key,
    required this.color,
    this.size = 96,
    this.onDone,
  });

  final Color color;
  final double size;
  final VoidCallback? onDone;

  @override
  State<LokalLikeBurst> createState() => _LokalLikeBurstState();
}

class _LokalLikeBurstState extends State<LokalLikeBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward().whenComplete(() => widget.onDone?.call());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          // 0 → 1.25 over the first 40%, settle to 1, fade over the last 30%.
          final scale = t < .4
              ? Curves.easeOutBack.transform(t / .4) * 1.25
              : 1.25 - .25 * Curves.easeOut.transform((t - .4) / .6);
          final opacity = t < .7 ? 1.0 : 1 - (t - .7) / .3;
          return SizedBox.square(
            dimension: widget.size * 2,
            child: CustomPaint(
              painter: _BurstPainter(progress: t, color: widget.color),
              child: Center(
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: scale,
                    child: Icon(
                      Icons.favorite_rounded,
                      size: widget.size,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: widget.color.withValues(alpha: .6),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  static const _count = 10;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < .15) return;
    final t = Curves.easeOutCubic.transform((progress - .15) / .85);
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    final paint = Paint()..color = color.withValues(alpha: 1 - t);
    for (var i = 0; i < _count; i++) {
      final angle = i / _count * math.pi * 2 - math.pi / 2;
      final distance = maxRadius * (.35 + .6 * t);
      final dot = center + Offset(math.cos(angle), math.sin(angle)) * distance;
      canvas.drawCircle(dot, (i.isEven ? 6 : 4) * (1 - t * .6), paint);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) =>
      old.progress != progress || old.color != color;
}
