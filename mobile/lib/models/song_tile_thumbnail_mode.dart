enum SongTileThumbnailMode { artwork, trackNumber, trackNumberOnArt }

extension SongTileThumbnailModeX on SongTileThumbnailMode {
  String get storageValue {
    switch (this) {
      case SongTileThumbnailMode.artwork:
        return 'artwork';
      case SongTileThumbnailMode.trackNumber:
        return 'trackNumber';
      case SongTileThumbnailMode.trackNumberOnArt:
        return 'trackNumberOnArt';
    }
  }

  static SongTileThumbnailMode fromStorageValue(String? value) {
    switch (value) {
      case 'trackNumber':
        return SongTileThumbnailMode.trackNumber;
      case 'trackNumberOnArt':
        return SongTileThumbnailMode.trackNumberOnArt;
      case 'artwork':
      default:
        return SongTileThumbnailMode.artwork;
    }
  }
}
