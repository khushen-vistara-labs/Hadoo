import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flick/widgets/common/cached_image_widget.dart';

/// Full-screen album art backdrop used by the artwork-card player.
///
/// The reference player does not use a palette gradient. It uses the current
/// cover enlarged beyond the viewport, blurred heavily, and drifted slowly so
/// the cover remains recognizable in the color and light of the background.
class AnimatedBlurredAlbumBackdrop extends StatefulWidget {
  final String? imagePath;
  final String? audioSourcePath;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AnimatedBlurredAlbumBackdrop({
    super.key,
    this.imagePath,
    this.audioSourcePath,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<AnimatedBlurredAlbumBackdrop> createState() =>
      _AnimatedBlurredAlbumBackdropState();
}

class _AnimatedBlurredAlbumBackdropState
    extends State<AnimatedBlurredAlbumBackdrop>
    with SingleTickerProviderStateMixin {
  final math.Random _random = math.Random();
  late final AnimationController _controller;
  late double _startX;
  late double _endX;
  late double _startY;
  late double _endY;
  late double _travelScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..addStatusListener(_handleAnimationStatus);
    _randomizeMotion();
  }

  void _randomizeMotion() {
    final horizontalDirection = _random.nextBool() ? 1.0 : -1.0;
    final verticalDirection = _random.nextBool() ? 1.0 : -1.0;
    // The endpoints deliberately sit near opposite corners of the enlarged
    // crop. This makes the starting frame visibly different from the center
    // rather than looking like a gently animated centered cover.
    _startX = horizontalDirection * (0.32 + _random.nextDouble() * 0.16);
    _startY = verticalDirection * (0.27 + _random.nextDouble() * 0.14);
    _endX = -horizontalDirection * (0.32 + _random.nextDouble() * 0.16);
    _endY = -verticalDirection * (0.27 + _random.nextDouble() * 0.14);
    _travelScale = 2.80 + _random.nextDouble() * 0.35;
    _controller
      ..value = 0
      ..forward();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.reverse();
    } else if (status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedBlurredAlbumBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath ||
        oldWidget.audioSourcePath != widget.audioSourcePath) {
      _randomizeMotion();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placeholder =
        widget.placeholder ?? const ColoredBox(color: Color(0xFF17120F));
    final image = AnimatedSwitcher(
      duration: const Duration(milliseconds: 460),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) => Stack(
        fit: StackFit.expand,
        children: [
          ...previous,
          ...?current == null ? null : [current],
        ],
      ),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(
        key: ValueKey('${widget.imagePath}|${widget.audioSourcePath}'),
        child: CachedImageWidget(
          imagePath: widget.imagePath,
          audioSourcePath: widget.audioSourcePath,
          fit: BoxFit.cover,
          placeholder: placeholder,
          errorWidget: widget.errorWidget ?? placeholder,
        ),
      ),
    );

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // The album image is already blurred inside its *own*
                // repaint boundary. Moving/scaling that composited surface
                // avoids re-filtering a 3x oversized image every frame.
                // Preserve the original ~30px displayed blur by applying a
                // ~10px blur before the ~3x transform.
                final t = Curves.easeInOut.transform(_controller.value);
                final x = ui.lerpDouble(_startX, _endX, t)!;
                final y = ui.lerpDouble(_startY, _endY, t)!;
                final scale = _travelScale + math.sin(t * math.pi) * 0.025;
                return Transform(
                  key: const ValueKey('animated-backdrop-motion'),
                  alignment: Alignment.center,
                  transform: Matrix4.translationValues(
                    x * MediaQuery.sizeOf(context).width,
                    y * MediaQuery.sizeOf(context).height,
                    0,
                  )..scaleByDouble(scale, scale, scale, 1.0),
                  child: child,
                );
              },
              child: RepaintBoundary(
                key: const ValueKey('cached-backdrop-blur'),
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: image,
                ),
              ),
            ),
          ),
          // Keep the blurred cover legible behind the controls. The old
          // overlay was almost forty percent black and made the background
          // look like a flat brown gradient on darker covers.
          const ColoredBox(color: Color(0x26000000)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x18000000),
                  Color(0x04000000),
                  Color(0x18000000),
                ],
                stops: [0.0, 0.48, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
