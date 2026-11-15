import 'package:flick/features/link/lokal_desktop_link_screen.dart';
import 'package:flick/l10n/l10n.dart';

import 'dart:async';
import 'dart:io';

import 'package:flick/features/settings/widgets/battery_optimization_setting.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flick/core/theme/lokal_appearance.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/features/appearance/lokal_appearance_screen.dart';
import 'package:flick/features/settings/library_scan/library_scan_flow.dart';
import 'package:flick/features/settings/lokal/lokal_settings_group.dart';
import 'package:flick/features/settings/lokal/lokal_settings_page.dart';
import 'package:flick/providers/lastfm_provider.dart';
import 'package:flick/features/settings/widgets/youtube_music_settings_tile.dart';
import 'package:flick/providers/onboarding_provider.dart';
import 'package:flick/services/permission_service.dart';
import 'package:flick/widgets/lokal/lokal_logo.dart';
import 'package:flick/widgets/lokal/settings/lokal_settings_kit.dart';

/// Lokal's first run, in desktop's order and wording: Welcome, your look,
/// your music folder, optional accounts, then All Set.
///
/// Each permission is asked for where it is needed: storage when a folder is
/// picked, notifications on the last step. Account connections remain opt-in;
/// YouTube Music opens the same sign-in flow as Data › Accounts.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Step { welcome, look, folder, desktop, online, background, done }

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Step _step = _Step.welcome;
  bool _forward = true;
  String? _folderName;
  bool _picking = false;
  bool _finishing = false;

  void _go(_Step step) {
    HapticFeedback.selectionClick();
    setState(() {
      _forward = step.index > _step.index;
      _step = step;
    });
  }

  void _next() {
    if (_step == _Step.done) {
      unawaited(_finish());
    } else if (_step == _Step.online && !Platform.isAndroid) {
      _go(_Step.done);
    } else {
      _go(_Step.values[_step.index + 1]);
    }
  }

  void _back() {
    if (_step == _Step.done && !Platform.isAndroid) {
      _go(_Step.online);
    } else if (_step.index > 0) {
      _go(_Step.values[_step.index - 1]);
    }
  }

  Future<void> _pickFolder() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final folder = await LibraryScanFlow.addFolder(context);
      if (mounted && folder != null) {
        setState(() => _folderName = folder.displayName);
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    final permissions = PermissionService();
    try {
      if (!await permissions.hasNotificationPermission()) {
        await permissions.requestNotificationPermission();
      }
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
    if (!mounted) return;
    await ref.read(onboardingCompletedProvider.notifier).complete();
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _skipAll() {
    unawaited(ref.read(onboardingCompletedProvider.notifier).complete());
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 420);

    final (primary, onPrimary) = switch (_step) {
      _Step.welcome => (lokalText('Get Started'), _next),
      _Step.folder when _folderName == null => (
        _picking ? lokalText('Opening…') : lokalText('Choose Folder'),
        _picking ? null : _pickFolder,
      ),
      _Step.done => (
        _finishing ? lokalText('Starting…') : lokalText('Start Listening'),
        _finishing ? null : _next,
      ),
      _ => (lokalText('Continue'), _next),
    };
    final (secondary, onSecondary) = switch (_step) {
      _Step.welcome => (lokalText('Skip Setup'), _skipAll),
      _Step.folder when _folderName == null => (
        lokalText('Skip for now'),
        _next,
      ),
      _Step.desktop => (l10n.linkNotNow, _next),
      _Step.online || _Step.background => (lokalText('Not now'), _next),
      _ => (null, null),
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          (t.isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light)
              .copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: t.bg,
              ),
      child: Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                step: _step.index,
                count: _Step.values.length,
                onBack: _step.index > 0 && !_finishing ? _back : null,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: duration,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final incoming = child.key == ValueKey(_step);
                    final dx = (incoming == _forward) ? .06 : -.06;
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(dx, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _page(context),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  children: [
                    _PrimaryButton(label: primary, onPressed: onPrimary),
                    AnimatedSize(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      child: secondary == null
                          ? const SizedBox(width: double.infinity)
                          : Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: TextButton(
                                onPressed: onSecondary,
                                style: TextButton.styleFrom(
                                  foregroundColor: t.muted,
                                  minimumSize: const Size.fromHeight(44),
                                ),
                                child: Text(
                                  secondary,
                                  style: const TextStyle(
                                    fontFamily: LokalTheme.sans,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _page(BuildContext context) => switch (_step) {
    _Step.welcome => const _WelcomePage(),
    _Step.look => const _LookPage(),
    _Step.folder => _FolderPage(
      folderName: _folderName,
      picking: _picking,
      onPick: _pickFolder,
    ),
    _Step.desktop => const _DesktopLinkPage(),
    _Step.online => const _OnlinePage(),
    _Step.background => ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const Text(
          'Keep the music playing',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        const Text(
          'You can allow background work now, or later in Data. This is optional.',
        ),
        const SizedBox(height: 24),
        LokalSettingsSection(
          title: 'Background',
          children: const [BatteryOptimizationSetting()],
        ),
      ],
    ),
    _Step.done => _DonePage(hasFolder: _folderName != null),
  };
}

// ─── Chrome ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.step, required this.count, this.onBack});

  final int step;
  final int count;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: AnimatedOpacity(
              opacity: onBack == null ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                tooltip: lokalText('Back'),
                onPressed: onBack,
                icon: Icon(Icons.chevron_left_rounded, size: 30, color: t.text),
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              label: lokalText(
                "Step {arg0} of {arg1}",
                args: {'arg0': step + 1, 'arg1': count},
              ),
              excludeSemantics: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < count; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == step ? 22 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= step ? t.accent : t.surface3,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 56),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: t.accent,
          foregroundColor: t.onAccent,
          disabledBackgroundColor: t.accent.withValues(alpha: .55),
          disabledForegroundColor: t.onAccent.withValues(alpha: .8),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            label,
            key: ValueKey(label),
            style: const TextStyle(
              fontFamily: LokalTheme.sans,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Eyebrow, large title and body, as every page opens.
class _Header extends StatelessWidget {
  const _Header({
    required this.eyebrow,
    required this.title,
    required this.body,
    this.center = false,
  });

  final String eyebrow;
  final String title;
  final String body;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    final align = center ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          textAlign: align,
          style: LokalTheme.label(t, color: t.accent),
        ),
        const SizedBox(height: 10),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: align,
            style: TextStyle(
              fontFamily: LokalTheme.sans,
              fontSize: 34,
              height: 1.08,
              letterSpacing: -1.1,
              fontWeight: FontWeight.w800,
              color: t.text,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          body,
          textAlign: align,
          style: TextStyle(
            fontFamily: LokalTheme.sans,
            fontSize: 16,
            height: 1.45,
            color: t.muted,
          ),
        ),
      ],
    );
  }
}

// ─── Pages ───────────────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 3),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: reduceMotion ? 1 : .82, end: 1),
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 900),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: const LokalLogo(size: 132),
          ),
          const SizedBox(height: 36),
          _Header(
            eyebrow: 'Hadoo',
            title: lokalText('Welcome to Hadoo'),
            body:
                'Stream YouTube Music, save your favorites for offline listening, '
                'and bring your own music. Your music. Your terminal.',
            center: true,
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}

class _LookPage extends ConsumerWidget {
  const _LookPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(lokalAppearanceProvider);
    final notifier = ref.read(lokalAppearanceProvider.notifier);
    final t = context.lokal;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Header(
                  eyebrow: 'Make it yours',
                  title: lokalText('Pick your look'),
                  body:
                      'Choose a theme and an accent. You can change them '
                      'any time in Settings › Appearance.',
                ),
              ),
              SizedBox(width: 12),
              LokalLogo(size: 64),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
          child: Text(lokalText('THEME'), style: LokalTheme.label(t)),
        ),
        LokalThemeGrid(
          selected: appearance.theme,
          onSelect: (id) {
            HapticFeedback.selectionClick();
            notifier.selectTheme(id);
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 12),
          child: Text(lokalText('ACCENT'), style: LokalTheme.label(t)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: SwitchListTile(
            title: Text(lokalText('Unboxed player controls')),
            subtitle: Text(lokalText('Same playback icons, without button boxes.')),
            value: appearance.unboxedPlayerControls,
            onChanged: notifier.setUnboxedPlayerControls,
          ),
        ),
        LokalAccentRow(
          selected: appearance.accent,
          onSelect: (accent) {
            HapticFeedback.selectionClick();
            notifier.setAccent(accent);
          },
        ),
      ],
    );
  }
}

