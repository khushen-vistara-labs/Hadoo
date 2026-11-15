/// Matching Discovery's picks to real recordings, ported from desktop Lokal
/// (`src/recommendations.js`): the same keys, title clean-up and the rule
/// that a match needs both the title and the artist, so a cover, remix or
/// another artist's song never stands in for the one recommended.
library;

/// Precomposed Latin letters and the letter under the accent. Dart has no
/// Unicode normalisation, so this stands in for desktop's NFKD, which drops
/// the marks from Latin letters only ("Beyoncé" is "beyonce", "流線" stays).
const _foldFrom =
    'ÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïñòóôõöùúûüýÿĀāĂăĄąĆ'
    'ćĈĉĊċČčĎďĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĨĩĪīĬĭĮįİĴĵĶķĹĺĻļĽľŃńŅņŇňŌōŎŏŐő'
    'ŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžƠơƯưǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛ'
    'ǜǞǟǠǡǦǧǨǩǪǫǬǭǰǴǵǸǹǺǻȀȁȂȃȄȅȆȇȈȉȊȋȌȍȎȏȐȑȒȓȔȕȖȗȘșȚțȞȟȦȧȨȩȪȫȬȭȮȯ'
    'ȰȱȲȳḀḁḂḃḄḅḆḇḈḉḊḋḌḍḎḏḐḑḒḓḔḕḖḗḘḙḚḛḜḝḞḟḠḡḢḣḤḥḦḧḨḩḪḫḬḭḮḯḰḱḲḳḴḵḶḷ'
    'ḸḹḺḻḼḽḾḿṀṁṂṃṄṅṆṇṈṉṊṋṌṍṎṏṐṑṒṓṔṕṖṗṘṙṚṛṜṝṞṟṠṡṢṣṤṥṦṧṨṩṪṫṬṭṮṯṰṱṲṳ'
    'ṴṵṶṷṸṹṺṻṼṽṾṿẀẁẂẃẄẅẆẇẈẉẊẋẌẍẎẏẐẑẒẓẔẕẖẗẘẙẛẠạẢảẤấẦầẨẩẪẫẬậẮắẰằẲẳẴ'
    'ẵẶặẸẹẺẻẼẽẾếỀềỂểỄễỆệỈỉỊịỌọỎỏỐốỒồỔổỖỗỘộỚớỜờỞởỠỡỢợỤụỦủỨứỪừỬửỮữỰ'
    'ựỲỳỴỵỶỷỸỹ';
const _foldTo =
    'AAAAAACEEEEIIIINOOOOOUUUUYaaaaaaceeeeiiiinooooouuuuyyAaAaAaC'
    'cCcCcCcDdEeEeEeEeEeGgGgGgGgHhIiIiIiIiIJjKkLlLlLlNnNnNnOoOoOo'
    'RrRrRrSsSsSsSsTtTtUuUuUuUuUuUuWwYyYZzZzZzOoUuAaIiOoUuUuUuUuU'
    'uAaAaGgKkOoOojGgNnAaAaAaEeEeIiIiOoOoRrRrUuUuSsTtHhAaEeOoOoOo'
    'OoYyAaBbBbBbCcDdDdDdDdDdEeEeEeEeEeFfGgHhHhHhHhHhIiIiKkKkKkLl'
    'LlLlLlMmMmMmNnNnNnNnOoOoOoOoPpPpRrRrRrRrSsSsSsSsSsTtTtTtTtUu'
    'UuUuUuUuVvVvWwWwWwWwWwXxXxYyZzZzZzhtwysAaAaAaAaAaAaAaAaAaAaA'
    'aAaEeEeEeEeEeEeEeEeIiIiOoOoOoOoOoOoOoOoOoOoOoOoUuUuUuUuUuUuU'
    'uYyYyYyYy';

final Map<int, int> _fold = {
  for (var i = 0; i < _foldFrom.length; i++)
    _foldFrom.codeUnitAt(i): _foldTo.codeUnitAt(i),
};

final _latin = RegExp(r'\p{Script=Latin}', unicode: true);
final _mark = RegExp(r'\p{M}', unicode: true);
final _letter = RegExp(r'\p{L}', unicode: true);
final _notWord = RegExp(r'[^\p{L}\p{M}\p{N}]+', unicode: true);

/// Latin accents dropped, and full-width forms ("ＡＢＣ") read as ASCII.
String foldLatin(String value) {
  final out = StringBuffer();
  var afterLatin = false;
  for (final rune in value.runes) {
    var code = _fold[rune] ?? rune;
    if (code >= 0xff01 && code <= 0xff5e) code -= 0xfee0;
    if (code == 0x3000) code = 0x20;
    final char = String.fromCharCode(code);
    if (afterLatin && _mark.hasMatch(char)) continue;
    afterLatin = _latin.hasMatch(char);
    out.write(char);
  }
  return out.toString();
}

