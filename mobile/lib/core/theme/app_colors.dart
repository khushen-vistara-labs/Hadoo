import 'package:flutter/material.dart';

import 'package:flick/core/theme/lokal_tokens.dart';

/// The palette the older Flick screens are written against, now read from
/// the active Lokal theme and accent ([LokalTokens]) so every screen follows
/// the listener's Appearance choice, light themes included.
///
/// The app root calls [bind] whenever the appearance changes and then
/// rebuilds the tree, so these getters never go stale.
class AppColors {
  AppColors._();

  static LokalTokens _t = LokalTokens.resolve(LokalThemeId.dark);

  /// The tokens these colours are read from.
  static LokalTokens get tokens => _t;

  /// Points the palette at [tokens]. Returns whether anything changed.
  static bool bind(LokalTokens tokens) {
    if (identical(tokens, _t) ||
        (tokens.bg == _t.bg &&
            tokens.surface == _t.surface &&
            tokens.surface2 == _t.surface2 &&
            tokens.surface3 == _t.surface3 &&
            tokens.text == _t.text &&
            tokens.muted == _t.muted &&
            tokens.muted2 == _t.muted2 &&
            tokens.accent == _t.accent &&
            tokens.accentDim == _t.accentDim &&
            tokens.red == _t.red)) {
      return false;
    }
    _t = tokens;
    return true;
  }

  static bool get isLight => _t.isLight;

  static Color _shade(Color c, double t) =>
      Color.lerp(c, isLight ? Colors.white : Colors.black, t)!;

  // Primary Background Colors
  static Color get background => _t.bg;
  static Color get backgroundLight => _t.surface2;
  static Color get backgroundDark => isLight ? _t.surface3 : _shade(_t.bg, .5);
  static Color get backgroundBlack => isLight ? _t.surface3 : _shade(_t.bg, .6);

  // Surface Colors (for cards, containers)
  static Color get surface => _t.surface;
  static Color get surfaceLight => _t.surface2;
  static Color get surfaceDark => isLight ? _t.surface3 : _shade(_t.bg, .2);

  // Text Colors
  static Color get textPrimary => _t.text;
  static Color get textSecondary => Color.lerp(_t.text, _t.muted, .45)!;
  static Color get textTertiary => _t.muted;

  // Accent Colors: the listener's accent, as desktop's "active" recipe.
  static Color get accent => _t.accent;
  static Color get accentLight => Color.lerp(_t.accent, _t.text, .25)!;
  static Color get accentDim => _t.accentDim;

  /// Text or icons drawn on an [accent] fill.
  static Color get onAccent => _t.onAccent;

  // Glassmorphism Colors: the theme's text colour at low opacity, so they
  // read as a lift on dark themes and a shade on light ones.
  static Color get glassBackground => _t.text.withValues(alpha: .05);
  static Color get glassBackgroundStrong => _t.text.withValues(alpha: .15);
  static Color get glassBorder => _t.text.withValues(alpha: .10);
  static Color get glassBorderStrong => _t.text.withValues(alpha: .20);

  // State Colors
  static Color get activeState => _t.text;
  static Color get inactiveState => _t.muted2;

  // Error / destructive colors
  static Color get error => _t.red;
  static Color get errorDim => _t.red.withValues(alpha: .16);
  static Color get errorBorder => _t.red.withValues(alpha: .35);

  // Success / positive state colors
  static const Color success = Color(0xFF4CC38A);
  static const Color onSuccess = Color(0xFF08150E);

  // Gradient definitions
  static LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundDark],
  );

  static LinearGradient get surfaceGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceLight, surface],
  );

  static RadialGradient get glowGradient => RadialGradient(
    colors: [_t.text.withValues(alpha: .125), _t.text.withValues(alpha: 0)],
  );

  // Milestone tier accent colors (subtle, glass-friendly tints).
  static const Color milestoneBronze = Color(0xFFC9956B);
  static const Color milestoneSilver = Color(0xFFB8C4D0);
  static const Color milestoneGold = Color(0xFFD4B265);
  static const Color milestoneSapphire = Color(0xFF8BB8FF);
  static const Color milestoneAmethyst = Color(0xFFC4A3FF);
  // Capper for the top song tier (10k) — caps the six-rung gem ladder.
  static const Color milestoneEmerald = Color(0xFF7FD3A0);
}
