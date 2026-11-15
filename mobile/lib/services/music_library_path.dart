/// One safe Artist/Album hierarchy for permanent music saves. Each returned
/// component is a filename segment, never an absolute or traversable path.
class MusicLibraryPath {
  static String segment(String? value, String fallback) {
    var clean = (value ?? '')
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f\x7f]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .replaceAll(RegExp(r'^[. ]+|[. ]+$'), '');
    if (clean.isEmpty) clean = fallback;
    clean = String.fromCharCodes(clean.runes.take(100)).trim();
    if (RegExp(
      r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\.|$)',
      caseSensitive: false,
    ).hasMatch(clean)) {
      clean = '_$clean';
    }
    return clean;
  }

  static List<String> directories({
    required String artist,
    String? album,
    String? albumArtist,
  }) => [
    segment(
      albumArtist?.trim().isNotEmpty == true ? albumArtist : artist,
      'Unknown Artist',
    ),
    segment(album, 'Unknown Album'),
  ];
}
