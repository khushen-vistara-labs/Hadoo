import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as image;
import 'package:flick/core/utils/dev_log.dart';

/// Decode compressed artwork and downsample in a worker isolate, not on
/// Flutter's UI/raster threads. ui.Image.toByteData() forces a GPU readback on
/// some Android Vulkan drivers; repeated calls can stall entire frames.
/// The caller receives only 32x32 RGBA, never a GPU texture.
Uint8List? _sampleArtworkRgba(Uint8List encoded) {
  final decoded = image.decodeImage(encoded);
  if (decoded == null) return null;
  final thumbnail = image.copyResize(
    decoded,
    width: 32,
    height: 32,
    interpolation: image.Interpolation.average,
  );
  return thumbnail.convert(format: image.Format.uint8)
      .getBytes(order: image.ChannelOrder.rgba);
}

/// Service to extract dominant colors from images for adaptive theming.
///
/// Uses palette extraction to determine the primary colors from album art,
/// enabling background-aware color adjustments throughout the app.
class ColorExtractionService {
  ColorExtractionService._();
  static final ColorExtractionService _instance = ColorExtractionService._();
  factory ColorExtractionService() => _instance;

  // Cache extracted colors to avoid recomputation
  final Map<String, Color> _colorCache = {};
  final Map<String, List<Color>> _paletteCache = {};
  // The shell and expanded player request the same art independently.
  // Share the sampled bytes, including in-flight work, to avoid double
  // JPEG/PNG decoding and costly CPU/GPU synchronization per track.
  final Map<String, Future<ByteData?>> _samples = {};

  Future<ByteData?> _sample(String path) {
    final existing = _samples[path];
    if (existing != null) return existing;
    // Missing or still-being-written artwork can become available later;
    // keep successful 32x32 samples, not permanent null-cache entries.
    final task = _readSample(path).then((sample) {
      if (sample == null) _samples.remove(path);
      return sample;
    });
    _samples[path] = task;
    while (_samples.length > 128) {
      _samples.remove(_samples.keys.first);
    }
    return task;
  }

