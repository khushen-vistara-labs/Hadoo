import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flick/core/theme/adaptive_color_provider.dart';

/// A repeating pour with rippling coffee and drifting steam, then a soft reset.
/// The parent button owns the tap action, tooltip, and accessibility label.
class DonationCoffeeIcon extends StatefulWidget {
  const DonationCoffeeIcon({super.key});

  @override
  State<DonationCoffeeIcon> createState() => _DonationCoffeeIconState();
}

class _DonationCoffeeIconState extends State<DonationCoffeeIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final AppLifecycleListener _lifecycleListener;
  bool _reduceMotion = false;
  bool _visible = true;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    _foreground =
        lifecycleState == null || lifecycleState == AppLifecycleState.resumed;
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        _foreground = state == AppLifecycleState.resumed;
        _syncAnimation();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _visible = TickerMode.valuesOf(context).enabled;
    _syncAnimation();
  }

  void _syncAnimation() {
    if (_reduceMotion) {
      // A static full mug with steam, without running a ticker.
      _controller.value = 0.6;
    } else if (!_visible || !_foreground) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: const Size.square(40),
        painter: _CoffeePainter(
          progress: _controller,
          reducedMotion: _reduceMotion,
          outlineColor: context.adaptiveTextSecondary,
          coffeeColor: context.isAdaptiveBackgroundDark
              ? const Color(0xFFC89B6D)
              : const Color(0xFF8A5937),
        ),
      ),
    );
  }
}

class _CoffeePainter extends CustomPainter {
  _CoffeePainter({
    required this.progress,
    required this.reducedMotion,
    required this.outlineColor,
    required this.coffeeColor,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final bool reducedMotion;
  final Color outlineColor;
  final Color coffeeColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 40, size.height / 40);

    final time = progress.value;
    final fill =
        const Interval(0.1, 0.4, curve: Curves.easeInOut).transform(time) *
        (1 -
            const Interval(
              0.87,
              0.98,
              curve: Curves.easeInOut,
            ).transform(time));
    final surfaceY = 35 - fill * 15;
    final pourOpacity =
        const Interval(0.06, 0.12).transform(time) *
        (1 - const Interval(0.4, 0.45).transform(time));
    final wave = reducedMotion
        ? 0.0
        : math.sin(time * math.pi * 16) * (0.35 + pourOpacity * 0.45) * fill;
    final cup = Path()
      ..moveTo(7, 18)
      ..lineTo(29, 18)
      ..lineTo(29, 29)
      ..quadraticBezierTo(29, 35, 23, 35)
      ..lineTo(13, 35)
      ..quadraticBezierTo(7, 35, 7, 29)
      ..close();

    final outline = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Clip the coffee to the mug rather than growing or moving the icon.
    if (fill > 0) {
      canvas.save();
      canvas.clipPath(cup);
      final surface = Path()
        ..moveTo(7, surfaceY)
        ..cubicTo(13, surfaceY - wave, 23, surfaceY + wave, 29, surfaceY);
      final liquid = Path.from(surface)
        ..lineTo(29, 35)
        ..lineTo(7, 35)
        ..close();
      canvas.drawPath(
        liquid,
        Paint()..color = coffeeColor.withValues(alpha: 0.75),
      );
      canvas.drawPath(
        surface,
        Paint()
          ..color = coffeeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      canvas.restore();
    }

    if (pourOpacity > 0) {
      final sway = math.sin(time * math.pi * 20) * 0.6;
      canvas.drawPath(
        Path()
          ..moveTo(18, 3)
          ..cubicTo(18 + sway, 10, 18 - sway, 16, 18, surfaceY),
        Paint()
          ..color = coffeeColor.withValues(alpha: pourOpacity * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
      );
      // A tiny spreading ripple where the stream meets the coffee.
      final ripple = (time * 12) % 1;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(18, surfaceY),
          width: 2 + ripple * 7,
          height: 0.8 + ripple * 1.4,
        ),
        Paint()
          ..color = coffeeColor.withValues(alpha: pourOpacity * (1 - ripple))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    canvas.drawPath(
      Path()
        ..moveTo(29, 21)
        ..lineTo(32, 21)
        ..cubicTo(39, 21, 39, 30, 32, 30)
        ..lineTo(29, 30),
      outline,
    );
    canvas.drawPath(cup, outline);
    canvas.drawLine(const Offset(5, 38), const Offset(32, 38), outline);

    // Stagger the wisps so the full cup continues to feel warm and alive.
    final warmth =
        const Interval(0.36, 0.46).transform(time) *
        (1 - const Interval(0.82, 0.91).transform(time));
    for (var i = 0; i < 3; i++) {
      final steam = reducedMotion ? 0.4 + i * 0.12 : (time * 3 + i / 3) % 1;
      final opacity = math.sin(steam * math.pi) * warmth;
      if (opacity <= 0) continue;
      final drift = math.sin(steam * math.pi * 2 + i) * 1.3;
      final x = 12.0 + i * 6 + drift;
      final y = 16 - steam * 6;
      final bend = 2 + math.sin(steam * math.pi * 2) * 0.8;
      canvas.drawPath(
        Path()
          ..moveTo(x, y)
          ..cubicTo(x - bend, y - 3, x + bend, y - 5, x + drift * 0.4, y - 8),
        Paint()
          ..color = outlineColor.withValues(alpha: opacity * 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CoffeePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.reducedMotion != reducedMotion ||
        oldDelegate.outlineColor != outlineColor ||
        oldDelegate.coffeeColor != coffeeColor;
  }
}
