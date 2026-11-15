import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lokal desktop's themes, ported 1:1 from `src/theme.js` in CHEYCKIT/lokal.
///
/// The ids and names match the desktop keys, so a desktop theme (or a theme
/// synced over the desktop link) maps across without translation.
enum LokalThemeId {
  dark('Terminal'),
  light('Light'),
  midnight('Midnight'),
  warm('Warm'),
  oled('OLED'),
  ocean('Ocean'),
  forest('Forest'),
  cyberpunk('Cyberpunk'),
  rosegold('Rose Gold'),
  deepContrast('Deep Contrast');

  const LokalThemeId(this.label);

  final String label;

  static LokalThemeId fromKey(String? key) => LokalThemeId.values.firstWhere(
    (id) => id.name == key,
    orElse: () => LokalThemeId.dark,
  );
}

/// One of desktop Lokal's accent presets (`ACCENT_COLORS` in `src/theme.js`).
@immutable
class LokalAccent {
  const LokalAccent(this.name, this.value, this.dim);

  final String name;
  final Color value;
  final Color dim;

  static const lime = LokalAccent('Lime', Color(0xFFC8FF57), Color(0xFFA8D94A));
  static const purple = LokalAccent(
    'Purple',
    Color(0xFF7C6AFF),
    Color(0xFF6A5AE8),
  );
  static const pink = LokalAccent('Pink', Color(0xFFFF57C8), Color(0xFFE04AB3));
  static const orange = LokalAccent(
    'Orange',
    Color(0xFFFF9F43),
    Color(0xFFE08A3A),
  );
  static const blue = LokalAccent('Blue', Color(0xFF57B8FF), Color(0xFF4AA5E8));
  static const red = LokalAccent('Red', Color(0xFFFF5757), Color(0xFFE04A4A));
  static const teal = LokalAccent('Teal', Color(0xFF57FFD4), Color(0xFF4AE8C0));
  static const white = LokalAccent(
    'White',
    Color(0xFFFFFFFF),
    Color(0xFFE0E0E0),
  );
  static const yellow = LokalAccent(
    'Yellow',
    Color(0xFFFFEC57),
    Color(0xFFE8D44A),
  );
  static const cyan = LokalAccent('Cyan', Color(0xFF57FFEC), Color(0xFF4AE8D4));
  static const magenta = LokalAccent(
    'Magenta',
    Color(0xFFFF57EC),
    Color(0xFFE04AD4),
  );
  static const gray = LokalAccent('Gray', Color(0xFF888888), Color(0xFF666666));

  /// In desktop order, which is also the order the pickers show.
  static const presets = <LokalAccent>[
    lime,
    purple,
    pink,
    orange,
    blue,
    red,
    teal,
    white,
    yellow,
    cyan,
    magenta,
    gray,
  ];

  static LokalAccent? byName(String? name) {
    for (final accent in presets) {
      if (accent.name == name) return accent;
    }
    return null;
  }

  /// The preset closest to [color], measured in OKLab so the match follows
  /// how different the colours look rather than their RGB distance.
  ///
  /// The launcher icon can only switch between pre-built icons, so a custom
  /// accent shows the nearest preset there.
  static LokalAccent nearest(Color color) {
    final target = _oklab(color);
    LokalAccent best = presets.first;
    double bestDistance = double.infinity;
    for (final accent in presets) {
      final lab = _oklab(accent.value);
      final distance =
          math.pow(lab[0] - target[0], 2) +
          math.pow(lab[1] - target[1], 2) +
          math.pow(lab[2] - target[2], 2);
      if (distance < bestDistance) {
        bestDistance = distance.toDouble();
        best = accent;
      }
    }
    return best;
  }

  static List<double> _oklab(Color color) {
    double linear(double c) => c <= 0.04045
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    final r = linear(color.r);
    final g = linear(color.g);
    final b = linear(color.b);
    final l = math.pow(
      0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b,
      1 / 3,
    );
    final m = math.pow(
      0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b,
      1 / 3,
    );
    final s = math.pow(
      0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b,
      1 / 3,
    );
    return [
      0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
      1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
      0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s,
    ];
  }

  @override
  bool operator ==(Object other) =>
      other is LokalAccent && other.name == name && other.value == value;

  @override
  int get hashCode => Object.hash(name, value);
}