  Future<ByteData?> _readSample(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      // Avoid a huge full-resolution allocation on 4 GB devices (M05).
      // Exceptionally large covers fall back to the theme accent.
      if (await file.length() > 24 * 1024 * 1024) return null;
      final decoded = await compute(_sampleArtworkRgba, await file.readAsBytes());
      if (decoded == null || decoded.lengthInBytes != 32 * 32 * 4) return null;
      return ByteData.sublistView(decoded);
    } catch (error) {
      devLog('ColorExtractionService: Palette sample failed: $error');
      return null;
    }
  }

  /// Extracts the dominant/average color from an image file.
  ///
  /// Returns null if extraction fails or file doesn't exist.
  Future<Color?> extractDominantColor(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    // Check cache first
    if (_colorCache.containsKey(imagePath)) {
      return _colorCache[imagePath];
    }

    try {
      final byteData = await _sample(imagePath);
      if (byteData == null) return null;
      final color = _calculateAverageColor(byteData, 32, 32);

      // Cache the result
      if (_colorCache.length >= 128) _colorCache.remove(_colorCache.keys.first);
      _colorCache[imagePath] = color;

      return color;
    } catch (e) {
      devLog('ColorExtractionService: Failed to extract color: $e');
      return null;
    }
  }

  /// Extracts a small, deterministic palette using k-means over a 32x32
  /// sample. Keeping several colors is important for album art with distinct
  /// regions (for example blue, violet, and red); a single average color
  /// produces the muddy player backgrounds we explicitly want to avoid.
  Future<List<Color>> extractPalette(
    String? imagePath, {
    int colorCount = 5,
  }) async {
    if (imagePath == null || imagePath.isEmpty) return const [];
    final cacheKey = '$imagePath#$colorCount';
    final cached = _paletteCache[cacheKey];
    if (cached != null) return cached;

    try {
      final byteData = await _sample(imagePath);
      if (byteData == null) return const [];

      final points = <List<double>>[];
      for (var i = 0; i + 3 < byteData.lengthInBytes; i += 4) {
        if (byteData.getUint8(i + 3) < 32) continue;
        points.add([
          byteData.getUint8(i).toDouble(),
          byteData.getUint8(i + 1).toDouble(),
          byteData.getUint8(i + 2).toDouble(),
        ]);
      }
      if (points.isEmpty) return const [];

      final k = math.min(colorCount.clamp(2, 8).toInt(), points.length);
      final centers = <List<double>>[
        List<double>.from(points[points.length ~/ 2]),
      ];
      while (centers.length < k) {
        var bestPoint = points.first;
        var bestDistance = -1.0;
        for (final point in points) {
          var nearest = double.infinity;
          for (final center in centers) {
            nearest = math.min(nearest, _colorDistance(point, center));
          }
          if (nearest > bestDistance) {
            bestDistance = nearest;
            bestPoint = point;
          }
        }
        centers.add(List<double>.from(bestPoint));
      }

      for (var iteration = 0; iteration < 8; iteration++) {
        final sums = List.generate(k, (_) => <double>[0, 0, 0]);
        final counts = List<int>.filled(k, 0);
        for (final point in points) {
          var nearestIndex = 0;
          var nearestDistance = double.infinity;
          for (var index = 0; index < centers.length; index++) {
            final distance = _colorDistance(point, centers[index]);
            if (distance < nearestDistance) {
              nearestDistance = distance;
              nearestIndex = index;
            }
          }
          final sum = sums[nearestIndex];
          sum[0] += point[0];
          sum[1] += point[1];
          sum[2] += point[2];
          counts[nearestIndex]++;
        }
        for (var index = 0; index < centers.length; index++) {
          if (counts[index] == 0) continue;
          centers[index] = [
            sums[index][0] / counts[index],
            sums[index][1] / counts[index],
            sums[index][2] / counts[index],
          ];
        }
      }

      final palette =
          centers
              .map(
                (color) => Color.fromARGB(
                  255,
                  color[0].round().clamp(0, 255),
                  color[1].round().clamp(0, 255),
                  color[2].round().clamp(0, 255),
                ),
              )
              .toList()
            ..sort((a, b) {
              final aHsl = HSLColor.fromColor(a);
              final bHsl = HSLColor.fromColor(b);
              return (bHsl.saturation * 0.75 + bHsl.lightness * 0.25).compareTo(
                aHsl.saturation * 0.75 + aHsl.lightness * 0.25,
              );
            });

      if (_paletteCache.length >= 128) {
        _paletteCache.remove(_paletteCache.keys.first);
      }
      _paletteCache[cacheKey] = palette;
      return palette;
    } catch (e) {
      devLog('ColorExtractionService: Failed to extract palette: $e');
      return const [];
    }
  }

  double _colorDistance(List<double> a, List<double> b) {
    final dr = a[0] - b[0];
    final dg = a[1] - b[1];
    final db = a[2] - b[2];
    return dr * dr + dg * dg + db * db;
  }

  /// Calculates the average color from pixel data, with brightness adjustment.
  Color _calculateAverageColor(ByteData byteData, int width, int height) {
    int totalR = 0, totalG = 0, totalB = 0;
    int pixelCount = width * height;

    for (int i = 0; i < byteData.lengthInBytes; i += 4) {
      final r = byteData.getUint8(i);
      final g = byteData.getUint8(i + 1);
      final b = byteData.getUint8(i + 2);
      // Skip alpha (i + 3)

      totalR += r;
      totalG += g;
      totalB += b;
    }

    final avgR = totalR ~/ pixelCount;
    final avgG = totalG ~/ pixelCount;
    final avgB = totalB ~/ pixelCount;

    return Color.fromARGB(255, avgR, avgG, avgB);
  }

  /// Extracts the dominant color and returns it blended with the app's
  /// base background color for a more cohesive look.
  Future<Color> extractBlendedBackgroundColor(
    String? imagePath, {
    Color baseColor = const Color(0xFF0A0A0A),
    double blendFactor = 0.4,
  }) async {
    final dominantColor = await extractDominantColor(imagePath);

    if (dominantColor == null) {
      return baseColor;
    }

    // Blend the dominant color with the base color
    return Color.lerp(baseColor, dominantColor, blendFactor)!;
  }

  /// Clears the color cache. Useful when album art changes.
  void clearCache() {
    _colorCache.clear();
    _paletteCache.clear();
    _samples.clear();
  }

  /// Removes a specific entry from the cache.
  void invalidateCache(String imagePath) {
    _colorCache.remove(imagePath);
    _paletteCache.removeWhere((key, _) => key.startsWith('$imagePath#'));
    _samples.remove(imagePath);
  }
}