/// Desktop's `recommendationKey`: lower case, Latin accents dropped, anything
/// that isn't a letter or digit a single space.
String recommendationKey(String? value) =>
    foldLatin(value ?? '').toLowerCase().replaceAll(_notWord, ' ').trim();

/// Desktop's `songKey`: one key per artist and title.
String recommendationSongKey(String? artist, String? title) =>
    '${recommendationKey(artist)}\u0000${recommendationKey(title)}';

String _stripFeatured(Match match) {
  final suffix = match[0]!;
  return RegExp(r'\b(?:remix|live|cover)\b').hasMatch(recommendationKey(suffix))
      ? suffix
      : '';
}

// The same recording under another label: "(2011 Remaster)", "- Remastered
// 2003", "- Original Mix", "(Mono)". Live, remix, edit... stay different songs.
const _sameRecording =
    r'(?:(?:\d{4}\s+)?(?:digital(?:ly)?\s+)?remaster(?:ed)?(?:\s+\d{4})?(?:\s+version)?|(?:album|single|mono|stereo|lp)\s+version|original\s+mix|mono|stereo)';
final _sameRecordingBracket = RegExp(
  '\\s*[(\\[]$_sameRecording[)\\]]',
  caseSensitive: false,
);
final _sameRecordingSuffix = RegExp(
  '\\s+[-–—]\\s+$_sameRecording\\s*\$',
  caseSensitive: false,
);
// "[Explicit]", "(Clean Version)": labels of the same recording.
final _contentLabel = RegExp(
  r'\s*[(\[](?:explicit|clean)(?:\s+version)?[)\]]',
  caseSensitive: false,
);
// A credit in brackets or after the name: "[feat. Joi]", "(ft. X)", " feat. Y".
final _featBracket = RegExp(
  r'\s*[(\[](?:feat\.?|ft\.?|featuring|with)\s+[^)\]]*[)\]]',
  caseSensitive: false,
);
final _featSuffix = RegExp(
  r'\s+(?:feat\.?|ft\.?|featuring)\s+.+$',
  caseSensitive: false,
);
final _videoLabel = RegExp(
  r'\s*[(\[](?:official (?:music video|audio|video)|lyrics?|audio|hq|hd|album version|single version)[)\]]',
  caseSensitive: false,
);
final _featBracketStrict = RegExp(
  r'\s*[(\[](?:feat\.?|ft\.?|featuring|with)\s+[^)\]]+[)\]]',
  caseSensitive: false,
);

/// An artist without the guests credited with them: "Estelle [feat. Joi]"
/// is "Estelle".
String mainArtist(String? artist) => (artist ?? '')
    .replaceAll(_featBracket, '')
    .replaceAll(_featSuffix, '')
    .trim();

// Imports flatten semicolon-separated credits into commas. Keep known
// comma-containing artist names intact, including when followed by guests.
const _commaArtists = [
  'Tyler, The Creator',
  'Earth, Wind & Fire',
  'Crosby, Stills, Nash & Young',
  'Crosby, Stills & Nash',
  'Emerson, Lake & Palmer',
];

/// The first credited artist.
String leadArtist(String? artist) {
  final name = mainArtist(artist);
  if (name.contains(';')) return name.split(';').first.trim();
  final lower = name.toLowerCase();
  for (final kept in _commaArtists) {
    final k = kept.toLowerCase();
    if (lower == k || lower.startsWith('$k,')) {
      return name.substring(0, kept.length);
    }
  }
  return name.split(',').first.trim();
}

/// A title to search with: without guests, "[Explicit]" and remaster labels.
/// A remix or live version keeps its label.
String searchTitle(String? title) {
  final raw = title ?? '';
  final clean = raw
      .replaceAll(_contentLabel, '')
      .replaceAll(_sameRecordingBracket, '')
      .replaceAll(_sameRecordingSuffix, '')
      .replaceAllMapped(_featBracket, _stripFeatured)
      .replaceAllMapped(_featSuffix, _stripFeatured)
      .replaceAll(RegExp(r'\s{2,}'), ' ')
      .trim();
  return clean.isEmpty ? raw.trim() : clean;
}

/// The key two titles of the same recording share.
String titleKey(String? title) => recommendationKey(
  (title ?? '')
      .replaceAll(_contentLabel, '')
      .replaceAll(_sameRecordingBracket, '')
      .replaceAll(_sameRecordingSuffix, '')
      .replaceAll(_videoLabel, '')
      .replaceAllMapped(_featBracketStrict, _stripFeatured)
      .replaceAllMapped(_featSuffix, _stripFeatured),
);

