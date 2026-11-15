import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flick/core/theme/app_colors.dart';
import 'package:flick/core/constants/app_constants.dart';
import 'package:flick/models/song.dart';
import 'package:flick/services/album_art_service.dart';
import 'package:flick/core/utils/dev_log.dart';

// ---------------------------------------------------------------------------
// AmbientBackground
//
// Strategy: decode + blur the album art **once** per song change using
// dart:ui APIs on the main isolate (async — does not block the UI thread).
// The result is cached as a plain [ui.Image] and displayed with [RawImage].
//
// This eliminates the per-frame GPU cost of BackdropFilter (sigma=25).
// dart:ui APIs MUST run on the main isolate — they cannot be passed to
// compute() because they require Flutter engine bindings.
//
// A module-level cache avoids re-computation when multiple widgets share
// the same album art (e.g. MainShell + Settings sub-pages). The old image
// is kept visible while the new one decodes so the background never flashes
// black during navigation.
// ---------------------------------------------------------------------------

/// Shared cache so parallel [AmbientBackground] instances don't recompute.
final Map<String, ui.Image> _blurCache = {};

/// Maps a song's input key (albumArt path, or filePath when art is embedded)
/// to the resolved art path that was actually blurred. Lets newly pushed
/// screens seed their first frame synchronously instead of flashing empty
/// while the async resolution runs.
final Map<String, String> _resolvedPathIndex = {};

/// Marks a subtree as already sitting on a shared [AmbientBackground]
/// (the bottom-bar shell). Any [AmbientBackground] under this scope
/// renders nothing, so tab screens don't stack a second instance.
class AmbientBackgroundScope extends InheritedWidget {
  const AmbientBackgroundScope({super.key, required super.child});

  static bool isPresent(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AmbientBackgroundScope>() !=
      null;

  @override
  bool updateShouldNotify(AmbientBackgroundScope oldWidget) => false;
}

class AmbientBackground extends StatefulWidget {
  final Song? song;

