import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flick/services/lyrics_service.dart';

/// Desktop Lokal's "line under each lyric" (`src/lyrics/useLyricSubline.js`):
/// the original alone, or with its translation when the lyrics carry one.
/// One choice for every song, remembered.
class LokalLyricsSubline {
  LokalLyricsSubline._();

  static const prefsKey = 'lokal_lyrics_subline';

  /// Whether translations show under their lines.
  static final ValueNotifier<bool> showTranslation = ValueNotifier(false);

  static bool _loaded = false;

  /// Reads the remembered choice once.
  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    showTranslation.value = prefs.getString(prefsKey) == 'translation';
  }

  static Future<void> toggle() async {
    showTranslation.value = !showTranslation.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      prefsKey,
      showTranslation.value ? 'translation' : 'original',
    );
  }

  /// Whether [lyrics] have any translation to show.
  static bool hasTranslation(LyricsData? lyrics) =>
      lyrics?.lines.any((line) => line.translation?.isNotEmpty ?? false) ??
      false;

  @visibleForTesting
  static void reset() {
    _loaded = false;
    showTranslation.value = false;
  }
}
