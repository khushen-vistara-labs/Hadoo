import 'dart:io';

import 'package:flick/core/theme/lokal_appearance.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/features/settings/lokal/lokal_licences_page.dart';
import 'package:flick/features/settings/screens/equalizer_screen.dart';
import 'package:flick/features/settings/screens/privacy_policy_screen.dart';
import 'package:flick/providers/equalizer_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home) => ProviderScope(
  overrides: [equalizerProvider.overrideWith(_QuietEqualizer.new)],
  child: Consumer(
    builder: (context, ref, _) => MaterialApp(
      theme: LokalTheme.build(ref.watch(lokalAppearanceProvider).tokens),
      home: home,
    ),
  ),
);

/// The equalizer without its saved state or the audio engine behind it.
class _QuietEqualizer extends EqualizerNotifier {
  @override
  EqualizerState build() => EqualizerState.initial();
}

/// The settings sub-pages reskinned to Lokal: none may keep Flick's look.
const _reskinned = [
  'lib/widgets/lokal/settings/lokal_settings_kit.dart',
  'lib/widgets/lokal/settings/lokal_settings_surfaces.dart',
  'lib/features/settings/lokal/groups/data_group.dart',
  'lib/features/settings/screens/equalizer_screen.dart',
  'lib/features/settings/screens/widgets/autoeq_search_sheet.dart',
  'lib/features/settings/screens/uac2_settings_screen.dart',
  'lib/features/settings/screens/uac2_preferences_screen.dart',
  'lib/features/settings/screens/bluetooth_settings_screen.dart',
  'lib/features/settings/screens/casting_settings_screen.dart',
  'lib/features/settings/screens/player_layout_settings_screen.dart',
  'lib/features/settings/screens/widget_settings_screen.dart',
  'lib/features/settings/screens/privacy_policy_screen.dart',
  'lib/features/settings/screens/logs_screen.dart',
  'lib/features/settings/screens/network_sources_screen.dart',
  'lib/features/settings/screens/network_server_edit_screen.dart',
  'lib/features/spotiflac/spotiflac_addons_screen.dart',
  'lib/features/manual/screens/manual_screen.dart',
  'lib/features/settings/lokal/lokal_licences_page.dart',
];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('reskinned settings pages have no blur and no Flick styling', () {
    final flick = RegExp(
      r'BackdropFilter|ImageFilter\.blur|AppColors\.|GoogleSansFlex|'
      r'FlickDialog|GlassBottomSheet|LokalGlass|\bSettingsScaffold\(|'
      r'\bSettingsCard\(|\bToggleSetting\(|\bCustomSwitch\(',
    );
    for (final path in _reskinned) {
      final file = File(path);
      if (!file.existsSync()) continue;
      final source = file.readAsStringSync();
      final hits = flick.allMatches(source).map((m) => m[0]).toSet();
      expect(hits, isEmpty, reason: '$path still uses $hits');
    }
  });

  testWidgets('the equalizer keeps advanced tools under Advanced', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(const EqualizerScreen()));
    await tester.pump();

    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Browse presets'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);
    expect(find.text('Preset files'.toUpperCase()), findsNothing);
    expect(find.text('TONE'), findsNothing);

    await tester.tap(find.text('Advanced'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('TONE'), findsOneWidget);
    for (
      var i = 0;
      i < 12 && find.text('PRESET FILES').evaluate().isEmpty;
      i++
    ) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -800));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('PRESET FILES'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('the privacy policy explains Hadoo streaming requests', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const PrivacyPolicyScreen()));
    await tester.pump();

    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.textContaining('Hadoo'), findsWidgets);
    expect(
      find.textContaining('Home and Search send your search terms'),
      findsOneWidget,
    );
    expect(find.textContaining('Lokal'), findsNothing);
    expect(find.textContaining('Flick'), findsNothing);
  });

  testWidgets('licences label Flick as the upstream project', (tester) async {
    await tester.pumpWidget(
      _app(
        LokalLicencesPage(
          licences: Stream.fromIterable([
            const LicenseEntryWithLineBreaks(['Flick'], 'MIT License'),
            const LicenseEntryWithLineBreaks(['zeta'], 'BSD'),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Flick (upstream project)'), findsOneWidget);
    expect(find.text('zeta'), findsOneWidget);
    await tester.tap(find.text('Flick (upstream project)'));
    await tester.pumpAndSettle();
    expect(find.text('MIT License'), findsOneWidget);
  });
}