class _FolderPage extends StatelessWidget {
  const _FolderPage({
    required this.folderName,
    required this.picking,
    required this.onPick,
  });

  final String? folderName;
  final bool picking;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    final added = folderName != null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        _Header(
          eyebrow: 'Your music',
          title: lokalText('Select Your Music Folder'),
          body:
              'Choose a folder where your music files are stored. Hadoo will '
              'scan and organize your library.',
        ),
        const SizedBox(height: 28),
        Semantics(
          button: true,
          label: added
              ? lokalText('Add another folder')
              : lokalText('Choose a music folder'),
          excludeSemantics: true,
          child: Material(
            color: added ? t.accentSoft : t.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: added ? t.accent.withValues(alpha: .5) : t.border2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: picking ? null : onPick,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: added ? t.accent : t.surface3,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        added ? Icons.check_rounded : Icons.folder_open_rounded,
                        color: added ? t.onAccent : t.accent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            folderName ?? lokalText('Choose a folder'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: LokalTheme.sans,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: t.text,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            added
                                ? lokalText(
                                    'Added · scanning in the background',
                                  )
                                : lokalText('MP3, FLAC, AAC, WAV and more'),
                            style: TextStyle(
                              fontFamily: LokalTheme.sans,
                              fontSize: 13,
                              color: t.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (added)
                      Text(
                        lokalText('ADD'),
                        style: LokalTheme.label(t, color: t.accent),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: 18, color: t.muted2),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lokalText(
                  "Hadoo is not a streaming service: it plays music you own. You can add folders later from Library or Settings › Library.",
                ),
                style: TextStyle(
                  fontFamily: LokalTheme.sans,
                  fontSize: 13,
                  height: 1.4,
                  color: t.muted2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OnlinePage extends ConsumerWidget {
  const _OnlinePage();

  void _open(BuildContext context, String section) => unawaited(
    openLokalSettings(
      context,
      group: LokalSettingsGroup.data,
      section: section,
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastFm = ref.watch(lastFmSessionProvider).value != null;
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: _Header(
            eyebrow: 'Optional',
            title: lokalText('Connect Your Music Accounts'),
            body:
                'Sign in to YouTube Music for your mixes, and connect Last.fm '
                'for scrobbling and Discovery. Both stay off until you turn '
                'them on, here or later in Data › Accounts.',
          ),
        ),
        const SizedBox(height: 6),
        LokalSettingsSection(
          title: lokalText('Accounts'),
          children: [
            const YoutubeMusicSettingsTile(),
            LokalSettingRow.toggle(
              label: lokalText('Last.fm'),
              description: lastFm
                  ? lokalText('Connected')
                  : lokalText('Scrobble what you play and power Discovery'),
              icon: Icons.graphic_eq_rounded,
              value: lastFm,
              onChanged: (_) => _open(context, LokalDataSections.accounts),
            ),
            LokalSettingLink(
              label: lokalText('All online sources'),
              description: lokalText(
                'Playback sources, add-ons, servers and radio',
              ),
              onTap: () => unawaited(
                openLokalSettings(
                  context,
                  group: LokalSettingsGroup.integrations,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DonePage extends StatelessWidget {
  const _DonePage({required this.hasFolder});

  final bool hasFolder;

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 3),
          const LokalLogo(size: 104),
          const SizedBox(height: 32),
          _Header(
            eyebrow: 'Ready',
            title: lokalText('All Set!'),
            body: hasFolder
                ? 'Your music library is ready. Enjoy your music with Hadoo!'
                : 'Add your music any time from Library or '
                      'Settings › Library. Enjoy Hadoo!',
            center: true,
          ),
          const Spacer(flex: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none_rounded, size: 18, color: t.muted2),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  lokalText(
                    "Hadoo may ask to show playback controls in your notifications.",
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: LokalTheme.sans,
                    fontSize: 13,
                    height: 1.4,
                    color: t.muted2,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _DesktopLinkPage extends StatelessWidget {
  const _DesktopLinkPage();
  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.devices_rounded, size: 64, color: t.accent),
          const SizedBox(height: 24),
          Text(
            l10n.linkConnectDesktop,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: t.text,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.linkOnboardingDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: t.muted, fontSize: 15),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => const LokalDesktopLinkScreen()),
            ),
            child: Text(l10n.linkDesktop),
          ),
        ],
      ),
    );
  }
}
