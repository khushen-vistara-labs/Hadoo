enum AlbumColorMode { off, subtle, moderate, vibrant }

extension AlbumColorModeX on AlbumColorMode {
  String get storageValue {
    switch (this) {
      case AlbumColorMode.off:
        return 'off';
      case AlbumColorMode.subtle:
        return 'subtle';
      case AlbumColorMode.moderate:
        return 'moderate';
      case AlbumColorMode.vibrant:
        return 'vibrant';
    }
  }

  /// Blend factor with Color(0xFF121212) for button/container surfaces.
  double get surfaceBlend {
    switch (this) {
      case AlbumColorMode.off:
        return 0.0;
      case AlbumColorMode.subtle:
        return 0.10;
      case AlbumColorMode.moderate:
        return 0.20;
      case AlbumColorMode.vibrant:
        return 0.35;
    }
  }

  /// Blend factor for accent/active states (slightly more saturated).
  double get accentBlend {
    switch (this) {
      case AlbumColorMode.off:
        return 0.0;
      case AlbumColorMode.subtle:
        return 0.18;
      case AlbumColorMode.moderate:
        return 0.32;
      case AlbumColorMode.vibrant:
        return 0.50;
    }
  }

  /// Blend factor for background gradient overlays.
  double get backgroundBlend {
    switch (this) {
      case AlbumColorMode.off:
        return 0.0;
      case AlbumColorMode.subtle:
        return 0.08;
      case AlbumColorMode.moderate:
        return 0.15;
      case AlbumColorMode.vibrant:
        return 0.25;
    }
  }

  static AlbumColorMode fromStorageValue(String? value) {
    switch (value) {
      case 'subtle':
        return AlbumColorMode.subtle;
      case 'moderate':
        return AlbumColorMode.moderate;
      case 'vibrant':
        return AlbumColorMode.vibrant;
      case 'off':
      default:
        return AlbumColorMode.off;
    }
  }
}
