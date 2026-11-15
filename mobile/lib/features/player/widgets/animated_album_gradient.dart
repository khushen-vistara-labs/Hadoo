import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A slowly moving, album-derived backdrop for the expanded player.
///
/// The cover itself remains crisp in the foreground. This layer turns several
/// sampled album-art colors into a dark, colorful field and moves those color
/// pools around the screen. Every animated value is a whole-number sine/cosine
/// harmonic, so the end of the loop is identical to its beginning.
class AnimatedAlbumGradient extends StatefulWidget {
  const AnimatedAlbumGradient({
    super.key,
    required this.albumColor,
    required this.palette,
    required this.songKey,
  });

  final Color? albumColor;
  final List<Color> palette;
  final String songKey;

  @override
  State<AnimatedAlbumGradient> createState() => _AnimatedAlbumGradientState();
}

class _AnimatedAlbumGradientState extends State<AnimatedAlbumGradient>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedAlbumGradient oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songKey != widget.songKey) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _tone(Color color, {required double mix, double hueShift = 0}) {
    final base = HSLColor.fromColor(color);
    final hue = (base.hue + hueShift) % 360.0;
    return base
        .withHue(hue < 0 ? hue + 360.0 : hue)
        .withSaturation((base.saturation * 3.2).clamp(0.72, 1.0))
        .withLightness((0.08 + base.lightness * mix).clamp(0.08, 0.5))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final source = <Color>[
      ...widget.palette,
      if (widget.albumColor != null) widget.albumColor!,
    ];
    if (source.isEmpty) source.add(const Color(0xFF3B3455));

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final phase = _controller.value * math.pi * 2;
          final pulse = math.sin(phase);
          final driftX = math.cos(phase);
          final driftY = math.sin(phase * 2);
          final colors = List<Color>.generate(5, (index) {
            final color = source[index % source.length];
            const hueSpread = <double>[0.0, 26.0, -30.0, 48.0, -54.0];
            return _tone(
              color,
              mix: 0.62 + pulse * 0.08,
              hueShift: hueSpread[index] + driftX * 7.0,
            );
          });

          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors[0], colors[1], colors[2], colors[3]],
                    stops: const [0.0, 0.31, 0.66, 1.0],
                  ),
                ),
              ),
              for (var index = 0; index < 5; index++)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        -0.78 + driftX * 0.42 + index * 0.22,
                        -0.72 + driftY * 0.32 + (index % 2) * 0.72,
                      ),
                      radius: 0.98 + (index % 3) * 0.16,
                      colors: [
                        colors[index].withValues(alpha: 0.46),
                        colors[index].withValues(alpha: 0.14),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.38, 1.0],
                    ),
                  ),
                ),
              const ColoredBox(color: Color(0x04000000)),
            ],
          );
        },
      ),
    );
  }
}