/// A catalogue sometimes credits a principal artist together with a guest,
/// e.g. "Big Data & Joywave" for a locally tagged "Big Data" recording.
/// Only consider the *leading* credited artist, and never split known
/// comma-containing band names or a single-word band such as "Simon &
/// Garfunkel" into an unrelated artist.
String _artworkCollaborationLead(String artist) {
  final name = mainArtist(artist);
  if (name.contains(',')) return '';
  final artists = name.split(
    RegExp(r'\s+(?:&|and|with|x)\s+', caseSensitive: false),
  );
  if (artists.length < 2 || artists.any((value) => value.trim().isEmpty)) {
    return '';
  }
  final first = recommendationKey(artists.first);
  // A full leading stage name is stronger evidence than a single common
  // name, which might be part of a band rather than a standalone credit.
  return first.split(' ').length >= 2 ? first : '';
}

/// Exact artist credits remain the default. Discord may additionally accept
/// a separately listed *guest* artist after the exact leading artist.
bool artworkArtistsMatch(
  String artist,
  String candidateArtist, {
  bool allowCollaborations = false,
}) {
  final expected = {
    recommendationKey(mainArtist(artist)),
    recommendationKey(leadArtist(artist)),
  }..remove('');
  final found = {
    recommendationKey(mainArtist(candidateArtist)),
    recommendationKey(leadArtist(candidateArtist)),
  }..remove('');
  if (expected.isEmpty || found.isEmpty) return false;
  if (expected.intersection(found).isNotEmpty) return true;
  return allowCollaborations &&
      expected.contains(_artworkCollaborationLead(candidateArtist));
}

/// Minimum accepted score for a fuzzy *artwork* match. This is never used to
/// decide which recording to play: a wrong cover should be omitted, not guessed.
const double artworkConfidenceThreshold = 0.84;

/// How likely a remotely found cover belongs to a locally tagged track.
/// The artist must match (including known featured-credit variants), and
/// recording-altering versions such as remixes/edits/live recordings must agree.
/// Only then do title spelling and word overlap produce a confidence score.
double artworkMatchConfidence({
  required String title,
  required String artist,
  required String candidateTitle,
  required String candidateArtist,
  bool allowCollaborations = false,
}) {
  if (!artworkArtistsMatch(
    artist,
    candidateArtist,
    allowCollaborations: allowCollaborations,
  )) {
    return 0;
  }
  final wanted = titleKey(title);
  final found = titleKey(candidateTitle);
  if (wanted.isEmpty || found.isEmpty) return 0;
  if (wanted == found) return 1;

  // A very similar title must never let a remix, live recording or edit
  // borrow the original recording's cover (or vice versa).
  Set<String> versions(String value) =>
      _versionWords.allMatches(value).map((m) => m.group(0)!.toLowerCase()).toSet();
  final wantedVersions = versions(wanted);
  final foundVersions = versions(found);
  if (wantedVersions.length != foundVersions.length ||
      !wantedVersions.containsAll(foundVersions)) {
    return 0;
  }

  const stopWords = {'a', 'an', 'and', 'at', 'by', 'for', 'in', 'of', 'on', 'the', 'to', 'with'};
  Set<String> important(String value) => value
      .split(' ')
      .where((word) => word.length >= 3 && !stopWords.contains(word))
      .toSet();
  final importantOverlap = important(wanted).intersection(important(found));
  if (importantOverlap.length < 2) return 0;

  final leftTokens = wanted.split(' ').toSet();
  final rightTokens = found.split(' ').toSet();
  final tokenOverlap = leftTokens.intersection(rightTokens).length /
      (leftTokens.length > rightTokens.length ? leftTokens.length : rightTokens.length);

  // Normalized Levenshtein similarity gives small substitutions a fair score.
  final a = wanted.runes.toList();
  final b = found.runes.toList();
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final next = List<int>.filled(b.length + 1, 0);
    next[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final substitution = a[i - 1] == b[j - 1] ? 0 : 1;
      final remove = previous[j] + 1;
      final insert = next[j - 1] + 1;
      final replace = previous[j - 1] + substitution;
      next[j] = [remove, insert, replace].reduce((x, y) => x < y ? x : y);
    }
    previous = next;
  }
  final maxLength = a.length > b.length ? a.length : b.length;
  final characterScore = 1 - previous[b.length] / maxLength;
  return 0.8 * characterScore + 0.2 * tokenOverlap;
}

