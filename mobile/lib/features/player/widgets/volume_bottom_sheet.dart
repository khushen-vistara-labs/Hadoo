import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flick/services/player_volume_control.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flick/core/theme/app_colors.dart';
import 'package:flick/services/player_service.dart';
import 'package:flick/widgets/common/glass_bottom_sheet.dart';
import 'package:flick/l10n/l10n.dart';

class VolumeBottomSheet extends StatefulWidget {
  final PlayerService playerService;
  const VolumeBottomSheet({super.key, required this.playerService});

  static Future<void> show(BuildContext context, PlayerService playerService) {
    return showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => VolumeBottomSheet(playerService: playerService),
    );
  }

  @override
  State<VolumeBottomSheet> createState() => _VolumeBottomSheetState();
}

class _VolumeBottomSheetState extends State<VolumeBottomSheet> {
  late final PlayerVolumeControl _volumeControl;

  @override
  void initState() {
    super.initState();
    _volumeControl = PlayerVolumeControl(widget.playerService);
  }

  @override
  void dispose() {
    _volumeControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _volumeControl,
      builder: (context, _) {
        final maxVolume = _volumeControl.max;
        final currentVolume = _volumeControl.value;
        final isAvailable = _volumeControl.available;
        return Container(
          decoration: AppBottomSheetSurface.decoration,
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    currentVolume > 0
                        ? LucideIcons.volume2
                        : LucideIcons.volumeX,
                    color: AppColors.accent,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.volume,
                    style: TextStyle(
                      fontFamily: 'HadooMono',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(currentVolume * 100).round()}%',
                    style: TextStyle(
                      fontFamily: 'HadooMono',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    LucideIcons.volume1,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  Expanded(
                    child: Slider(
                      value: currentVolume,
                      min: 0.0,
                      max: maxVolume,
                      divisions: (maxVolume * 100).round(),
                      label: '${(currentVolume * 100).round()}%',
                      onChanged: isAvailable
                          ? (value) => unawaited(_volumeControl.set(value))
                          : null,
                      activeColor: AppColors.accent,
                      inactiveColor: AppColors.textTertiary.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  Icon(
                    LucideIcons.volume2,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ],
              ),
              if (!isAvailable && !_volumeControl.usesSystemVolume) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.volumeIsFixedWhileBitPerfect,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
