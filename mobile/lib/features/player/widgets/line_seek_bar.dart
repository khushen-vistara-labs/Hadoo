import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flick/core/utils/app_haptics.dart';
import 'package:flick/core/constants/app_constants.dart';
import 'package:flick/core/theme/app_colors.dart';

class LineSeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final VoidCallback? onCancel;
  final double appearProgress;
  final bool targetStyle;

  const LineSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onChanged,
    this.onChangeEnd,
    this.onCancel,
    this.appearProgress = 1.0,
    this.targetStyle = false,
  });

  @override
  State<LineSeekBar> createState() => _LineSeekBarState();
}

class _LineSeekBarState extends State<LineSeekBar>
    with SingleTickerProviderStateMixin {
  static const double _baseHeight = 24;
  static const double _fineScrubZoom = 2.6;

  bool _isDragging = false;
  bool _isFineScrubbing = false;
  Duration? _interactivePosition;
  double _fineScrubAnchorDx = 0;
  Duration _fineScrubAnchorPosition = Duration.zero;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Duration get _displayPosition => _interactivePosition ?? widget.position;

  Duration _positionFromDx(double dx, double width) {
    final progress = (dx / width).clamp(0.0, 1.0);
    final ms = (progress * widget.duration.inMilliseconds).round();
    return Duration(milliseconds: ms);
  }

  void _updateInteractivePosition(Duration position) {
    _interactivePosition = position;
  }

  void _onDragStart(DragStartDetails details) {
    if (!mounted) return;
    setState(() => _isDragging = true);
  }

  void _onDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_isFineScrubbing) return;
    final width = constraints.maxWidth;
    final position = _positionFromDx(details.localPosition.dx, width);
    setState(() {
      _updateInteractivePosition(position);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    final finalPosition = _displayPosition;
    _interactivePosition = null;
    widget.onChanged(finalPosition);
    AppHaptics.selection();
    widget.onChangeEnd?.call(finalPosition);
    if (mounted) setState(() {});
  }

  void _onTapUp(TapUpDetails details, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final newPos = _positionFromDx(details.localPosition.dx, width);
    widget.onChanged(newPos);
    AppHaptics.selection();
    widget.onChangeEnd?.call(newPos);
  }

  void _onLongPressStart(
    LongPressStartDetails details,
    BoxConstraints constraints,
  ) {
    _pulseController.repeat(reverse: true);
    final anchorPosition = _positionFromDx(
      details.localPosition.dx,
      constraints.maxWidth,
    );
    setState(() {
      _isFineScrubbing = true;
      _fineScrubAnchorDx = details.localPosition.dx;
      _fineScrubAnchorPosition = anchorPosition;
      _updateInteractivePosition(anchorPosition);
    });
  }

  void _onLongPressMoveUpdate(
    LongPressMoveUpdateDetails details,
    BoxConstraints constraints,
  ) {
    final width = constraints.maxWidth;
    final anchorProgress = widget.duration.inMilliseconds == 0
        ? 0.0
        : _fineScrubAnchorPosition.inMilliseconds /
              widget.duration.inMilliseconds;
    final deltaProgress =
        (details.localPosition.dx - _fineScrubAnchorDx) /
        width /
        _fineScrubZoom;
    final progress = (anchorProgress + deltaProgress).clamp(0.0, 1.0);
    final nextPosition = Duration(
      milliseconds: (progress * widget.duration.inMilliseconds).round(),
    );

    setState(() {
      _updateInteractivePosition(nextPosition);
    });
  }

  void _endFineScrub() {
    _pulseController.stop();
    _pulseController.reset();
    final finalPosition = _displayPosition;
    _isFineScrubbing = false;
    _interactivePosition = null;
    widget.onChanged(finalPosition);
    AppHaptics.selection();
    widget.onChangeEnd?.call(finalPosition);
    if (mounted) setState(() {});
  }

  void _cancelScrub() {
    _pulseController.stop();
    _pulseController.reset();
    _isDragging = false;
    _isFineScrubbing = false;
    _interactivePosition = null;
    widget.onCancel?.call();
    if (mounted) setState(() {});
  }

  double _timeIndicatorLeft(double maxWidth, double progress) {
    const popupWidth = 132.0;
    final effectiveWidth = maxWidth - 4;
    final thumbX = 2 + effectiveWidth * progress;
    return (thumbX - popupWidth / 2).clamp(0.0, maxWidth - popupWidth);
  }

  Widget _buildTimeIndicator(bool isFine) {
    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            width: 78,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isFine ? 1.0 : 0.96),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              _formatDuration(_displayPosition),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontFamily: 'HadooMono',
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _cancelScrub,
            borderRadius: BorderRadius.circular(23),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isFine ? 1.0 : 0.96),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.close, color: Colors.black, size: 25),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _effectiveLineHeight {
    if (_isFineScrubbing) return 10;
    if (_isDragging) return 5;
    return widget.targetStyle ? 2.5 : 3;
  }

  double get _effectiveDotRadius {
    if (_isFineScrubbing) return 7;
    if (_isDragging) return 5;
    return widget.targetStyle ? 0 : 3.5;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isScrubbing = _isFineScrubbing || _isDragging;
        final progress = widget.duration.inMilliseconds == 0
            ? 0.0
            : _displayPosition.inMilliseconds / widget.duration.inMilliseconds;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: (details) =>
                  _onDragUpdate(details, constraints),
              onHorizontalDragEnd: _onDragEnd,
              onLongPressStart: (details) =>
                  _onLongPressStart(details, constraints),
              onLongPressMoveUpdate: (details) =>
                  _onLongPressMoveUpdate(details, constraints),
              onLongPressEnd: (_) => _endFineScrub(),
              onTapUp: (details) => _onTapUp(details, constraints),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: AppConstants.animationFast,
                curve: Curves.easeOutCubic,
                height: _baseHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: _isFineScrubbing
                      ? AppColors.glassBackgroundStrong
                      : Colors.transparent,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _LineSeekBarPainter(
                          progress: progress,
                          lineHeight: _effectiveLineHeight,
                          dotRadius: _effectiveDotRadius,
                          targetStyle: widget.targetStyle,
                          glowIntensity: _isFineScrubbing
                              ? _pulseAnimation.value
                              : 0.0,
                          trackColor: widget.targetStyle
                              ? Colors.white.withValues(alpha: 0.28)
                              : AppColors.textTertiary.withValues(alpha: 0.2),
                          activeColor: widget.targetStyle
                              ? Colors.white.withValues(alpha: 0.82)
                              : AppColors.accent,
                          appearProgress: widget.appearProgress,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: -86,
              left: _timeIndicatorLeft(constraints.maxWidth, progress),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                reverseDuration: const Duration(milliseconds: 140),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.86, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: isScrubbing
                    ? KeyedSubtree(
                        key: ValueKey(_displayPosition.inSeconds),
                        child: _buildTimeIndicator(_isFineScrubbing),
                      )
                    : const SizedBox(
                        key: ValueKey('seek-time-hidden'),
                        width: 1,
                        height: 1,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LineSeekBarPainter extends CustomPainter {
  final double progress;
  final double lineHeight;
  final double dotRadius;
  final double glowIntensity;
  final Color trackColor;
  final Color activeColor;
  final double appearProgress;
  final bool targetStyle;

  _LineSeekBarPainter({
    required this.progress,
    required this.lineHeight,
    required this.dotRadius,
    required this.glowIntensity,
    required this.trackColor,
    required this.activeColor,
    required this.appearProgress,
    required this.targetStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final lineTop = centerY - lineHeight / 2;
    final trackWidth = size.width * appearProgress;
    final playedWidth = (trackWidth * progress).clamp(0.0, trackWidth);

    if (trackWidth <= 0) return;

    final trackRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, lineTop, trackWidth, lineHeight),
      Radius.circular(lineHeight / 2),
    );

    final paint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(trackRRect, paint);

    if (playedWidth > 0) {
      final playedRadius = math.min(playedWidth, lineHeight) / 2;
      final playedRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, lineTop, playedWidth, lineHeight),
        Radius.circular(playedRadius),
      );
      paint.color = activeColor;
      canvas.drawRRect(playedRRect, paint);
    }

    final dotX = playedWidth.clamp(0.0, trackWidth);

    final thumbRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(dotX, centerY), width: 4, height: 22),
      const Radius.circular(2),
    );
    paint.color = activeColor;
    canvas.drawRRect(thumbRect, paint);
  }

  @override
  bool shouldRepaint(_LineSeekBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.lineHeight != lineHeight ||
        oldDelegate.dotRadius != dotRadius ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.appearProgress != appearProgress ||
        oldDelegate.targetStyle != targetStyle;
  }
}
