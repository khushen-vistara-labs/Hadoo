import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// The motion behind Now Playing's in-place queue: one 0..1 value (0 = the
/// full artwork, 1 = the queue) that a finger moves directly and a spring
/// settles. Every piece of the reveal reads off [controller], so a drag, a
/// tap on the queue button and Back all run the same animation, and any of
/// them can take over from another mid-flight.
class LokalQueueRevealMotion extends ChangeNotifier {
  LokalQueueRevealMotion(this.controller);

  /// Bounded 0..1; owned (and disposed) by the caller.
  final AnimationController controller;

  /// A release carries on to the other end once the reveal has travelled
  /// this share of the way; deliberately under half, because nothing else
  /// starts the gesture by accident.
  static const double carryFraction = .3;

  /// A release faster than this (logical px/s) decides on its own.
  static const double flickVelocity = 450;

  /// Close to critically damped: it lands without wobbling.
  static const SpringDescription spring = SpringDescription(
    mass: 1,
    stiffness: 380,
    damping: 36,
  );

  /// How far a finger travels for the whole reveal, in logical pixels.
  double travel = 320;

  bool _open = false;

  /// Where the reveal is heading (or resting), as opposed to [value].
  bool get isOpen => _open;

  double get value => controller.value;

  /// Moves the reveal with the finger; [upPx] is positive when pulling up.
  void dragBy(double upPx) {
    if (controller.isAnimating) controller.stop();
    final next = (controller.value + upPx / math.max(travel, 1)).clamp(
      0.0,
      1.0,
    );
    controller.value = next;
  }

  /// Settles after a drag; [upVelocity] is in logical px/s, positive upward.
  /// Returns whether the reveal is now heading open.
  bool release(double upVelocity, {bool animate = true}) {
    final bool open;
    if (upVelocity >= flickVelocity) {
      open = true;
    } else if (upVelocity <= -flickVelocity) {
      open = false;
    } else if (_open) {
      open = controller.value > 1 - carryFraction;
    } else {
      open = controller.value >= carryFraction;
    }
    setOpen(open, velocity: upVelocity / math.max(travel, 1), animate: animate);
    return open;
  }

  /// Opens or closes from wherever the reveal is now, carrying [velocity]
  /// (progress per second). Without [animate] it jumps straight there.
  void setOpen(bool open, {double velocity = 0, bool animate = true}) {
    if (_open != open) {
      _open = open;
      notifyListeners();
    }
    final target = open ? 1.0 : 0.0;
    if (!animate) {
      controller.stop();
      controller.value = target;
      return;
    }
    if (controller.value == target && velocity == 0) return;
    controller
        .animateWith(
          SpringSimulation(spring, controller.value, target, velocity),
        )
        // A spring counts as settled within a hair of its target (1e-6
        // short after a fling down): land exactly, or the player still
        // sees the queue as part-way out and keeps the pull-up blocked.
        // Not on a cancel: a finger that takes over keeps its place.
        .then((_) {
          if (_open == open && !controller.isAnimating) {
            controller.value = target;
          }
        });
  }

  /// Whether the reveal is out or on its way, so the sheet under it should
  /// leave vertical drags alone.
  bool get engaged => _open || controller.isAnimating;

  void toggle({bool animate = true}) => setOpen(!_open, animate: animate);
}

/// Now Playing's artwork block that turns into the queue in place: the cover
/// shrinks into a small thumbnail in the top-left corner, the title slides up
/// beside it and the queue list rises into the space underneath, all driven by
/// [progress]. Once open, the header row (thumbnail and title) takes a tap or a
/// downward drag to put the queue away again.
class LokalQueueReveal extends StatelessWidget {
  const LokalQueueReveal({
    super.key,
    required this.progress,
    required this.open,
    required this.artwork,
    required this.info,
    required this.queue,
    this.badge,
    this.artGap = 16,
    this.thumbSize = 56,
    this.onHeaderTap,
    this.onHeaderDragUpdate,
    this.onHeaderDragEnd,
  });

  final Animation<double> progress;

  /// Whether the queue is open (or opening): enables the header's gestures
  /// and the queue's hit testing.
  final bool open;

  /// The cover, given the slot's width and the cover's [size]. Place it with
  /// [coverAlignment] so it travels from the centre to the left edge.
  final Widget Function(BuildContext context, double size, double progress)
  artwork;

  /// Title and subtitle; laid out at the width the reveal gives it.
  final Widget Function(BuildContext context, double progress) info;

  /// Shown under the title on the full player only; fades out first.
  final Widget? badge;

  final Widget queue;
  final double artGap;
  final double thumbSize;
  final VoidCallback? onHeaderTap;

  /// Positive when pulling up, as [LokalQueueRevealMotion.dragBy].
  final ValueChanged<double>? onHeaderDragUpdate;

  /// Release velocity in logical px/s, positive upward.
  final ValueChanged<double>? onHeaderDragEnd;

