import 'material_player_thumb.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flick/providers/favorites_provider.dart';
import 'package:flick/widgets/lokal/lokal_toast.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flick/services/player_service.dart';
import 'package:flick/services/player_volume_control.dart';
import 'package:flick/models/song.dart';
import 'package:flick/models/shuffle_mode.dart';
import 'package:flick/models/album_color_mode.dart';
import 'package:flick/core/theme/app_colors.dart';
import 'package:flick/core/utils/app_haptics.dart';
import 'package:flick/core/utils/responsive.dart';
import 'package:flick/features/player/widgets/album_color_helpers.dart';
import 'package:flick/features/player/widgets/shuffle_mode_sheet.dart';
import 'package:flick/features/player/widgets/loop_mode_sheet.dart';
import 'package:flick/services/favorites_service.dart';

import 'package:flick/l10n/l10n.dart';

class PlayerControls extends StatelessWidget {
  final PlayerService playerService;
  final String Function(Duration) formatDuration;
  final Song? currentSong;
  final Future<void> Function() onPrevious;
  final Future<void> Function() onNext;
  final double timelineHorizontalPadding;
  final AlbumColorMode albumColorMode;
  final Color? albumColor;
  final bool showTimeLabels;
  final bool targetLayout;
  final FavoritesService? favoritesService;

