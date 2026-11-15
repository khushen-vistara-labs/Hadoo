import 'package:flutter/material.dart';

/// Material-style vertical handle shared by player seek and volume sliders.
class MaterialPlayerThumb extends SliderComponentShape {
  const MaterialPlayerThumb();
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(4, 24);
  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter? labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 4, height: 24),
        const Radius.circular(2),
      ),
      Paint()..color = sliderTheme.thumbColor ?? Colors.white,
    );
  }
}
