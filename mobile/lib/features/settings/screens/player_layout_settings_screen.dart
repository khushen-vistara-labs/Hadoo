import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flick/core/constants/app_constants.dart';
import 'package:flick/models/player_screen_mode.dart';
import 'package:flick/models/player_action_button.dart';
import 'package:flick/models/song.dart';
import 'package:flick/providers/providers.dart';
import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/widgets/lokal/settings/lokal_settings_kit.dart';
import 'package:flick/widgets/common/cached_image_widget.dart';
import 'package:flick/widgets/common/flick_artwork_placeholder.dart';

import 'package:flick/l10n/l10n.dart';

String _placementLabel(double value) {
  if (value == 0) return l10n.center;
  return value < 0 ? l10n.up(value.abs().round()) : l10n.down(value.round());
}

String _percentLabel(double value) => '${(value * 100).round()}%';

class PlayerLayoutSettingsScreen extends ConsumerWidget {
  const PlayerLayoutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appPrefs = ref.watch(appPreferencesProvider);
    final playerScreenMode = ref.watch(playerScreenModeProvider);

    final notifier = ref.read(appPreferencesProvider.notifier);

    LokalSettingSlider slider({
      required String label,
      required String description,
      required double value,
      required double min,
      required double max,
      required int divisions,
      required String Function(double) valueLabel,
      required ValueChanged<double> onChanged,
    }) => LokalSettingSlider(
      label: label,
      description: description,
      value: value,
      min: min,
      max: max,
      divisions: divisions,
      valueLabel: valueLabel,
      live: true,
      onChanged: onChanged,
    );

