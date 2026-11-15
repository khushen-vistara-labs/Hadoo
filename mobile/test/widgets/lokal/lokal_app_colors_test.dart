import 'package:flick/core/theme/app_colors.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/features/settings/lokal/lokal_settings_group.dart';
import 'package:flick/features/settings/lokal/lokal_settings_page.dart';
import 'package:flick/features/settings/widgets/settings_widgets.dart';
import 'package:flick/l10n/l10n.dart';
import 'package:flick/providers/player_provider.dart';
import 'package:flick/widgets/lokal/settings/lokal_settings_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final dark = LokalTokens.resolve(LokalThemeId.dark);
  final light = LokalTokens.resolve(LokalThemeId.light);
  final ocean = LokalTokens.resolve(
    LokalThemeId.ocean,
    accent: LokalAccent.pink,
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => AppColors.bind(dark));

  test('the old palette follows the bound theme and accent', () {
    expect(AppColors.bind(light), isTrue);
    expect(AppColors.background, light.bg);
    expect(AppColors.surface, light.surface);
    expect(AppColors.textPrimary, light.text);
    expect(AppColors.textTertiary, light.muted);
    expect(AppColors.accent, light.accent);
    expect(AppColors.onAccent, light.onAccent);
    expect(AppColors.error, light.red);
    expect(AppColors.glassBorder, light.text.withValues(alpha: .10));
    expect(AppColors.isLight, isTrue);
    expect(AppColors.bind(LokalTokens.resolve(LokalThemeId.light)), isFalse);

    expect(AppColors.bind(ocean), isTrue);
    expect(AppColors.background, ocean.bg);
    expect(AppColors.accent, LokalAccent.pink.value);
    expect(AppColors.isLight, isFalse);
  });

  Future<void> pump(WidgetTester tester, LokalTokens tokens, Widget home) {
    AppColors.bind(tokens);
    return tester.pumpWidget(
      ProviderScope(
        overrides: [currentSongProvider.overrideWithValue(null)],
        child: MaterialApp(
          theme: LokalTheme.build(tokens),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            LocaleController.instance.bind(AppLocalizations.of(context));
            return child!;
          },
          home: home,
        ),
      ),
    );
  }

  testWidgets('a switched-on setting is filled with the accent', (
    tester,
  ) async {
    await pump(
      tester,
      ocean,
      Scaffold(body: CustomSwitch(value: true, onChanged: (_) {})),
    );
    final track = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(CustomSwitch),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect((track.decoration! as BoxDecoration).color, ocean.accent);
  });

  for (final entry in {'light': light, 'ocean': ocean}.entries) {
    testWidgets('settings screens build on the ${entry.key} theme', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2340);
      addTearDown(tester.view.reset);
      await pump(tester, entry.value, const LokalSettingsPage());
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      await pump(
        tester,
        entry.value,
        const LokalSettingsGroupPage(
          group: LokalSettingsGroup.appearance,
          section: 'Interface',
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(find.byType(LokalOnOffPill), findsWidgets);
    });
  }
}