  static Alignment coverAlignment(double progress) =>
      Alignment(-progress.clamp(0.0, 1.0), 0);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      child: queue,
      builder: (context, queueChild) {
        final p = progress.value.clamp(0.0, 1.0);
        final queueOpacity = Curves.easeOut.transform(
          ((p - .3) / .7).clamp(0.0, 1.0),
        );
        final badgeOpacity = (1 - p / .35).clamp(0.0, 1.0);
        final showQueue = p > 0 || open;
        return CustomMultiChildLayout(
          delegate: _RevealLayout(
            progress: p,
            thumbSize: thumbSize,
            artGap: artGap,
          ),
          children: [
            LayoutId(
              id: _Slot.art,
              child: _ArtSlot(builder: artwork, progress: p),
            ),
            LayoutId(id: _Slot.info, child: info(context, p)),
            if (badge != null)
              LayoutId(
                id: _Slot.badge,
                child: IgnorePointer(
                  ignoring: p > 0,
                  child: Opacity(opacity: badgeOpacity, child: badge),
                ),
              ),
            if (showQueue)
              LayoutId(
                id: _Slot.queue,
                child: IgnorePointer(
                  ignoring: !open,
                  child: Opacity(opacity: queueOpacity, child: queueChild),
                ),
              ),
            if (open)
              LayoutId(
                id: _Slot.header,
                child: GestureDetector(
                  key: const ValueKey('lokal-queue-reveal-header'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onHeaderTap,
                  onVerticalDragUpdate: onHeaderDragUpdate == null
                      ? null
                      : (d) => onHeaderDragUpdate!(-d.delta.dy),
                  onVerticalDragEnd: onHeaderDragEnd == null
                      ? null
                      : (d) => onHeaderDragEnd!(-(d.primaryVelocity ?? 0)),
                ),
              ),
          ],
        );
      },
    );
  }
}

enum _Slot { art, info, badge, queue, header }

/// Hands the cover builder the size the layout gave the slot.
class _ArtSlot extends StatelessWidget {
  const _ArtSlot({required this.builder, required this.progress});

  final Widget Function(BuildContext, double, double) builder;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => builder(context, c.maxHeight, progress),
    );
  }
}

class _RevealLayout extends MultiChildLayoutDelegate {
  _RevealLayout({
    required this.progress,
    required this.thumbSize,
    required this.artGap,
  });

  final double progress;
  final double thumbSize;
  final double artGap;

  static const double _headerGap = 12;
  static const double _badgeGap = 8;
  static const double _bottomPad = 6;

  @override
  void performLayout(Size size) {
    final p = progress;
    final w = size.width;
    final h = size.height;

    final infoWidth = math.max(0.0, lerpDouble(w, w - thumbSize - 12, p)!);
    final infoSize = layoutChild(
      _Slot.info,
      BoxConstraints(minWidth: infoWidth, maxWidth: infoWidth, maxHeight: h),
    );
    var badgeBlock = 0.0;
    if (hasChild(_Slot.badge)) {
      final badgeSize = layoutChild(_Slot.badge, BoxConstraints.loose(size));
      badgeBlock = _badgeGap + badgeSize.height;
    }

    // Keep the cover and song information together, with a fixed art-to-title gap.
    final coverRoom = math.max(
      0.0,
      h - artGap - infoSize.height - badgeBlock - _bottomPad,
    );
    final fullSide = math.min(w, coverRoom);
    final artSize = math.max(0.0, lerpDouble(fullSide, thumbSize, p)!);
    final artTop = lerpDouble((coverRoom - fullSide) / 2, 0, p)!;
    layoutChild(_Slot.art, BoxConstraints.tightFor(width: w, height: artSize));
    positionChild(_Slot.art, Offset(0, artTop));

    final infoTop = lerpDouble(
      (coverRoom - fullSide) / 2 + fullSide + artGap,
      (thumbSize - infoSize.height) / 2,
      p,
    )!;
    final infoLeft = lerpDouble(0, thumbSize + 12, p)!;
    positionChild(_Slot.info, Offset(infoLeft, infoTop));
    if (hasChild(_Slot.badge)) {
      positionChild(
        _Slot.badge,
        Offset(infoLeft, infoTop + infoSize.height + _badgeGap),
      );
    }

    final headerHeight = math.min(h, thumbSize + _headerGap);
    if (hasChild(_Slot.queue)) {
      final queueHeight = math.max(0.0, h - headerHeight);
      layoutChild(
        _Slot.queue,
        BoxConstraints.tightFor(width: w, height: queueHeight),
      );
      // Rises into place as the cover leaves.
      positionChild(
        _Slot.queue,
        Offset(0, headerHeight + (1 - p) * queueHeight * .35),
      );
    }
    if (hasChild(_Slot.header)) {
      layoutChild(
        _Slot.header,
        BoxConstraints.tightFor(width: w, height: headerHeight),
      );
      positionChild(_Slot.header, Offset.zero);
    }
  }

  @override
  bool shouldRelayout(_RevealLayout old) =>
      old.progress != progress ||
      old.thumbSize != thumbSize ||
      old.artGap != artGap;
}
