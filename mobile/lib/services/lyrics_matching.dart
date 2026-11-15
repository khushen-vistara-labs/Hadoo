/// Desktop Lokal's catalogue name cleanup, preserving live/remix versions.
String lyricsSearchTitle(String title) {
  var value = title;
  for (final pattern in [
    r'\s*[(\[](?:feat\.?|ft\.?|featuring|with)\s[^)\]]*[)\]]',
    r'\s*[(\[][^)\]]*(?:official|video|audio|lyrics?|visuali[sz]er|music video|mv|hd|hq|4k)[^)\]]*[)\]]',
    r'\s*[(\[][^)\]]*(?:remaster(?:ed)?|re-?recorded|explicit|clean|radio edit|single version|album version|mono|stereo)[^)\]]*[)\]]',
    r'\s+-\s+(?:\d{4}\s+)?remaster(?:ed)?(?:\s+\d{4})?(?:\s+version)?$',
    r'\s+-\s+(?:single|radio edit|album version|explicit|clean)$',
    r'\s+(?:feat\.?|ft\.?)\s.*$',
  ]) {
    value = value.replaceAll(RegExp(pattern, caseSensitive: false), '');
  }
  final clean = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  return clean.isEmpty ? title.trim() : clean;
}

String lyricsSearchArtist(String artist) {
  // Keep commas/ampersands: these are also legitimate band names (AC/DC,
  // Earth, Wind & Fire). Strip explicit featured-artist credit only.
  return artist
      .split(RegExp(r'\s+(?:feat\.?|ft\.?|featuring)\s+', caseSensitive: false))
      .first
      .trim();
}

String lyricsMatchName(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
    .trim();
