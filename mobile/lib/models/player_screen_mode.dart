/// Full player layout modes persisted across app launches.
enum PlayerScreenMode { immersive, artworkCard }

extension PlayerScreenModeX on PlayerScreenMode {
  String get storageValue {
    switch (this) {
      case PlayerScreenMode.immersive:
        return 'immersive';
      case PlayerScreenMode.artworkCard:
        return 'artwork_card';
    }
  }

  static PlayerScreenMode fromStorageValue(String? value) {
    switch (value) {
      case 'artwork_card':
        return PlayerScreenMode.artworkCard;
      case 'immersive':
        return PlayerScreenMode.immersive;
      default:
        // The card layout is the stable, information-dense default on phones:
        // artwork, identity, seek bar, primary controls, and labeled actions
        // remain visible without requiring a gesture.
        return PlayerScreenMode.artworkCard;
    }
  }
}
