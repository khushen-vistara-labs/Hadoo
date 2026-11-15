import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';

enum PlayerActionButton {
  none,
  lyrics,
  favorites,
  ratings,
  queue,
  sleepTimer,
  share,
  usbVolume,
  equalizer,
  volume,
  cast,
}

extension PlayerActionButtonX on PlayerActionButton {
  String get storageValue {
    switch (this) {
      case PlayerActionButton.none:
        return 'none';
      case PlayerActionButton.lyrics:
        return 'lyrics';
      case PlayerActionButton.favorites:
        return 'favorites';
      case PlayerActionButton.ratings:
        return 'ratings';
      case PlayerActionButton.queue:
        return 'queue';
      case PlayerActionButton.sleepTimer:
        return 'sleep_timer';
      case PlayerActionButton.share:
        return 'share';
      case PlayerActionButton.usbVolume:
        return 'usb_volume';
      case PlayerActionButton.equalizer:
        return 'equalizer';
      case PlayerActionButton.volume:
        return 'volume';
      case PlayerActionButton.cast:
        return 'cast';
    }
  }

  IconData get icon {
    switch (this) {
      case PlayerActionButton.none:
        return Icons.block_rounded;
      case PlayerActionButton.lyrics:
        return LucideIcons.fileText;
      case PlayerActionButton.favorites:
        return Icons.favorite_border;
      case PlayerActionButton.ratings:
        return LucideIcons.star;
      case PlayerActionButton.queue:
        return LucideIcons.listMusic;
      case PlayerActionButton.sleepTimer:
        return LucideIcons.moonStar;
      case PlayerActionButton.share:
        return LucideIcons.share2;
      case PlayerActionButton.usbVolume:
        return LucideIcons.volume2;
      case PlayerActionButton.equalizer:
        return LucideIcons.slidersHorizontal;
      case PlayerActionButton.volume:
        return LucideIcons.volume;
      case PlayerActionButton.cast:
        return LucideIcons.cast;
    }
  }

  static PlayerActionButton fromStorageValue(String? value) {
    switch (value) {
      case 'none':
        return PlayerActionButton.none;
      case 'favorites':
        return PlayerActionButton.favorites;
      case 'visualizer':
        return PlayerActionButton.none;
      case 'ratings':
        return PlayerActionButton.ratings;
      case 'queue':
        return PlayerActionButton.queue;
      case 'sleep_timer':
        return PlayerActionButton.sleepTimer;
      case 'share':
        return PlayerActionButton.share;
      case 'usb_volume':
        return PlayerActionButton.usbVolume;
      case 'equalizer':
        return PlayerActionButton.equalizer;
      case 'volume':
        return PlayerActionButton.volume;
      case 'cast':
        return PlayerActionButton.cast;
      case 'lyrics':
      default:
        return PlayerActionButton.lyrics;
    }
  }
}
