import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flick/core/theme/lokal_tokens.dart';

void main() {
  test('every desktop theme has tokens', () {
    for (final id in LokalThemeId.values) {
      expect(LokalTokens.themes[id], isNotNull, reason: id.name);
    }
    expect(LokalTokens.themes, hasLength(10));
    expect(LokalAccent.presets, hasLength(12));
  });

  test('theme keys round-trip and unknown keys fall back to Dark', () {
    for (final id in LokalThemeId.values) {
      expect(LokalThemeId.fromKey(id.name), id);
    }
    expect(LokalThemeId.fromKey('nope'), LokalThemeId.dark);
    expect(LokalThemeId.fromKey(null), LokalThemeId.dark);
  });

  test('a chosen accent replaces the theme accent and nothing else', () {
    final base = LokalTokens.resolve(LokalThemeId.ocean);
    final custom = LokalTokens.resolve(
      LokalThemeId.ocean,
      accent: LokalAccent.pink,
    );
    expect(custom.accent, LokalAccent.pink.value);
    expect(custom.accentDim, LokalAccent.pink.dim);
    expect(custom.bg, base.bg);
    expect(custom.text, base.text);
  });

  test('nearest preset matches exact and near colours', () {
    for (final accent in LokalAccent.presets) {
      expect(LokalAccent.nearest(accent.value), accent);
    }
    expect(LokalAccent.nearest(const Color(0xFFFF5050)), LokalAccent.red);
    expect(LokalAccent.nearest(const Color(0xFF60B0FF)), LokalAccent.blue);
  });

  test('text on the accent stays readable', () {
    // Lime is bright, so it takes dark text; Purple takes light text.
    final lime = LokalTokens.resolve(
      LokalThemeId.dark,
      accent: LokalAccent.lime,
    );
    expect(lime.onAccent.computeLuminance(), lessThan(.2));
    final purple = LokalTokens.resolve(
      LokalThemeId.dark,
      accent: LokalAccent.purple,
    );
    expect(purple.onAccent.computeLuminance(), greaterThan(.5));
  });

  test('Light is the only light theme', () {
    for (final id in LokalThemeId.values) {
      expect(
        LokalTokens.resolve(id).isLight,
        id == LokalThemeId.light,
        reason: id.name,
      );
    }
  });

  test('lerp lands on both ends', () {
    final a = LokalTokens.resolve(LokalThemeId.dark);
    final b = LokalTokens.resolve(LokalThemeId.light);
    expect(a.lerp(b, 0).bg, a.bg);
    expect(a.lerp(b, 1).bg, b.bg);
    expect(a.lerp(b, 1).accent, b.accent);
  });
}
