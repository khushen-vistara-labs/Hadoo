import 'package:flick/core/utils/artist_credits.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flick/core/constants/app_constants.dart';
import 'package:flick/core/utils/responsive.dart';
import 'package:flick/models/album_color_mode.dart';
import 'package:flick/models/player_screen_mode.dart';
import 'package:flick/models/song.dart';
import 'package:flick/providers/providers.dart';
import 'package:flick/services/lyrics_service.dart';
import 'package:flick/services/player_service.dart';
import 'package:flick/features/player/widgets/album_art_box.dart';
import 'package:flick/features/player/widgets/bit_perfect_capsule.dart';
import 'package:flick/features/player/widgets/bit_perfect_indicator.dart';
import 'package:flick/features/player/widgets/compact_player_info_layout.dart';
import 'package:flick/features/player/widgets/inline_lyrics_panel.dart';
import 'package:flick/features/player/widgets/lyrics_mode_waveform_strip.dart';
import 'package:flick/features/player/widgets/waveform_layer.dart';
import 'package:flick/widgets/common/cached_image_widget.dart';
import 'package:flick/widgets/common/flick_artwork_placeholder.dart';
import 'package:flick/widgets/common/marquee_widget.dart';

/// The sliding portion of the player: album art + title/artist/album +
/// file-info row + waveform. Background, top chrome and [PlayerControls]
/// stay pinned — only this stage translates during a swipe.
///
/// The file-info row keeps its layout slot even when hidden; the row is
/// then drawn pinned by the parent screen ([fileInfoRowVisible]).
class SongStage extends ConsumerWidget {
  static const double _shortHeightThreshold = 620.0;

  final Song song;
  final bool lyricsMode;
  final bool visualizationMode;
  final bool immersiveFullView;
  final PlayerScreenMode playerScreenMode;
  final AlbumColorMode albumColorMode;
  final Color? albumColor;
  final PlayerService playerService;
  final LyricsService lyricsService;
  final ValueNotifier<Duration> positionNotifier;
  final String Function(Duration) formatDuration;
  final void Function(Song song) onNavigateToArtistDetail;
  final void Function(Song song, String artistName)? onNavigateToArtistName;
  final void Function(Song song) onNavigateToAlbumDetail;
  final Widget Function(Song song, bool lyricsMode, PlayerScreenMode mode)
  buildFileInfoRow;

  /// Hides the row but keeps its slot (pinned row renders on top of it).
  final bool fileInfoRowVisible;
  final String visualizerAnimationStyle;
  final String visualizerFrequencyMode;
  final String visualizerMovementMode;
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
  final void Function(bool enabled)? onRotationEnabledChanged;
  final bool vinylMode;
  final ValueChanged<bool>? onVinylChanged;
  final VoidCallback onToggleLyrics;
  final bool showWaveform;

  /// Gates Motion Art on the album art box (e.g. only the settled carousel
  /// page keeps video running).
  final bool motionArtEnabled;

  /// True only for the carousel page of the currently playing song. Peek
  /// stages render lyrics statically instead of following playback.
  final bool active;