  const PlayerControls({
    super.key,
    required this.playerService,
    required this.formatDuration,
    required this.currentSong,
    required this.onPrevious,
    required this.onNext,
    this.timelineHorizontalPadding = 0,
    this.albumColorMode = AlbumColorMode.off,
    this.albumColor,
    this.showTimeLabels = true,
    this.targetLayout = false,
    this.favoritesService,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceBlend = albumColorMode.surfaceBlend;
    final accentBlend = albumColorMode.accentBlend;
    final hasAlbumTint = albumColor != null && surfaceBlend > 0;

    final buttonSurface = hasAlbumTint
        ? albumSurface(albumColor!, surfaceBlend)
        : const Color(0xFF121212);
    final activeAccent = hasAlbumTint
        ? albumAccent(albumColor!, accentBlend)
        : AppColors.accent;

    if (targetLayout) {
      return _TargetPlayerControls(
        playerService: playerService,
        currentSong: currentSong,
        onPrevious: onPrevious,
        onNext: onNext,
        albumColor: albumColor,
        albumColorMode: albumColorMode,
        favoritesService: favoritesService,
      );
    }

    return RepaintBoundary(
      child: ValueListenableBuilder<Duration>(
        valueListenable: playerService.positionNotifier,
        builder: (context, position, _) {
          return ValueListenableBuilder<Duration>(
            valueListenable: playerService.durationNotifier,
            builder: (context, engineDuration, _) {
              final duration = engineDuration.inMilliseconds > 0
                  ? engineDuration
                  : (currentSong?.duration ?? Duration.zero);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    alignment: Alignment.bottomCenter,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      opacity: showTimeLabels ? 1.0 : 0.0,
                      child: showTimeLabels
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PlaybackTimeLabels(
                                  position: position,
                                  duration: duration,
                                  formatDuration: formatDuration,
                                  horizontalPadding: timelineHorizontalPadding,
                                ),
                                const SizedBox(height: 12),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Shuffle
                      ValueListenableBuilder<ShuffleMode>(
                        valueListenable: playerService.shuffleModeNotifier,
                        builder: (context, shuffleMode, _) {
                          final isActive = shuffleMode.isActive;
                          final icon = switch (shuffleMode) {
                            ShuffleMode.categories => LucideIcons.layers,
                            ShuffleMode.random => LucideIcons.dices,
                            _ => LucideIcons.shuffle,
                          };
                          return GestureDetector(
                            onTap: () {
                              AppHaptics.tap();
                              playerService.toggleShuffle();
                              final next =
                                  playerService.shuffleModeNotifier.value;
                              LokalToast.fromSnackBar(context, 
                                  SnackBar(
                                    content: Text(l10n.shuffle2(next.label)),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                            },
                            onLongPress: () {
                              AppHaptics.tap();
                              ShuffleModeSheet.show(context, playerService);
                            },
                            child: Container(
                              width: context.responsive(40.0, 44.0, 48.0),
                              height: context.responsive(40.0, 44.0, 48.0),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? activeAccent.withValues(alpha: 0.25)
                                    : buttonSurface.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                                border: isActive
                                    ? Border.all(
                                        color: activeAccent.withValues(
                                          alpha: 0.6,
                                        ),
                                        width: 1.5,
                                      )
                                    : null,
                              ),
                              child: Icon(
                                icon,
                                size: context.responsive(18.0, 20.0, 22.0),
                                color: isActive
                                    ? activeAccent
                                    : Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: context.responsive(14.0, 18.0, 22.0)),
                      // Previous
                      Container(
                        width: context.responsive(40.0, 44.0, 48.0),
                        height: context.responsive(40.0, 44.0, 48.0),
                        decoration: BoxDecoration(
                          color: buttonSurface.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            AppHaptics.tap();
                            onPrevious();
                          },
                          iconSize: context.responsive(18.0, 20.0, 22.0),
                          padding: EdgeInsets.zero,
                          icon: Icon(LucideIcons.skipBack, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: context.responsive(14.0, 18.0, 22.0)),
                      // Play/Pause
                      _PlayPauseButton(
                        playerService: playerService,
                        albumColorMode: albumColorMode,
                        albumColor: albumColor,
                      ),
                      SizedBox(width: context.responsive(14.0, 18.0, 22.0)),
                      // Next
                      Container(
                        width: context.responsive(40.0, 44.0, 48.0),
                        height: context.responsive(40.0, 44.0, 48.0),
                        decoration: BoxDecoration(
                          color: buttonSurface.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            AppHaptics.tap();
                            onNext();
                          },
                          iconSize: context.responsive(18.0, 20.0, 22.0),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            LucideIcons.skipForward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: context.responsive(14.0, 18.0, 22.0)),
                      // Repeat/Loop
                      ValueListenableBuilder<LoopMode>(
                        valueListenable: playerService.loopModeNotifier,
                        builder: (context, loopMode, _) {
                          final icon = LoopModeSheet.iconFor(loopMode);
                          final isActive = loopMode != LoopMode.off;
                          final color = isActive
                              ? activeAccent
                              : Colors.white.withValues(alpha: 0.7);
                          return GestureDetector(
                            onTap: () {
                              AppHaptics.tap();
                              playerService.toggleLoopMode();
                              final next = playerService.loopModeNotifier.value;
                              LokalToast.fromSnackBar(context, 
                                  SnackBar(
                                    content: Text(l10n.repeat(next.label)),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                            },
                            onLongPress: () {
                              AppHaptics.tap();
                              LoopModeSheet.show(context, playerService);
                            },
                            child: Container(
                              width: context.responsive(40.0, 44.0, 48.0),
                              height: context.responsive(40.0, 44.0, 48.0),
                              decoration: BoxDecoration(
                                color: buttonSurface.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    icon,
                                    size: context.responsive(18.0, 20.0, 22.0),
                                    color: color,
                                  ),
                                  if (loopMode == LoopMode.all)
                                    Positioned(
                                      bottom: 6,
                                      child: Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: activeAccent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _TargetPlayerControls extends StatefulWidget {
  const _TargetPlayerControls({
    required this.playerService,
    required this.currentSong,
    required this.onPrevious,
    required this.onNext,
    required this.albumColor,
    required this.albumColorMode,
    required this.favoritesService,
  });

  final PlayerService playerService;
  final Song? currentSong;
  final Future<void> Function() onPrevious;
  final Future<void> Function() onNext;
  final Color? albumColor;
  final AlbumColorMode albumColorMode;
  final FavoritesService? favoritesService;

  @override
  State<_TargetPlayerControls> createState() => _TargetPlayerControlsState();
}

class _TargetPlayerControlsState extends State<_TargetPlayerControls> {
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

  Color get _accent {
    final color = widget.albumColor;
    return color == null
        ? AppColors.accent
        : albumAccent(color, widget.albumColorMode.accentBlend);
  }

  Color get _surface {
    return Colors.white.withValues(alpha: .08);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: context.responsive(100, 110, 120),
              child: _mainButton(
                context,
                icon: LucideIcons.skipBack,
                label: 'Previous',
                onTap: () => unawaited(widget.onPrevious()),
              ),
            ),
            SizedBox(width: context.responsive(6, 8, 10)),
            SizedBox(
              width: context.responsive(124, 136, 148),
              child: ValueListenableBuilder<bool>(
                valueListenable: widget.playerService.isPlayingNotifier,
                builder: (context, isPlaying, _) => _mainButton(
                  context,
                  icon: isPlaying ? LucideIcons.pause : LucideIcons.play,
                  label: isPlaying ? 'Pause' : 'Play',
                  primary: true,
                  onTap: () {
                    AppHaptics.tap();
                    widget.playerService.togglePlayPause();
                  },
                ),
              ),
            ),
            SizedBox(width: context.responsive(6, 8, 10)),
            SizedBox(
              width: context.responsive(100, 110, 120),
              child: _mainButton(
                context,
                icon: LucideIcons.skipForward,
                label: 'Next',
                onTap: () => unawaited(widget.onNext()),
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsive(10, 12, 14)),
        _secondaryRow(context),
      ],
    );
  }

  Widget _mainButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    final background = primary ? Colors.white.withValues(alpha: .88) : _surface;
    final foreground = primary
        ? Colors.black
        : Colors.white.withValues(alpha: .9);
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: primary ? background.withValues(alpha: .9) : background,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: context.responsive(86, 96, 104),
            child: Icon(
              icon,
              size: primary
                  ? context.responsive(29, 34, 38)
                  : context.responsive(24, 28, 32),
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _secondaryRow(BuildContext context) => ListenableBuilder(
    listenable: _volumeControl,
    builder: (context, _) => _buildSecondaryRow(context),
  );

  Widget _buildSecondaryRow(BuildContext context) {
    final maxVolume = _volumeControl.max;
    final available = _volumeControl.available;
    final volume = _volumeControl.value;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive(8, 10, 12),
        vertical: context.responsive(6, 8, 10),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: .13)),
      ),
      child: Row(
        children: [
          Icon(
            volume <= 0.001 ? LucideIcons.volumeX : LucideIcons.volume2,
            size: context.responsive(17, 19, 21),
            color: Colors.white.withValues(alpha: .88),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const MaterialPlayerThumb(),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: Colors.white.withValues(alpha: .78),
                inactiveTrackColor: Colors.white.withValues(alpha: .22),
                thumbColor: Colors.white,
              ),
              child: Slider(
                min: 0,
                max: maxVolume <= 0 ? 1 : maxVolume,
                value: volume,
                onChanged: available
                    ? (value) => unawaited(_volumeControl.set(value))
                    : null,
              ),
            ),
          ),
          SizedBox(width: context.responsive(6, 8, 10)),
          Container(
            width: 1,
            height: context.responsive(28, 32, 36),
            color: Colors.white.withValues(alpha: .14),
          ),
          SizedBox(width: context.responsive(6, 8, 10)),
          ValueListenableBuilder<ShuffleMode>(
            valueListenable: widget.playerService.shuffleModeNotifier,
            builder: (context, shuffleMode, _) => _smallButton(
              context,
              icon: LucideIcons.shuffle,
              active: shuffleMode.isActive,
              onTap: () => widget.playerService.toggleShuffle(),
              label: 'Shuffle',
            ),
          ),
          SizedBox(width: context.responsive(6, 8, 10)),
          ValueListenableBuilder<LoopMode>(
            valueListenable: widget.playerService.loopModeNotifier,
            builder: (context, loopMode, _) => _smallButton(
              context,
              icon: LoopModeSheet.iconFor(loopMode),
              active: loopMode != LoopMode.off,
              onTap: () => widget.playerService.toggleLoopMode(),
              label: 'Repeat',
            ),
          ),
          SizedBox(width: context.responsive(6, 8, 10)),
          _favoriteButton(context),
        ],
      ),
    );
  }

  Widget _smallButton(
    BuildContext context, {
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    required String label,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: IconButton(
        onPressed: () {
          AppHaptics.tap();
          onTap();
        },
        tooltip: label,
        style: IconButton.styleFrom(
          backgroundColor: active
              ? _accent.withValues(alpha: .24)
              : Colors.white.withValues(alpha: .05),
          side: BorderSide(
            color: active
                ? _accent.withValues(alpha: .62)
                : Colors.white.withValues(alpha: .14),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        icon: Icon(
          icon,
          size: context.responsive(17, 19, 21),
          color: active ? _accent : Colors.white.withValues(alpha: .86),
        ),
      ),
    );
  }

  Widget _favoriteButton(BuildContext context) {
    final song = widget.currentSong;
    if (song == null) {
      return const SizedBox.shrink();
    }
    return Consumer(
      builder: (context, ref, _) {
        final favorite = ref.watch(isSongFavoriteProvider(song.id));
        return _smallButton(
          context,
          icon: LucideIcons.heart,
          active: favorite,
          onTap: () async {
            await ref.read(favoritesProvider.notifier)
                .toggleFavorite(song.id, song: song);
            widget.playerService.refreshNotificationState();
          },
          label: 'Favorite',
        );
      },
    );
  }
}

class PlaybackTimeLabels extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final String Function(Duration) formatDuration;
  final double horizontalPadding;

  const PlaybackTimeLabels({
    super.key,
    required this.position,
    required this.duration,
    required this.formatDuration,
    this.horizontalPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formatDuration(position),
            style: const TextStyle(
              fontFamily: 'HadooMono',
              fontSize: 12,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            formatDuration(duration),
            style: const TextStyle(
              fontFamily: 'HadooMono',
              fontSize: 12,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Extracted play/pause button to minimize rebuilds when only play state changes
class _PlayPauseButton extends StatelessWidget {
  final PlayerService playerService;
  final AlbumColorMode albumColorMode;
  final Color? albumColor;

  const _PlayPauseButton({
    required this.playerService,
    this.albumColorMode = AlbumColorMode.off,
    this.albumColor,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceBlend = albumColorMode.surfaceBlend;
    final accentBlend = albumColorMode.accentBlend;
    final hasAlbumTint = albumColor != null && surfaceBlend > 0;

    final buttonSurface = hasAlbumTint
        ? albumSurface(albumColor!, surfaceBlend)
        : const Color(0xFF121212);
    final glowColor = hasAlbumTint
        ? albumAccent(albumColor!, accentBlend)
        : AppColors.accent;

    return RepaintBoundary(
      child: ValueListenableBuilder<bool>(
        valueListenable: playerService.isPlayingNotifier,
        builder: (context, isPlaying, _) {
          final buttonSize = context.responsive(58.0, 64.0, 68.0);
          final iconSize = context.responsive(26.0, 28.0, 30.0);

          return Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: buttonSurface.withValues(alpha: 0.6),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.4),
                  blurRadius: context.responsive(14.0, 18.0, 22.0),
                  offset: Offset(0, context.responsive(5.0, 6.0, 7.0)),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                AppHaptics.tap();
                playerService.togglePlayPause();
              },
              iconSize: iconSize,
              padding: EdgeInsets.zero,
              icon: Icon(
                isPlaying ? LucideIcons.pause : LucideIcons.play,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}