final _versionWords = RegExp(
  r'\b(?:remix|live|cover|instrumental|acoustic|karaoke|edit|sped up|slowed|nightcore)\b',
  caseSensitive: false,
);

bool _nonLatinLetters(String value) => value.runes.any((rune) {
  final char = String.fromCharCode(rune);
  return _letter.hasMatch(char) && !_latin.hasMatch(char);
});

/// A title and its explicit bilingual aliases, e.g. "流線 - ryusen".
List<String> recommendationTitles(String? title) {
  final original = (title ?? '').trim();
  final parts = original
      .split(RegExp(r'\s+[-–—|/]\s+'))
      .map((part) => part.trim())
      .toList();
  if (parts.length != 2 ||
      _versionWords.hasMatch(original) ||
      _nonLatinLetters(parts[0]) == _nonLatinLetters(parts[1]) ||
      !parts.any((part) => !_nonLatinLetters(part) && _latin.hasMatch(part))) {
    return [original];
  }
  return [
    original,
    ...parts.where((part) => !_nonLatinLetters(part)),
    ...parts.where(_nonLatinLetters),
  ];
}

/// A song to find, or a search result to check.
class RecommendationCandidate {
  const RecommendationCandidate({
    required this.title,
    required this.artist,
    this.album,
    this.duration,
    this.youtube = false,
  });

  final String title;
  final String artist;
  final String? album;
  final Duration? duration;

  /// A YouTube upload, whose title may carry the artist ("Artist - Song").
  final bool youtube;
}

/// Up to six searches for [candidate]: clean names first, then as given.
List<String> recommendationQueries(RecommendationCandidate candidate) {
  final artist = candidate.artist.trim();
  final names = <String>{
    for (final name in [leadArtist(artist), mainArtist(artist), artist])
      if (name.isNotEmpty) name,
  };
  final titles = <String>{
    ...recommendationTitles(searchTitle(candidate.title)),
    ...recommendationTitles(candidate.title),
  };
  return <String>{
    for (final title in titles)
      for (final name in names) '$name $title'.trim(),
  }.take(6).toList();
}

bool _matchingDuration(Duration? expected, Duration? actual) =>
    expected == null ||
    actual == null ||
    expected <= Duration.zero ||
    actual <= Duration.zero ||
    (expected - actual).abs() <= const Duration(seconds: 10);

/// The first of [results] that is [candidate]'s song: the same title (or an
/// alias) by the same artist, within ten seconds when both lengths are
/// known. A match from the same album comes first.
T? recommendationMatch<T>(
  RecommendationCandidate candidate,
  Iterable<T> results,
  RecommendationCandidate Function(T result) describe,
) {
  final titles = recommendationTitles(candidate.title).map(titleKey).toList();
  final artist = recommendationKey(candidate.artist);
  if (titles.first.isEmpty || artist.isEmpty) return null;
  String clean(String key) => key.replaceFirst(RegExp(r' topic$'), '');
  final artistKeys = <String>{
    artist,
    clean(recommendationKey(leadArtist(candidate.artist))),
    recommendationKey(mainArtist(candidate.artist)),
  }..remove('');
  bool sameArtist(String? name) =>
      artistKeys.contains(clean(recommendationKey(mainArtist(name))));
  final matches = <(T, String?)>[];
  for (final result in results) {
    final found = describe(result);
    if (!_matchingDuration(candidate.duration, found.duration)) continue;
    final name = found.title;
    final prefix = RegExp(r'^(.+?)\s+[-–—|]\s+(.+)$').firstMatch(name);
    final suffix = RegExp(r'^(.+)\s+[-–—|]\s+(.+)$').firstMatch(name);
    final prefixedArtist = prefix != null && sameArtist(prefix[1]);
    final suffixedArtist =
        found.youtube && suffix != null && sameArtist(suffix[2]);
    final resultTitle = prefixedArtist
        ? prefix[2]!
        : suffixedArtist
        ? suffix[1]!
        : name;
    if (!recommendationTitles(resultTitle).map(titleKey).any(titles.contains)) {
      continue;
    }
    // Video uploaders need not be the performer: only an explicit
    // artist/title pair counts there.
    if (found.youtube && (prefixedArtist || suffixedArtist)) {
      matches.add((result, found.album));
      continue;
    }
    if (sameArtist(found.artist) || sameArtist(leadArtist(found.artist))) {
      matches.add((result, found.album));
    }
  }
  if (matches.isEmpty) return null;
  final album = recommendationKey(candidate.album);
  if (album.isNotEmpty) {
    for (final (result, other) in matches) {
      if (recommendationKey(other) == album) return result;
    }
  }
  return matches.first.$1;
}
