String motionName(Object? value) => (value ?? '')
    .toString()
    .toLowerCase()
    .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
    .trim()
    .replaceAll(RegExp(r'\s+'), ' ');
String motionTitle(String title) => title
    .replaceAll(
      RegExp(
        r'\s*[([][^)\]]*(?:official|lyric|audio|video|visuali[sz]er|hd|4k|mv)[^)\]]*[)\]]|\s*\|.*$',
        caseSensitive: false,
      ),
      '',
    )
    .trim();
List<String> motionArtists(String artist) => artist
    .split(
      RegExp(
        r'\s*(?:,|&|×|\bx\b|\bfeat\.?|\bft\.?|\bfeaturing\b|\bwith\b|;|/)\s*',
        caseSensitive: false,
      ),
    )
    .map(motionName)
    .where((s) => s.isNotEmpty)
    .toList();
bool motionArtistsMatch(String wanted, Object? got) {
  final have = (got is List ? got : [got])
      .expand((v) => motionArtists(v.toString()))
      .toSet();
  final want = motionArtists(wanted);
  return want.isNotEmpty &&
      want.every((v) => have.contains(v) || have.join(' ').contains(v));
}

String motionAlbum(String? album) =>
    RegExp(
      r'^\s*(?:unknown album|unknown|untitled)?\s*$',
      caseSensitive: false,
    ).hasMatch(album ?? '')
    ? ''
    : album!.trim();