/// Lokal's design tokens, carried on [ThemeData] so every widget reads the
/// same values and a theme change animates through [lerp].
///
/// Field names follow the desktop CSS variables (`--bg` → [bg],
/// `--surface2` → [surface2], `--accent-dim` → [accentDim], …).
@immutable
class LokalTokens extends ThemeExtension<LokalTokens> {
  const LokalTokens({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.border,
    required this.border2,
    required this.text,
    required this.muted,
    required this.muted2,
    required this.accent,
    required this.accentDim,
    required this.red,
    required this.purple,
    required this.orange,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color border;
  final Color border2;
  final Color text;
  final Color muted;
  final Color muted2;
  final Color accent;
  final Color accentDim;
  final Color red;
  final Color purple;
  final Color orange;

  /// Desktop flips to its light styles when `--bg` luminance passes 0.5.
  bool get isLight => _luminance(bg) > 0.5;

  /// Text or icons drawn on an [accent] fill.
  Color get onAccent =>
      _luminance(accent) > 0.5 ? const Color(0xFF0A0A0A) : Colors.white;

  /// Desktop's "active" recipe: `bg-accent/15 border-accent/50 text-accent`.
  Color get accentSoft => accent.withValues(alpha: .15);
  Color get accentLine => accent.withValues(alpha: .5);

  /// The tinted logo's tile (`--logo-wrap-bg` / `--logo-wrap-border`).
  Color get accentTile => accent.withValues(alpha: .10);
  Color get accentTileBorder => accent.withValues(alpha: .20);

  /// Flow's gradient (`#7c6aff` → `#ff6aa8` → accent), as on desktop.
  List<Color> get flowGradient => [
    const Color(0xFF7C6AFF),
    const Color(0xFFFF6AA8),
    accent,
  ];

  static const _dark = LokalTokens(
    bg: Color(0xFF070B09),
    surface: Color(0xFF0D1410),
    surface2: Color(0xFF131E17),
    surface3: Color(0xFF1B2A20),
    border: Color(0xFF253C2D),
    border2: Color(0xFF3B5943),
    text: Color(0xFFE4F0E6),
    muted: Color(0xFF95AF9D),
    muted2: Color(0xFF66816E),
    accent: Color(0xFF65FF8F),
    accentDim: Color(0xFF46C66B),
    red: Color(0xFFFF6D7A),
    purple: Color(0xFFC5A3FF),
    orange: Color(0xFFFFBE76),
  );

  static const Map<LokalThemeId, LokalTokens> themes = {
    LokalThemeId.dark: _dark,
    LokalThemeId.light: LokalTokens(
      bg: Color(0xFFF5F5F5),
      surface: Color(0xFFFFFFFF),
      surface2: Color(0xFFFAFAFA),
      surface3: Color(0xFFF0F0F0),
      border: Color(0xFFE0E0E0),
      border2: Color(0xFFCCCCCC),
      text: Color(0xFF1A1A1A),
      muted: Color(0xFF666666),
      muted2: Color(0xFF999999),
      accent: Color(0xFF7C6AFF),
      accentDim: Color(0xFF9D94FF),
      red: Color(0xFFE53935),
      purple: Color(0xFF5E35B1),
      orange: Color(0xFFFB8C00),
    ),
    LokalThemeId.midnight: LokalTokens(
      bg: Color(0xFF0D1117),
      surface: Color(0xFF161B22),
      surface2: Color(0xFF21262D),
      surface3: Color(0xFF30363D),
      border: Color(0xFF30363D),
      border2: Color(0xFF484F58),
      text: Color(0xFFC9D1D9),
      muted: Color(0xFF8B949E),
      muted2: Color(0xFF6E7681),
      accent: Color(0xFF58A6FF),
      accentDim: Color(0xFF388BFD),
      red: Color(0xFFF85149),
      purple: Color(0xFFA371F7),
      orange: Color(0xFFD29922),
    ),
    LokalThemeId.warm: LokalTokens(
      bg: Color(0xFF1A1410),
      surface: Color(0xFF251C18),
      surface2: Color(0xFF302520),
      surface3: Color(0xFF3D2E28),
      border: Color(0xFF4A3830),
      border2: Color(0xFF5C4640),
      text: Color(0xFFF0E6DC),
      muted: Color(0xFFA89585),
      muted2: Color(0xFF7D6B60),
      accent: Color(0xFFFF9F43),
      accentDim: Color(0xFFE08A3A),
      red: Color(0xFFE74C3C),
      purple: Color(0xFF9B59B6),
      orange: Color(0xFFE67E22),
    ),
    LokalThemeId.oled: LokalTokens(
      bg: Color(0xFF000000),
      surface: Color(0xFF0A0A0A),
      surface2: Color(0xFF121212),
      surface3: Color(0xFF1A1A1A),
      border: Color(0xFF222222),
      border2: Color(0xFF2A2A2A),
      text: Color(0xFFFFFFFF),
      muted: Color(0xFF888888),
      muted2: Color(0xFF555555),
      accent: Color(0xFFE8FF57),
      accentDim: Color(0xFFC8DF47),
      red: Color(0xFFFF5757),
      purple: Color(0xFF7C6AFF),
      orange: Color(0xFFFF9F43),
    ),
    LokalThemeId.ocean: LokalTokens(
      bg: Color(0xFF0A1929),
      surface: Color(0xFF0F2744),
      surface2: Color(0xFF14395E),
      surface3: Color(0xFF1A4678),
      border: Color(0xFF1E4D6B),
      border2: Color(0xFF2A5F7F),
      text: Color(0xFFE0F0FF),
      muted: Color(0xFF7AA3C4),
      muted2: Color(0xFF5A7D9E),
      accent: Color(0xFF57B8FF),
      accentDim: Color(0xFF4A9FE8),
      red: Color(0xFFFF5757),
      purple: Color(0xFF7C6AFF),
      orange: Color(0xFFFF9F43),
    ),
    LokalThemeId.forest: LokalTokens(
      bg: Color(0xFF0A1A0A),
      surface: Color(0xFF0F260F),
      surface2: Color(0xFF143214),
      surface3: Color(0xFF1A3D1A),
      border: Color(0xFF1F451F),
      border2: Color(0xFF2A552A),
      text: Color(0xFFE0FFE0),
      muted: Color(0xFF7AC47A),
      muted2: Color(0xFF5A9A5A),
      accent: Color(0xFF57FFD4),
      accentDim: Color(0xFF4AE8C0),
      red: Color(0xFFFF5757),
      purple: Color(0xFF7C6AFF),
      orange: Color(0xFFFF9F43),
    ),
    LokalThemeId.cyberpunk: LokalTokens(
      bg: Color(0xFF0F0F1A),
      surface: Color(0xFF161625),
      surface2: Color(0xFF1C1C30),
      surface3: Color(0xFF252540),
      border: Color(0xFF2D2D4A),
      border2: Color(0xFF3A3A5E),
      text: Color(0xFF00FFCC),
      muted: Color(0xFF7A7AB0),
      muted2: Color(0xFF4E4E7A),
      accent: Color(0xFFFF00FF),
      accentDim: Color(0xFFBC00BC),
      red: Color(0xFFFF3E3E),
      purple: Color(0xFF9D4EDD),
      orange: Color(0xFFFF9100),
    ),
    LokalThemeId.rosegold: LokalTokens(
      bg: Color(0xFF1A1718),
      surface: Color(0xFF241E20),
      surface2: Color(0xFF2D2528),
      surface3: Color(0xFF382E32),
      border: Color(0xFF45383C),
      border2: Color(0xFF54454A),
      text: Color(0xFFF5EDEE),
      muted: Color(0xFFA69296),
      muted2: Color(0xFF7A686C),
      accent: Color(0xFFFFB7C5),
      accentDim: Color(0xFFE5A4B1),
      red: Color(0xFFFF6B6B),
      purple: Color(0xFFD4A5FF),
      orange: Color(0xFFFFB38A),
    ),
    LokalThemeId.deepContrast: LokalTokens(
      bg: Color(0xFF000000),
      surface: Color(0xFF050505),
      surface2: Color(0xFF0A0A0A),
      surface3: Color(0xFF121212),
      border: Color(0xFF404040),
      border2: Color(0xFF666666),
      text: Color(0xFFFFFFFF),
      muted: Color(0xFF999999),
      muted2: Color(0xFF777777),
      accent: Color(0xFFFFFFFF),
      accentDim: Color(0xFFCCCCCC),
      red: Color(0xFFFF0000),
      purple: Color(0xFFBF94FF),
      orange: Color(0xFFFFAB40),
    ),
  };

  /// [id]'s tokens with [accent] in place of the theme's own, if given.
  static LokalTokens resolve(LokalThemeId id, {LokalAccent? accent}) {
    final base = themes[id] ?? _dark;
    if (accent == null) return base;
    return base.copyWith(accent: accent.value, accentDim: accent.dim);
  }

  /// The tokens of the nearest [Theme]; desktop's Dark outside one.
  static LokalTokens of(BuildContext context) =>
      Theme.of(context).extension<LokalTokens>() ?? _dark;

  @override
  LokalTokens copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? surface3,
    Color? border,
    Color? border2,
    Color? text,
    Color? muted,
    Color? muted2,
    Color? accent,
    Color? accentDim,
    Color? red,
    Color? purple,
    Color? orange,
  }) => LokalTokens(
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    surface2: surface2 ?? this.surface2,
    surface3: surface3 ?? this.surface3,
    border: border ?? this.border,
    border2: border2 ?? this.border2,
    text: text ?? this.text,
    muted: muted ?? this.muted,
    muted2: muted2 ?? this.muted2,
    accent: accent ?? this.accent,
    accentDim: accentDim ?? this.accentDim,
    red: red ?? this.red,
    purple: purple ?? this.purple,
    orange: orange ?? this.orange,
  );

  @override
  LokalTokens lerp(covariant LokalTokens? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return LokalTokens(
      bg: mix(bg, other.bg),
      surface: mix(surface, other.surface),
      surface2: mix(surface2, other.surface2),
      surface3: mix(surface3, other.surface3),
      border: mix(border, other.border),
      border2: mix(border2, other.border2),
      text: mix(text, other.text),
      muted: mix(muted, other.muted),
      muted2: mix(muted2, other.muted2),
      accent: mix(accent, other.accent),
      accentDim: mix(accentDim, other.accentDim),
      red: mix(red, other.red),
      purple: mix(purple, other.purple),
      orange: mix(orange, other.orange),
    );
  }

  // Desktop's formula (`isLightColor` in src/theme.js), on sRGB channels.
  static double _luminance(Color c) =>
      0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b;
}

extension LokalTokensContext on BuildContext {
  LokalTokens get lokal => LokalTokens.of(this);
}
