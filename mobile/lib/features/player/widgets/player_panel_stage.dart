import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flick/l10n/l10n.dart';

/// One cover and title move into the compact row below the lyrics.
class PlayerPanelStage extends StatelessWidget {
  const PlayerPanelStage({
    super.key,
    required this.lyricsProgress,
    required this.lyricsOpen,
    required this.artwork,
    required this.info,
    required this.lyrics,
    this.artGap = 16,
    this.infoReserve = 72,
    this.onLyricsCoverReturn,
  });

  final Animation<double> lyricsProgress;
  final bool lyricsOpen;
  final Widget Function(BuildContext, double, double) artwork;
  final Widget Function(BuildContext, double) info;
  final Widget lyrics;
  final double artGap;
  final double infoReserve;
  final VoidCallback? onLyricsCoverReturn;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: lyricsProgress,
    builder: (context, _) {
      final progress = lyricsProgress.value.clamp(0.0, 1.0);
      final opacity = Curves.easeOut.transform(
        ((progress - .12) / .88).clamp(0.0, 1.0),
      );
      return ClipRect(
        child: CustomMultiChildLayout(
          delegate: _PanelLayout(
            lyrics: progress,
            artGap: artGap,
            infoReserve: MediaQuery.textScalerOf(context).scale(infoReserve),
          ),
          children: [
            LayoutId(
              id: _Part.lyrics,
              child: IgnorePointer(
                ignoring: !lyricsOpen,
                child: ExcludeSemantics(
                  excluding: !lyricsOpen,
                  child: TickerMode(
                    enabled: opacity > 0,
                    child: Opacity(
                      opacity: opacity,
                      child: RepaintBoundary(child: lyrics),
                    ),
                  ),
                ),
              ),
            ),
            LayoutId(
              id: _Part.art,
              child: LayoutBuilder(
                builder: (context, c) => RepaintBoundary(
                  child: artwork(context, c.maxWidth, progress),
                ),
              ),
            ),
            LayoutId(id: _Part.info, child: info(context, progress)),
            LayoutId(
              id: _Part.header,
              child: IgnorePointer(
                ignoring: !lyricsOpen,
                child: ExcludeSemantics(
                  excluding: !lyricsOpen,
                  child: _LyricsCoverReturnTarget(
                    onReturn: onLyricsCoverReturn,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// The full-size artwork target used by both the player panel layout and
/// Space's reveal. Matching these calculations prevents the rounded Space
/// cutout drifting from the cover when Space opens directly from Lyrics.
@visibleForTesting
Rect playerPanelRestArtworkRect(
  Size size, {
  required double artGap,
  required double infoReserve,
}) {
  final width = size.width;
  final height = size.height;
  final room = math.max(
    0.0,
    height - artGap - math.min(height, infoReserve) - 6,
  );
  final side = math.min(width, room);
  return Rect.fromLTWH((width - side) / 2, (room - side) / 2, side, side);
}

/// Artwork rectangle at any point in the lyrics transition.
/// These are exactly the constraints and offsets used by _PanelLayout, so
/// Space's growing frost mask can follow the actual cover frame by frame.
@visibleForTesting
Rect playerPanelArtworkRect(
  Size size, {
  required double artGap,
  required double infoReserve,
  required double lyrics,
}) {
  final l = lyrics.clamp(0.0, 1.0);
  final full = 1 - l;
  final rest = playerPanelRestArtworkRect(
    size,
    artGap: artGap,
    infoReserve: infoReserve,
  );
  final w = size.width;
  final h = size.height;
  const thumb = 52.0;
  final headerHeight = math.max(math.min(thumb, h), infoReserve);
  final artCentering = (headerHeight - math.min(thumb, h)) / 2;
  final lyricsTop = math.max(0.0, h - headerHeight - 8);
  final side = lerpDouble(rest.width, math.min(thumb, h), l)!;
  return Rect.fromLTWH(
    (w - rest.width) / 2 * full,
    rest.top * full + (artCentering + lyricsTop) * l,
    side,
    side,
  );
}

enum _Part { art, info, lyrics, header }

class _PanelLayout extends MultiChildLayoutDelegate {
  _PanelLayout({
    required this.lyrics,
    required this.artGap,
    required this.infoReserve,
  });
  final double lyrics, artGap, infoReserve;
  static const thumb = 52.0;
  @override
  void performLayout(Size size) {
    final full = 1 - lyrics;
    final w = size.width, h = size.height;
    final left = (thumb + 12) * lyrics;
    final info = layoutChild(
      _Part.info,
      BoxConstraints(
        minWidth: math.max(0, w - left),
        maxWidth: math.max(0, w - left),
        maxHeight: h,
      ),
    );
    // Hold sleeve geometry steady across fallback fonts with different
    // ascent/descent metrics (e.g. Japanese, Chinese, Latin).
    final restArtwork = playerPanelRestArtworkRect(
      size,
      artGap: artGap,
      infoReserve: infoReserve,
    );
    final fullSide = restArtwork.width;
    final top = restArtwork.top;
    final headerHeight = math.max(math.min(thumb, h), infoReserve);
    final artCentering = (headerHeight - math.min(thumb, h)) / 2;
    final lyricsTop = math.max(0.0, h - headerHeight - 8);
    final artBounds = playerPanelArtworkRect(
      size,
      artGap: artGap,
      infoReserve: infoReserve,
      lyrics: lyrics,
    );
    layoutChild(_Part.art, BoxConstraints.tight(artBounds.size));
    positionChild(_Part.art, artBounds.topLeft);
    positionChild(
      _Part.info,
      Offset(
        left,
        (top + fullSide + artGap) * full +
            (headerHeight - info.height) / 2 * lyrics +
            lyricsTop * lyrics,
      ),
    );
    layoutChild(
      _Part.lyrics,
      BoxConstraints.tightFor(width: w, height: math.max(0, lyricsTop - 10)),
    );
    positionChild(_Part.lyrics, Offset(0, (1 - lyrics) * 18));
    layoutChild(
      _Part.header,
      BoxConstraints.tightFor(
        width: math.min(thumb, w),
        height: math.min(thumb, h),
      ),
    );
    positionChild(_Part.header, Offset(0, (lyricsTop + artCentering) * lyrics));
  }

  @override
  bool shouldRelayout(_PanelLayout old) =>
      old.lyrics != lyrics ||
      old.artGap != artGap ||
      old.infoReserve != infoReserve;
}

/// A compact cover exits lyrics on tap or an upward swipe, without stealing
/// gestures from the lyrics list.
class _LyricsCoverReturnTarget extends StatefulWidget {
  const _LyricsCoverReturnTarget({this.onReturn});
  final VoidCallback? onReturn;
  @override
  State<_LyricsCoverReturnTarget> createState() =>
      _LyricsCoverReturnTargetState();
}

class _LyricsCoverReturnTargetState extends State<_LyricsCoverReturnTarget> {
  double _distance = 0;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: lokalText('Return to player'),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onReturn,
      onVerticalDragStart: (_) => _distance = 0,
      onVerticalDragUpdate: (details) => _distance += details.delta.dy,
      onVerticalDragEnd: (details) {
        if (_distance <= -20 || (details.primaryVelocity ?? 0) < -250)
          widget.onReturn?.call();
        _distance = 0;
      },
      onVerticalDragCancel: () => _distance = 0,
    ),
  );
}
