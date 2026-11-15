import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flick/core/constants/app_constants.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/core/utils/navigation_helper.dart';
import 'package:flick/features/menu/screens/restarting_screen.dart';
import 'package:flick/l10n/l10n.dart';

/// Inline "restart required" prompt shown after the audio engine is changed.
///
/// Self-contained: tapping Restart pushes [RestartingScreen], which hard-kills
/// and relaunches the app so the new engine takes effect.
class EngineRestartNotice extends StatelessWidget {
  const EngineRestartNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.accentDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(LucideIcons.refreshCcw, color: t.accent, size: 17),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.restartRequired,
                  style: TextStyle(
                    fontFamily: LokalTheme.sans,
                    fontSize: 14,
                    color: t.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXxs),
                Text(
                  l10n.yourNewAudioEngineIsReady,
                  style: TextStyle(
                    fontFamily: LokalTheme.sans,
                    fontSize: 12.5,
                    color: t.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          FilledButton(
            onPressed: () => NavigationHelper.pushOnRoot(
              context,
              PageRouteBuilder(
                opaque: true,
                transitionDuration: const Duration(milliseconds: 300),
                reverseTransitionDuration: Duration.zero,
                pageBuilder: (_, _, _) => const RestartingScreen(),
                transitionsBuilder: (context, animation, _, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: t.accent,
              foregroundColor: t.onAccent,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
                vertical: AppConstants.spacingSm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(l10n.restart),
          ),
        ],
      ),
    );
  }
}