  const SongStage({
    super.key,
    required this.song,
    required this.lyricsMode,
    required this.visualizationMode,
    required this.immersiveFullView,
    required this.playerScreenMode,
    required this.albumColorMode,
    this.albumColor,
    required this.playerService,
    required this.lyricsService,
    required this.positionNotifier,
    required this.formatDuration,
    required this.onNavigateToArtistDetail,
    this.onNavigateToArtistName,
    required this.onNavigateToAlbumDetail,
    required this.buildFileInfoRow,
    this.fileInfoRowVisible = true,
    this.visualizerAnimationStyle = 'bars',
    this.visualizerFrequencyMode = 'full',
    this.visualizerMovementMode = 'bouncy',
    this.artworkCardArtworkScale = 1.0,
    this.artworkCardTextScale = 1.0,
    this.artworkCardVerticalOffset = 0.0,
    this.artworkCardArtworkOffset = 0.0,
    this.artworkCardShowTitle = true,
    this.artworkCardShowArtist = true,
    this.artworkCardShowAlbum = true,
    this.artworkCardShowFileInfo = true,
    this.artworkCardShowFrame = true,
    this.immersiveTextScale = 1.0,
    this.immersiveVerticalOffset = 0.0,
    this.immersiveFullViewScale = 1.0,
    this.immersiveShowTitle = true,
    this.immersiveShowArtist = true,
    this.immersiveShowFileInfo = true,
    this.onRotationEnabledChanged,
    this.vinylMode = false,
    this.onVinylChanged,
    required this.onToggleLyrics,
    this.showWaveform = true,
    this.motionArtEnabled = true,
    this.active = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuild the capsule when verification settles, not on every diagnostic tick.
    ref.watch(uac2BitPerfectIndicatorProvider);
    final isShortHeight =
        MediaQuery.sizeOf(context).height < _shortHeightThreshold;
    final showImmersiveFullView =
        immersiveFullView &&
        playerScreenMode == PlayerScreenMode.immersive &&
        !isShortHeight;
    final showVisualizerOnly = visualizationMode && showImmersiveFullView;

    // Inner switcher: immersive full-view vs default vs lyrics — keep the
    // same subtle slide+fade as before (not the song-to-song swipe).
    return AnimatedSwitcher(
      duration: AppConstants.animationNormal,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          fit: StackFit.expand,
          children: [...previousChildren, ?currentChild],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        final isFullView = child.key == const ValueKey('immersive-full-view');
        final slideOffset = isFullView
            ? const Offset(0, 0.12)
            : const Offset(0, 0.03);
        return SlideTransition(
          position: Tween<Offset>(begin: slideOffset, end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: showVisualizerOnly
          ? const KeyedSubtree(
              key: ValueKey('immersive-empty-overlay'),
              child: SizedBox.shrink(),
            )
          : showImmersiveFullView
          ? KeyedSubtree(
              key: const ValueKey('immersive-full-view'),
              child: SafeArea(child: _buildImmersiveFullViewLayout(context)),
            )
          : KeyedSubtree(
              key: const ValueKey('immersive-default-layout'),
              child: Column(
                children: [
                  Expanded(
                    child: playerScreenMode == PlayerScreenMode.artworkCard
                        ? _buildArtworkCardLayout(context)
                        : _buildImmersiveLayout(context),
                  ),
                ],
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Immersive
  // ---------------------------------------------------------------------------

  Widget _buildImmersiveLayout(BuildContext context) {
    final layout = lyricsMode
        ? KeyedSubtree(
            key: const ValueKey('immersive-lyrics-layout'),
            child: Column(
              children: [
                SizedBox(height: context.responsive(8.0, 10.0, 12.0)),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsive(20.0, 28.0, 36.0),
                    ),
                    child: InlineLyricsPanel(
                      song: song,
                      playerService: playerService,
                      lyricsService: lyricsService,
                      albumColor: albumColor,
                      positionNotifier: positionNotifier,
                      active: active,
                    ),
                  ),
                ),
                if (showWaveform) ...[
                  SizedBox(height: context.responsive(10.0, 12.0, 14.0)),
                  LyricsModeWaveformStrip(
                    playerService: playerService,
                    positionNotifier: positionNotifier,
                    currentSong: song,
                    formatDuration: formatDuration,
                    horizontalPadding: context.responsive(18.0, 24.0, 30.0),
                    onSwipeUp: onToggleLyrics,
                  ),
                ],
              ],
            ),
          )
        : KeyedSubtree(
            key: const ValueKey('immersive-default-layout'),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Transform.translate(
                  offset: Offset(0, immersiveVerticalOffset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsive(12.0, 16.0, 20.0),
                        ),
                        child: _buildImmersiveSongHeader(context),
                      ),
                      if (immersiveShowFileInfo) ...[
                        Builder(
                          builder: (context) {
                            final diagnostics = ProviderScope.containerOf(
                              context,
                            ).read(audioOutputDiagnosticsProvider);
                            final appPrefs = ProviderScope.containerOf(context)
                                .read(appPreferencesProvider);
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (diagnostics != null &&
                                    appPrefs
                                        .replaceAlbumWithBitPerfectCapsule) ...[
                                  SizedBox(
                                    height: context.responsive(6.0, 8.0, 10.0),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: context.responsive(
                                        12.0,
                                        16.0,
                                        20.0,
                                      ),
                                    ),
                                    child: BitPerfectCapsule(
                                      diagnostics: diagnostics,
                                      horizontalPadding: context.responsive(
                                        12.0,
                                        14.0,
                                        16.0,
                                      ),
                                      verticalPadding: context.responsive(
                                        4.0,
                                        5.0,
                                        6.0,
                                      ),
                                      fontSize: context.responsive(
                                        11.0,
                                        12.0,
                                        13.0,
                                      ),
                                      onTap: () {
                                        final deviceStatus =
                                            ProviderScope.containerOf(context)
                                                .read(uac2DeviceStatusProvider);
                                        BitPerfectIndicator.showInfoSheet(
                                          context,
                                          song: song,
                                          diagnostics: diagnostics,
                                          deviceStatus: deviceStatus,
                                          playerService: playerService,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                SizedBox(
                                  height: context.responsive(10.0, 12.0, 14.0),
                                ),
                                Visibility(
                                  visible: fileInfoRowVisible,
                                  maintainSize: true,
                                  maintainAnimation: true,
                                  maintainState: true,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: context.responsive(
                                        12.0,
                                        16.0,
                                        20.0,
                                      ),
                                    ),
                                    child: buildFileInfoRow(
                                      song,
                                      lyricsMode,
                                      playerScreenMode,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                if (showWaveform) ...[
                  SizedBox(height: context.responsive(12.0, 14.0, 16.0)),
                  _buildWaveformOnly(context),
                ],
              ],
            ),
          );

    if (AppConstants.animationNormal == Duration.zero) return layout;

    return AnimatedSwitcher(
      duration: AppConstants.animationNormal,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ...previousChildren,
            ...?currentChild == null ? null : [currentChild],
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final isLyricsChild =
            child.key == const ValueKey('immersive-lyrics-layout');
        final offsetAnimation = Tween<Offset>(
          begin: isLyricsChild ? const Offset(0, -0.04) : const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: layout,
    );
  }

  Widget _buildImmersiveFullViewLayout(BuildContext context) {
    final artworkSize =
        context.responsive(56.0, 60.0, 64.0) * immersiveFullViewScale;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.responsive(16.0, 20.0, 24.0),
          0,
          context.responsive(16.0, 20.0, 24.0),
          context.responsive(20.0, 24.0, 28.0),
        ),
        child: Container(
          padding: EdgeInsets.all(
            context.responsive(10.0, 12.0, 14.0) * immersiveFullViewScale,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF121212).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  18 * immersiveFullViewScale,
                ),
                child: SizedBox(
                  width: artworkSize,
                  height: artworkSize,
                  child: CachedImageWidget(
                    imagePath: song.albumArt,
                    audioSourcePath: song.filePath,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: Colors.white.withValues(alpha: 0.05),
                      child: FlickArtworkPlaceholder(
                        size: artworkSize * 0.44,
                        opacity: 0.92,
                      ),
                    ),
                    errorWidget: Container(
                      color: Colors.white.withValues(alpha: 0.05),
                      child: FlickArtworkPlaceholder(
                        size: artworkSize * 0.44,
                        opacity: 0.92,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.responsive(12.0, 14.0, 16.0)),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (immersiveShowTitle)
                      Text(
                        song.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'HadooMono',
                          fontSize: context.responsiveText(
                            context.responsive(18.0, 19.0, 21.0) *
                                immersiveTextScale,
                          ),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.12,
                        ),
                      ),
                    if (immersiveShowTitle && immersiveShowArtist)
                      SizedBox(height: context.responsive(6.0, 7.0, 8.0)),
                    if (immersiveShowArtist)
                      GestureDetector(
                        onTap: () => onNavigateToArtistDetail(song),
                        child: Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'HadooMono',
                            fontSize: context.responsiveText(
                              context.responsive(13.0, 14.0, 15.0) *
                                  immersiveTextScale,
                            ),
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.78),
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

  Widget _buildImmersiveSongHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (immersiveShowTitle)
                Text(
                  song.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'HadooMono',
                    fontSize: context.responsiveText(
                      context.responsive(22.0, 24.0, 28.0) * immersiveTextScale,
                    ),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.08,
                  ),
                ),
              if (immersiveShowTitle && immersiveShowArtist)
                SizedBox(height: context.responsive(10.0, 12.0, 14.0)),
              if (immersiveShowArtist)
                GestureDetector(
                  onTap: () => onNavigateToArtistDetail(song),
                  child: Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'HadooMono',
                      fontSize: context.responsiveText(
                        context.responsive(13.0, 14.0, 16.0) *
                            immersiveTextScale,
                      ),
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ),
              if (immersiveShowTitle || immersiveShowArtist)
                SizedBox(height: context.responsive(10.0, 12.0, 14.0)),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Artwork card
  // ---------------------------------------------------------------------------

  Widget _buildArtworkCardLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isShortHeight = constraints.maxHeight < 620;
        final isVeryShortHeight = constraints.maxHeight < 400;
        final horizontalPadding = constraints.maxWidth < 360
            ? 16.0
            : context.responsive(16.0, 20.0, 24.0);
        final topPadding = isVeryShortHeight
            ? 6.0
            : context.responsive(4.0, 5.0, 6.0);
        final maxArtworkSize = context.responsive(440.0, 500.0, 540.0);
        final baseArtworkSize = math
            .min(
              (constraints.maxWidth - (horizontalPadding * 2)) * 1.0,
              isVeryShortHeight
                  ? constraints.maxHeight * 0.38
                  : isShortHeight
                  ? constraints.maxHeight * 1.08
                  : constraints.maxHeight * 0.94,
            )
            .clamp(isVeryShortHeight ? 160.0 : 180.0, maxArtworkSize)
            .toDouble();
        final artworkSize = (baseArtworkSize * artworkCardArtworkScale)
            .clamp(isVeryShortHeight ? 140.0 : 160.0, constraints.maxWidth)
            .toDouble();
        final artworkSpacing = isVeryShortHeight
            ? 12.0
            : isShortHeight
            ? 12.0
            : context.responsive(8.0, 10.0, 12.0);
        final identitySpacing = isVeryShortHeight
            ? 8.0
            : isShortHeight
            ? 8.0
            : context.responsive(6.0, 8.0, 10.0);
        final lyricsSpacing = isVeryShortHeight
            ? 12.0
            : context.responsive(16.0, 18.0, 20.0);
        final playbackSpacing = isVeryShortHeight
            ? 10.0
            : context.responsive(14.0, 16.0, 18.0);
        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            0,
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: AnimatedSwitcher(
                        duration: AppConstants.animationNormal,
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInOutCubic,
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ...previousChildren,
                              ...?currentChild == null ? null : [currentChild],
                            ],
                          );
                        },
                        transitionBuilder: (child, animation) {
                          final isLyrics =
                              child.key == const ValueKey('artwork-lyrics');
                          final slide =
                              Tween<Offset>(
                                begin: isLyrics
                                    ? const Offset(0, -0.06)
                                    : const Offset(0, 0.06),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ),
                              );
                          return FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                            child: SlideTransition(
                              position: slide,
                              child: child,
                            ),
                          );
                        },
                        child: lyricsMode
                            ? Padding(
                                key: const ValueKey('artwork-lyrics'),
                                padding: EdgeInsets.only(bottom: lyricsSpacing),
                                child: InlineLyricsPanel(
                                  song: song,
                                  playerService: playerService,
                                  lyricsService: lyricsService,
                                  albumColor: albumColor,
                                  positionNotifier: positionNotifier,
                                  active: active,
                                ),
                              )
                            : KeyedSubtree(
                                key: const ValueKey('artwork-default'),
                                child: isVeryShortHeight
                                    ? Center(
                                        child: CompactPlayerInfoLayout(
                                          song: song,
                                          onNavigateToArtistDetail:
                                              onNavigateToArtistDetail,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                child: SizedBox(
                                                  width: artworkSize,
                                                  height: artworkSize,
                                                  child: Transform.translate(
                                                    offset: Offset(
                                                      0,
                                                      artworkCardArtworkOffset,
                                                    ),
                                                    child: ClipRRect(
                                                      // Keep the clip outside the
                                                      // image transform. Scaling the
                                                      // clip itself made the top edge
                                                      // escape the rounded viewport.
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            context.responsive(
                                                              20.0,
                                                              24.0,
                                                              28.0,
                                                            ),
                                                          ),
                                                      child: Transform.scale(
                                                        scaleX: 1.11,
                                                        scaleY: 1.18,
                                                        child: AlbumArtBox(
                                                          song: song,
                                                          size: artworkSize,
                                                          playerService:
                                                              playerService,
                                                          onRotationEnabledChanged:
                                                              onRotationEnabledChanged,
                                                          initialVinyl:
                                                              vinylMode,
                                                          onVinylChanged:
                                                              onVinylChanged,
                                                          showFrame:
                                                              artworkCardShowFrame,
                                                          motionArtEnabled:
                                                              motionArtEnabled,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: artworkSpacing),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top:
                                                  artworkCardVerticalOffset +
                                                  context.responsive(
                                                    6.0,
                                                    8.0,
                                                    10.0,
                                                  ) +
                                                  (isShortHeight ? 20.0 : 0.0),
                                              left: isVeryShortHeight
                                                  ? 8.0
                                                  : 0.0,
                                              right: isVeryShortHeight
                                                  ? 8.0
                                                  : 0.0,
                                            ),
                                            child: _buildSongIdentity(
                                              context,
                                              compact: isShortHeight,
                                              veryCompact: isVeryShortHeight,
                                            ),
                                          ),
                                          SizedBox(height: identitySpacing),
                                        ],
                                      ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              if (artworkCardShowFileInfo && fileInfoRowVisible)
                buildFileInfoRow(song, lyricsMode, playerScreenMode),
              if (showWaveform) ...[
                if (artworkCardShowFileInfo) SizedBox(height: playbackSpacing),
                _buildWaveformOnly(context),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSongIdentity(
    BuildContext context, {
    bool compact = false,
    bool veryCompact = false,
  }) {
    final titleSize =
        (veryCompact
            ? context.responsive(20.0, 22.0, 25.0)
            : compact
            ? context.responsive(22.0, 25.0, 28.0)
            : context.responsive(25.0, 27.0, 30.0)) *
        artworkCardTextScale;
    final titleToMetadataSpacing = veryCompact
        ? 6.0
        : context.responsive(8.0, 10.0, 12.0);
    final metadataSize = context.responsiveText(
      (veryCompact
              ? 11.0
              : compact
              ? 12.0
              : 12.0) *
          artworkCardTextScale,
    );
    final metadata = <Widget>[];
    void addMetadataWidget(Widget widget) {
      if (metadata.isNotEmpty) {
        metadata.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              '·',
              style: TextStyle(
                fontFamily: 'HadooMono',
                fontSize: metadataSize,
                color: Colors.white.withValues(alpha: .52),
              ),
            ),
          ),
        );
      }
      metadata.add(widget);
    }

    void addMetadata(String value, {VoidCallback? onTap}) {
      if (value.trim().isEmpty) return;
      final text = Text(
        value,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          fontFamily: 'HadooMono',
          fontSize: metadataSize,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: .76),
        ),
      );
      addMetadataWidget(
        onTap == null ? text : GestureDetector(onTap: onTap, child: text),
      );
    }

    if (artworkCardShowArtist) {
      final artists = splitArtistCredits(song.artist);
      addMetadataWidget(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < artists.length; index++) ...[
              if (index > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    ', ',
                    style: TextStyle(
                      fontFamily: 'HadooMono',
                      fontSize: metadataSize,
                      color: Colors.white.withValues(alpha: .76),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () =>
                    (onNavigateToArtistName ??
                    (song, _) =>
                        onNavigateToArtistDetail(song))(song, artists[index]),
                child: Text(
                  artists[index],
                  style: TextStyle(
                    fontFamily: 'HadooMono',
                    fontSize: metadataSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: .76),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }
    if (artworkCardShowAlbum && song.album?.trim().isNotEmpty == true) {
      addMetadata(song.album!, onTap: () => onNavigateToAlbumDetail(song));
    }
    if (song.year != null) addMetadata(song.year.toString());

    return Column(
      children: [
        if (artworkCardShowTitle)
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => onNavigateToAlbumDetail(song),
              child: MarqueeWidget(
                child: Text(
                  song.title,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'HadooMono',
                    fontSize: context.responsiveText(titleSize),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.08,
                  ),
                ),
              ),
            ),
          ),
        if (artworkCardShowTitle && metadata.isNotEmpty)
          SizedBox(height: titleToMetadataSpacing),
        if (metadata.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: MarqueeWidget(
              child: Row(mainAxisSize: MainAxisSize.min, children: metadata),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Waveform only (no controls)
  // ---------------------------------------------------------------------------

  Widget _buildWaveformOnly(BuildContext context) {
    final immersivePlaybackPadding =
        playerScreenMode == PlayerScreenMode.immersive
        ? context.responsive(18.0, 24.0, 30.0)
        : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: immersivePlaybackPadding),
      child: WaveformLayer(
        playerService: playerService,
        positionNotifier: positionNotifier,
        currentSong: song,
      ),
    );
  }
}