  const AmbientBackground({super.key, this.song});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground> {
  /// Blur sigma. Lower sigma on the already-downscaled image (~300px wide)
  /// produces the same perceived softness as sigma=25 on a full-res image.
  static const double _blurSigma = 12.0;

  /// Max dimension to decode the source image into (saves memory + decode time).
  static const int _targetDimension = 300;

  ui.Image? _blurredImage;
  String? _currentPath; // resolved path of the image currently shown
  String? _loadingPath; // path we're currently computing for
  int _generation = 0;
  final _retired = <ui.Image>{};

  void _showImage(ui.Image? cached) {
    final previous = _blurredImage;
    _blurredImage = cached?.clone();
    if (previous != null) {
      _retired.add(previous);
      Timer(AppConstants.animationSlow + const Duration(milliseconds: 100), () {
        if (_retired.remove(previous)) previous.dispose();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _syncInitFromCache();
    _updateBlur(widget.song?.albumArt, widget.song?.filePath);
  }

  @override
  void didUpdateWidget(AmbientBackground old) {
    super.didUpdateWidget(old);
    final newPath = widget.song?.albumArt;
    final newSourcePath = widget.song?.filePath;
    if (newPath != old.song?.albumArt || newSourcePath != old.song?.filePath) {
      _syncInitFromCache();
      _updateBlur(newPath, newSourcePath);
    }
  }

  /// Key used to remember how this song's art was resolved.
  String? get _inputKey {
    final art = widget.song?.albumArt;
    if (art != null && art.isNotEmpty) return art;
    return widget.song?.filePath;
  }

  /// Seeded synchronously so [build] never starts with a null image
  /// when the artwork is already cached.
  void _syncInitFromCache() {
    final key = _inputKey;
    if (key == null) return;
    final resolved = _resolvedPathIndex[key] ?? key;
    final image = _blurCache[resolved];
    if (image != null) {
      _showImage(image);
      _currentPath = resolved;
    }
  }

  @override
  void dispose() {
    ++_generation;
    _blurredImage?.dispose();
    for (final image in _retired) {
      image.dispose();
    }
    _retired.clear();
    _blurredImage = null;
    super.dispose();
  }

  Future<void> _updateBlur(String? path, String? audioSourcePath) async {
    final generation = ++_generation;
    final resolvedPath = await _resolveArtworkPath(path, audioSourcePath);
    if (!mounted || generation != _generation) return;
    if (resolvedPath == null) {
      if (mounted) {
        setState(() {
          _showImage(null);
          _currentPath = null;
          _loadingPath = null;
        });
      }
      return;
    }

    final input = _inputKey;
    if (input != null) {
      if (_resolvedPathIndex.length >= 256) {
        _resolvedPathIndex.remove(_resolvedPathIndex.keys.first);
      }
      _resolvedPathIndex[input] = resolvedPath;
    }

    // If another widget already blurred this path, reuse it instantly.
    if (_blurCache.containsKey(resolvedPath)) {
      if (mounted) {
        setState(() {
          _showImage(_blurCache[resolvedPath]);
          _currentPath = resolvedPath;
        });
      }
      return;
    }

    _loadingPath = resolvedPath;

    try {
      // 1. Read raw bytes from disk (async IO — does not block UI thread)
      final file = File(resolvedPath);
      if (!await file.exists()) {
        return;
      }
      final bytes = await file.readAsBytes();

      // Bail if widget disposed or song changed while we were reading
      if (!mounted ||
          generation != _generation ||
          resolvedPath != _loadingPath) {
        return;
      }

      // 2. Decode at reduced resolution (codec handles downscale on raster thread)
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: _targetDimension,
        targetHeight: _targetDimension,
      );
      final frame = await codec.getNextFrame();
      codec.dispose();
      final srcImage = frame.image;

      if (!mounted ||
          generation != _generation ||
          resolvedPath != _loadingPath) {
        srcImage.dispose();
        return;
      }

      // 3. Draw with blur ImageFilter into a Picture, then rasterise.
      //    picture.toImage() runs on Flutter's raster thread — non-blocking.
      // Capture dimensions before disposal.
      final int imgW = srcImage.width;
      final int imgH = srcImage.height;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawImage(
        srcImage,
        Offset.zero,
        Paint()
          ..imageFilter = ui.ImageFilter.blur(
            sigmaX: _blurSigma,
            sigmaY: _blurSigma,
            tileMode: TileMode.clamp,
          ),
      );
      final picture = recorder.endRecording();
      srcImage.dispose();

      final blurred = await picture.toImage(imgW, imgH);
      picture.dispose();

      if (!mounted ||
          generation != _generation ||
          resolvedPath != _loadingPath) {
        blurred.dispose();
        return;
      }

      // Widgets own cloned handles, so cache eviction cannot invalidate a
      // visible image or its outgoing cross-fade.
      _blurCache.remove(resolvedPath)?.dispose();
      while (_blurCache.length >= 12) {
        _blurCache.remove(_blurCache.keys.first)?.dispose();
      }
      _blurCache[resolvedPath] = blurred;
      setState(() {
        _showImage(blurred);
        _currentPath = resolvedPath;
      });
    } catch (e) {
      devLog('[AmbientBackground] blur failed: $e');
    }
  }

  Future<String?> _resolveArtworkPath(
    String? path,
    String? audioSourcePath,
  ) async {
    if (path != null && path.isNotEmpty && await File(path).exists()) {
      return path;
    }

    if (audioSourcePath == null || audioSourcePath.isEmpty) {
      return null;
    }

    return AlbumArtService.instance.resolveArtworkPath(
      existingPath: path,
      audioSourcePath: audioSourcePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Shared shell background already exists below this subtree.
    if (AmbientBackgroundScope.isPresent(context)) {
      return const SizedBox.shrink();
    }
    if (widget.song?.albumArt == null && widget.song?.filePath == null) {
      return const SizedBox.shrink();
    }

    final image = _blurredImage;
    // No cross-fade from empty: a fresh screen shows the image instantly.
    if (image == null) {
      return const SizedBox.expand();
    }

    return RepaintBoundary(
      child: AnimatedSwitcher(
        duration: AppConstants.animationSlow,
        child: SizedBox.expand(
          key: ValueKey(_currentPath),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Pre-blurred raster — zero GPU filter cost per frame
              RawImage(
                image: image,
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.6),
              ),
              // Scrim in the theme's background colour for readability: a
              // dark veil on dark themes, a light wash on light ones.
              ColoredBox(
                color: AppColors.background.withValues(
                  alpha: AppColors.isLight ? 0.62 : 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