    LokalSettingLink actionLink(
      String title,
      String stored,
      ValueChanged<PlayerActionButton> save,
    ) {
      final current = PlayerActionButtonX.fromStorageValue(stored);
      return LokalSettingLink(
        label: title,
        value: current.label.toUpperCase(),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _ActionButtonPickerScreen(
              title: title,
              currentValue: current,
              onSelected: save,
            ),
          ),
        ),
      );
    }

    return LokalSettingsScaffold(
      title: l10n.playerLayout,
      subtitle:
          'How Now Playing is laid out. Tap the preview to see it full size.',
      children: [
        LokalSettingsBlock(
          top: 16,
          child: Semantics(
            button: true,
            label: l10n.fullscreen,
            child: GestureDetector(
              onTap: () => _showFullScreenPreview(context, ref),
              child: Stack(
                children: [
                  _LayoutPreview(
                    song: ref.watch(currentSongProvider),
                    mode: playerScreenMode,
                    artworkCardArtworkScale: appPrefs.artworkCardArtworkScale,
                    artworkCardTextScale: appPrefs.artworkCardTextScale,
                    artworkCardVerticalOffset:
                        appPrefs.artworkCardVerticalOffset,
                    artworkCardArtworkOffset: appPrefs.artworkCardArtworkOffset,
                    artworkCardShowTitle: appPrefs.artworkCardShowTitle,
                    artworkCardShowArtist: appPrefs.artworkCardShowArtist,
                    artworkCardShowAlbum: appPrefs.artworkCardShowAlbum,
                    artworkCardShowFileInfo: appPrefs.artworkCardShowFileInfo,
                    artworkCardShowFrame: appPrefs.artworkCardShowFrame,
                    immersiveTextScale: appPrefs.immersiveTextScale,
                    immersiveVerticalOffset: appPrefs.immersiveVerticalOffset,
                    immersiveFullViewScale: appPrefs.immersiveFullViewScale,
                    immersiveShowTitle: appPrefs.immersiveShowTitle,
                    immersiveShowArtist: appPrefs.immersiveShowArtist,
                    immersiveShowFileInfo: appPrefs.immersiveShowFileInfo,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: LokalStatusPill(label: l10n.fullscreen),
                  ),
                ],
              ),
            ),
          ),
        ),
        LokalSettingsSection(
          title: l10n.layoutMode,
          children: [
            for (final mode in [
              PlayerScreenMode.immersive,
              PlayerScreenMode.artworkCard,
            ])
              LokalSettingRow.option(
                label: mode.label,
                description: mode.description,
                selected: playerScreenMode == mode,
                onTap: () =>
                    ref.read(playerScreenModeProvider.notifier).setMode(mode),
              ),
          ],
        ),
        LokalSettingsSection(
          title: l10n.immersive,
          children: [
            slider(
              label: l10n.textSize2,
              description: l10n.adjustMetadataTextSizeInImmersive,
              value: appPrefs.immersiveTextScale,
              valueLabel: _percentLabel,
              min: 0.82,
              max: 1.2,
              divisions: 19,
              onChanged: notifier.setImmersiveTextScale,
            ),
            slider(
              label: l10n.textPlacement2,
              description: l10n.shiftMetadataTextUpOrDown,
              value: appPrefs.immersiveVerticalOffset,
              valueLabel: _placementLabel,
              min: -36,
              max: 36,
              divisions: 12,
              onChanged: notifier.setImmersiveVerticalOffset,
            ),
            slider(
              label: l10n.fullViewCardSize2,
              description: l10n.scaleTheFullViewAlbumArt,
              value: appPrefs.immersiveFullViewScale,
              valueLabel: _percentLabel,
              min: 0.82,
              max: 1.18,
              divisions: 18,
              onChanged: notifier.setImmersiveFullViewScale,
            ),
            LokalSettingRow.toggle(
              label: l10n.showTitle2,
              description: l10n.displayTheTrackTitleInImmersive,
              value: appPrefs.immersiveShowTitle,
              onChanged: notifier.setImmersiveShowTitle,
            ),
            LokalSettingRow.toggle(
              label: l10n.showArtist2,
              description: l10n.displayTheArtistNameInImmersive,
              value: appPrefs.immersiveShowArtist,
              onChanged: notifier.setImmersiveShowArtist,
            ),
            LokalSettingRow.toggle(
              label: l10n.showFileInfo2,
              description: l10n.displayFileFormatAndBitrateIn,
              value: appPrefs.immersiveShowFileInfo,
              onChanged: notifier.setImmersiveShowFileInfo,
            ),
            slider(
              label: l10n.autoFullView,
              description: l10n.autoShowFullViewAfterInactivity,
              value: appPrefs.immersiveAutoFullViewSeconds.toDouble(),
              valueLabel: (v) => v.round() == 0 ? l10n.off : '${v.round()}s',
              min: 0,
              max: 15,
              divisions: 15,
              onChanged: (value) =>
                  notifier.setImmersiveAutoFullViewSeconds(value.round()),
            ),
          ],
        ),
        LokalSettingsSection(
          title: l10n.artworkCard,
          children: [
            slider(
              label: l10n.artworkSize2,
              description: l10n.scaleTheAlbumArtCard,
              value: appPrefs.artworkCardArtworkScale,
              valueLabel: _percentLabel,
              min: 0.8,
              max: 1.36,
              divisions: 28,
              onChanged: notifier.setArtworkCardArtworkScale,
            ),
            slider(
              label: l10n.textSize2,
              description: l10n.adjustMetadataTextSizeInArtwork,
              value: appPrefs.artworkCardTextScale,
              valueLabel: _percentLabel,
              min: 0.82,
              max: 1.2,
              divisions: 19,
              onChanged: notifier.setArtworkCardTextScale,
            ),
            slider(
              label: l10n.contentPlacement2,
              description: l10n.shiftOnlyTheSongDetailsUp,
              value: appPrefs.artworkCardVerticalOffset,
              valueLabel: _placementLabel,
              min: -36,
              max: 36,
              divisions: 12,
              onChanged: notifier.setArtworkCardVerticalOffset,
            ),
            slider(
              label: l10n.artworkPlacement2,
              description: l10n.shiftOnlyTheAlbumArtUp,
              value: appPrefs.artworkCardArtworkOffset,
              valueLabel: _placementLabel,
              min: -48,
              max: 48,
              divisions: 16,
              onChanged: notifier.setArtworkCardArtworkOffset,
            ),
            LokalSettingRow.toggle(
              label: l10n.showTitle2,
              description: l10n.displayTheTrackTitleInArtwork,
              value: appPrefs.artworkCardShowTitle,
              onChanged: notifier.setArtworkCardShowTitle,
            ),
            LokalSettingRow.toggle(
              label: l10n.showArtist2,
              description: l10n.displayTheArtistNameInArtwork,
              value: appPrefs.artworkCardShowArtist,
              onChanged: notifier.setArtworkCardShowArtist,
            ),
            LokalSettingRow.toggle(
              label: l10n.showAlbum2,
              description: l10n.displayTheAlbumNameInArtwork,
              value: appPrefs.artworkCardShowAlbum,
              onChanged: notifier.setArtworkCardShowAlbum,
            ),
            LokalSettingRow.toggle(
              label: l10n.showFileInfo2,
              description: l10n.displayFileFormatAndBitrateIn2,
              value: appPrefs.artworkCardShowFileInfo,
              onChanged: notifier.setArtworkCardShowFileInfo,
            ),
            LokalSettingRow.toggle(
              label: l10n.showFrame2,
              description: l10n.showTheGlassFrameAroundAlbum,
              value: appPrefs.artworkCardShowFrame,
              onChanged: notifier.setArtworkCardShowFrame,
            ),
            LokalSettingRow.toggle(
              label: l10n.bitPerfectCapsule,
              description: l10n.replaceAlbumNameWithAVerified,
              value: appPrefs.replaceAlbumWithBitPerfectCapsule,
              onChanged: notifier.setReplaceAlbumWithBitPerfectCapsule,
            ),
          ],
        ),
        LokalSettingsSection(
          title: l10n.quickActions,
          children: [
            actionLink(
              l10n.leftTopButton,
              appPrefs.leftTopActionButton,
              (a) => notifier.setLeftTopActionButton(a.storageValue),
            ),
            actionLink(
              l10n.leftBottomButton,
              appPrefs.leftActionButton,
              (a) => notifier.setLeftActionButton(a.storageValue),
            ),
            actionLink(
              l10n.rightTopButton,
              appPrefs.rightTopActionButton,
              (a) => notifier.setRightTopActionButton(a.storageValue),
            ),
            actionLink(
              l10n.rightBottomButton,
              appPrefs.rightActionButton,
              (a) => notifier.setRightActionButton(a.storageValue),
            ),
          ],
        ),
      ],
    );
  }

  void _showFullScreenPreview(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.88),
        transitionDuration: AppConstants.animationNormal,
        reverseTransitionDuration: AppConstants.animationNormal,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Consumer(
              builder: (context, ref, _) {
                final appPrefs = ref.watch(appPreferencesProvider);
                final mode = ref.watch(playerScreenModeProvider);
                return SafeArea(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _FullScreenPreview(
                          song: ref.watch(currentSongProvider),
                          mode: mode,
                          artworkCardArtworkScale:
                              appPrefs.artworkCardArtworkScale,
                          artworkCardTextScale: appPrefs.artworkCardTextScale,
                          artworkCardVerticalOffset:
                              appPrefs.artworkCardVerticalOffset,
                          artworkCardArtworkOffset:
                              appPrefs.artworkCardArtworkOffset,
                          artworkCardShowTitle: appPrefs.artworkCardShowTitle,
                          artworkCardShowArtist: appPrefs.artworkCardShowArtist,
                          artworkCardShowAlbum: appPrefs.artworkCardShowAlbum,
                          artworkCardShowFileInfo:
                              appPrefs.artworkCardShowFileInfo,
                          artworkCardShowFrame: appPrefs.artworkCardShowFrame,
                          immersiveTextScale: appPrefs.immersiveTextScale,
                          immersiveVerticalOffset:
                              appPrefs.immersiveVerticalOffset,
                          immersiveFullViewScale:
                              appPrefs.immersiveFullViewScale,
                          immersiveShowTitle: appPrefs.immersiveShowTitle,
                          immersiveShowArtist: appPrefs.immersiveShowArtist,
                          immersiveShowFileInfo: appPrefs.immersiveShowFileInfo,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    mode == PlayerScreenMode.immersive
                                        ? Icons.fit_screen_rounded
                                        : Icons.rounded_corner_rounded,
                                    size: 18,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    mode.label,
                                    style: TextStyle(
                                      fontFamily: LokalTheme.sans,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(
                                        alpha: 0.72,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

String _fileInfoLabel(Song? song) {
  if (song == null) return '';
  final type = song.fileType;
  final res = song.resolution;
  if (res != null && res.isNotEmpty) return '$type  $res';
  return type;
}

class _LayoutPreview extends StatelessWidget {
  const _LayoutPreview({
    required this.song,
    required this.mode,
    required this.artworkCardArtworkScale,
    required this.artworkCardTextScale,
    required this.artworkCardVerticalOffset,
    required this.artworkCardArtworkOffset,
    required this.artworkCardShowTitle,
    required this.artworkCardShowArtist,
    required this.artworkCardShowAlbum,
    required this.artworkCardShowFileInfo,
    required this.artworkCardShowFrame,
    required this.immersiveTextScale,
    required this.immersiveVerticalOffset,
    required this.immersiveFullViewScale,
    required this.immersiveShowTitle,
    required this.immersiveShowArtist,
    required this.immersiveShowFileInfo,
  });

  final Song? song;
  final PlayerScreenMode mode;
  final double artworkCardArtworkScale;
  final double artworkCardTextScale;
  final double artworkCardVerticalOffset;
  final double artworkCardArtworkOffset;
  final bool artworkCardShowTitle;
  final bool artworkCardShowArtist;
  final bool artworkCardShowAlbum;
  final bool artworkCardShowFileInfo;
  final bool artworkCardShowFrame;
  final double immersiveTextScale;
  final double immersiveVerticalOffset;
  final double immersiveFullViewScale;
  final bool immersiveShowTitle;
  final bool immersiveShowArtist;
  final bool immersiveShowFileInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: context.lokal.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.lokal.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Icon(
                  Icons.preview_rounded,
                  size: 16,
                  color: context.lokal.muted,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.livePreview.toUpperCase(),
                  style: LokalTheme.label(context.lokal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 180,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF232323),
                  Color(0xFF121212),
                  Color(0xFF2A1A3A),
                ],
              ),
            ),
            child: Stack(
              children: [
                if (song == null)
                  Center(
                    child: Text(
                      l10n.noSongPlaying,
                      style: TextStyle(
                        fontFamily: LokalTheme.sans,
                        fontSize: 14,
                        color: Color(0xFF888888),
                      ),
                    ),
                  )
                else
                  Positioned.fill(
                    child: mode == PlayerScreenMode.artworkCard
                        ? _buildArtworkCardPreview(context)
                        : _buildImmersivePreview(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkCardPreview(BuildContext context) {
    final artSize = 70.0 * artworkCardArtworkScale;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, artworkCardArtworkOffset * 0.45),
          child: _AlbumArtThumb(song: song, size: artSize, radius: 18),
        ),
        const SizedBox(height: 10),
        Transform.translate(
          offset: Offset(0, artworkCardVerticalOffset * 0.45),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (artworkCardShowTitle)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    song?.title ?? l10n.unknown,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: LokalTheme.sans,
                      fontSize: 17 * artworkCardTextScale,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (artworkCardShowTitle && artworkCardShowArtist)
                const SizedBox(height: 4),
              if (artworkCardShowArtist)
                Text(
                  song?.artist ?? l10n.unknownArtist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: LokalTheme.sans,
                    fontSize: 12 * artworkCardTextScale,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              if (artworkCardShowAlbum) ...[
                if ((artworkCardShowTitle || artworkCardShowArtist))
                  const SizedBox(height: 2),
                Text(
                  song?.album ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: LokalTheme.sans,
                    fontSize: 11 * artworkCardTextScale,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
              if (artworkCardShowFileInfo && song != null)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    _fileInfoLabel(song),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: LokalTheme.sans,
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.48),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImmersivePreview(BuildContext context) {
    final artSize = 38.0 * immersiveFullViewScale;
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.28,
            child: _AlbumArtThumb(song: song, size: double.infinity, radius: 0),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 14,
          child: Transform.translate(
            offset: Offset(0, immersiveVerticalOffset * 0.45),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.all(7 * immersiveFullViewScale),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.34),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: _AlbumArtThumb(song: song, size: artSize, radius: 12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (immersiveShowTitle)
                        Text(
                          song?.title ?? l10n.unknown,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: LokalTheme.sans,
                            fontSize: 18 * immersiveTextScale,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                            color: Colors.white,
                          ),
                        ),
                      if (immersiveShowTitle && immersiveShowArtist)
                        const SizedBox(height: 5),
                      if (immersiveShowArtist)
                        Text(
                          song?.artist ?? l10n.unknownArtist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: LokalTheme.sans,
                            fontSize: 12 * immersiveTextScale,
                            color: Colors.white.withValues(alpha: 0.76),
                          ),
                        ),
                      if (immersiveShowFileInfo && song != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _fileInfoLabel(song),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: LokalTheme.sans,
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.48),
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
      ],
    );
  }
}

class _AlbumArtThumb extends StatelessWidget {
  const _AlbumArtThumb({
    required this.song,
    required this.size,
    required this.radius,
  });

  final Song? song;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: CachedImageWidget(
          imagePath: song?.albumArt,
          audioSourcePath: song?.filePath,
          fit: BoxFit.cover,
          placeholder: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4B3D7A), Color(0xFF111111)],
              ),
            ),
            child: const Center(
              child: FlickArtworkPlaceholder(size: 36, opacity: 0.9),
            ),
          ),
          errorWidget: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4B3D7A), Color(0xFF111111)],
              ),
            ),
            child: const Center(
              child: FlickArtworkPlaceholder(size: 36, opacity: 0.9),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButtonPickerScreen extends ConsumerWidget {
  const _ActionButtonPickerScreen({
    required this.title,
    required this.currentValue,
    required this.onSelected,
  });

  final String title;
  final PlayerActionButton currentValue;
  final ValueChanged<PlayerActionButton> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LokalSettingsScaffold(
      title: title,
      children: [
        LokalSettingsSection(
          title: l10n.chooseAction,
          children: [
            for (final action in PlayerActionButton.values)
              LokalSettingRow.option(
                icon: action.icon,
                label: action.label,
                selected: action == currentValue,
                onTap: () {
                  onSelected(action);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _FullScreenPreview extends StatelessWidget {
  const _FullScreenPreview({
    required this.song,
    required this.mode,
    required this.artworkCardArtworkScale,
    required this.artworkCardTextScale,
    required this.artworkCardVerticalOffset,
    required this.artworkCardArtworkOffset,
    this.artworkCardShowTitle = true,
    this.artworkCardShowArtist = true,
    this.artworkCardShowAlbum = true,
    this.artworkCardShowFileInfo = true,
    this.artworkCardShowFrame = true,
    required this.immersiveTextScale,
    required this.immersiveVerticalOffset,
    required this.immersiveFullViewScale,
    this.immersiveShowTitle = true,
    this.immersiveShowArtist = true,
    this.immersiveShowFileInfo = true,
  });

  final Song? song;
  final PlayerScreenMode mode;
  final double artworkCardArtworkScale;
  final double artworkCardTextScale;
  final double artworkCardVerticalOffset;
  final double artworkCardArtworkOffset;
  final bool artworkCardShowTitle;
  final bool artworkCardShowArtist;
  final bool artworkCardShowAlbum;
  final bool artworkCardShowFileInfo;
  final bool artworkCardShowFrame;
  final double immersiveTextScale;
  final double immersiveVerticalOffset;
  final double immersiveFullViewScale;
  final bool immersiveShowTitle;
  final bool immersiveShowArtist;
  final bool immersiveShowFileInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF232323),
            context.lokal.bg,
            context.lokal.accent.withValues(alpha: 0.28),
          ],
        ),
      ),
      child: mode == PlayerScreenMode.artworkCard
          ? _buildArtworkCardFullScreen(context)
          : _buildImmersiveFullScreen(context),
    );
  }

  Widget _buildArtworkCardFullScreen(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final artSize =
            (maxWidth * 0.68).clamp(180.0, 380.0) * artworkCardArtworkScale;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, artworkCardArtworkOffset * 1.0),
              child: _AlbumArtThumb(song: song, size: artSize, radius: 28),
            ),
            const SizedBox(height: 24),
            Transform.translate(
              offset: Offset(0, artworkCardVerticalOffset * 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (artworkCardShowTitle)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        song?.title ?? l10n.midnightSignal,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: LokalTheme.sans,
                          fontSize: 28 * artworkCardTextScale,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (artworkCardShowTitle && artworkCardShowArtist)
                    const SizedBox(height: 8),
                  if (artworkCardShowArtist)
                    Text(
                      song?.artist ?? l10n.flickPreview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: LokalTheme.sans,
                        fontSize: 17 * artworkCardTextScale,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  if (artworkCardShowArtist && artworkCardShowAlbum)
                    const SizedBox(height: 6),
                  if (artworkCardShowAlbum)
                    Text(
                      song?.album ?? l10n.mirrorTest,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: LokalTheme.sans,
                        fontSize: 14 * artworkCardTextScale,
                        color: Colors.white.withValues(alpha: 0.56),
                      ),
                    ),
                  if (artworkCardShowFileInfo)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _fileInfoLabel(song),
                        style: TextStyle(
                          fontFamily: LokalTheme.sans,
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImmersiveFullScreen(BuildContext context) {
    final artSize = 64.0 * immersiveFullViewScale;
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.32,
            child: _AlbumArtThumb(song: song, size: double.infinity, radius: 0),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 36,
          child: Transform.translate(
            offset: Offset(0, immersiveVerticalOffset * 1.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.all(10 * immersiveFullViewScale),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.34),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: _AlbumArtThumb(song: song, size: artSize, radius: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (immersiveShowTitle)
                        Text(
                          song?.title ?? l10n.midnightSignal,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: LokalTheme.sans,
                            fontSize: 32 * immersiveTextScale,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                            color: Colors.white,
                          ),
                        ),
                      if (immersiveShowTitle && immersiveShowArtist)
                        const SizedBox(height: 8),
                      if (immersiveShowArtist)
                        Text(
                          song?.artist ?? l10n.flickPreview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: LokalTheme.sans,
                            fontSize: 18 * immersiveTextScale,
                            color: Colors.white.withValues(alpha: 0.76),
                          ),
                        ),
                      if (immersiveShowFileInfo)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _fileInfoLabel(song),
                            style: TextStyle(
                              fontFamily: LokalTheme.sans,
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.4),
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
      ],
    );
  }
}
