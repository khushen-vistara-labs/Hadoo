import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flick/core/constants/app_constants.dart';
import 'package:flick/core/utils/responsive.dart';
import 'package:flick/models/mini_player_config.dart';

class BottomBarGeometry {
  BottomBarGeometry._();

  static double navigationInset(BuildContext context) =>
      context.scaleSize(AppConstants.spacingLg);

  static double miniPlayerHeight(
    BuildContext context,
    MiniPlayerConfig config,
  ) {
    final scaler = MediaQuery.textScalerOf(context);
    final title = TextPainter(
      text: TextSpan(
        text: 'Ag',
        style: TextStyle(
          fontFamily: 'HadooMono',
          fontSize: 14 * config.textScale,
          fontWeight: FontWeight.w600,
          height: 1.15,
        ),
      ),
      textDirection: Directionality.of(context),
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final artist = TextPainter(
      text: TextSpan(
        text: 'Ag',
        style: TextStyle(
          fontFamily: 'HadooMono',
          fontSize: 12 * config.textScale,
          fontWeight: FontWeight.w500,
          height: 1.15,
        ),
      ),
      textDirection: Directionality.of(context),
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final textHeight =
        title.height + (config.showArtist ? artist.height + 2 : 0);
    title.dispose();
    artist.dispose();
    return math.max(config.height, textHeight + 12);
  }

  static double extraClearance(
    BuildContext context,
    MiniPlayerConfig config,
    bool separated,
  ) => math.max(
    0,
    miniPlayerHeight(context, config) -
        56 +
        (separated ? config.navigationGap - 8 : 0),
  );
}
