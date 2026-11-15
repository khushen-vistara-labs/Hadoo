import 'package:flick/features/discovery/recommendation_match.dart';
import 'package:flutter_test/flutter_test.dart';

RecommendationCandidate _song(
  String artist,
  String title, {
  String? album,
  int? seconds,
  bool youtube = false,
}) => RecommendationCandidate(
  title: title,
  artist: artist,
  album: album,
  duration: seconds == null ? null : Duration(seconds: seconds),
  youtube: youtube,
);

RecommendationCandidate? _match(
  RecommendationCandidate wanted,
  List<RecommendationCandidate> results,
) => recommendationMatch(wanted, results, (result) => result);

void main() {
  test('artwork confidence accepts minor title wording with exact artist', () {
    final score = artworkMatchConfidence(
      title: 'Biggest in the City',
      artist: 'Knuckle G',
      candidateTitle: 'Biggest of the City (Original Mix)',
      candidateArtist: 'Knuckle G',
    );
    expect(score, greaterThanOrEqualTo(artworkConfidenceThreshold));
    expect(score, lessThan(1));
  });

  test('mobile Discord scores Big Data - Dangerous with credited guest artist', () {
    double score(
      String candidateTitle,
      String candidateArtist, {
      bool allowCollaborations = false,
    }) => artworkMatchConfidence(
      title: 'Dangerous',
      artist: 'Big Data',
      candidateTitle: candidateTitle,
      candidateArtist: candidateArtist,
      allowCollaborations: allowCollaborations,
    );
    // The existing exact-artist requirement is deliberately unchanged for
    // Discovery; only Discord opts in to credited collaborators.
    expect(score('Dangerous', 'Big Data & Joywave'), 0);
    expect(score('Dangerous', 'Big Data & Joywave',
        allowCollaborations: true), 1.0);
    expect(score('Dangerous (feat. Joywave)', 'Big Data & Joywave',
        allowCollaborations: true), 1.0);
    expect(score('Dangerous (Oliver Remix)', 'Big Data & Joywave',
        allowCollaborations: true), 0);
    expect(score('Dangerous', 'Big Data Theory & Joywave',
        allowCollaborations: true), 0);
    expect(score('Dangerous', 'David Guetta', allowCollaborations: true), 0);
    // Joywave is a guest, not the leading billed artist for this release.
    expect(artworkMatchConfidence(
      title: 'Dangerous',
      artist: 'Joywave',
      candidateTitle: 'Dangerous',
      candidateArtist: 'Big Data & Joywave',
      allowCollaborations: true,
    ), 0);
    // Preserve genuine band names containing an ampersand/comma.
    expect(artworkArtistsMatch('Earth', 'Earth, Wind & Fire',
        allowCollaborations: true), isFalse);
    expect(artworkArtistsMatch('Simon', 'Simon & Garfunkel',
        allowCollaborations: true), isFalse);
  });

  test('artwork confidence rejects remixes, wrong artists and other songs', () {
    double score(String foundTitle, String foundArtist) => artworkMatchConfidence(
      title: 'Biggest in the City',
      artist: 'Knuckle G',
      candidateTitle: foundTitle,
      candidateArtist: foundArtist,
    );
    expect(score('Biggest of the City (Remix)', 'Knuckle G'), 0);
    expect(score('Biggest of the City', 'Another Artist'), 0);
    expect(score('Biggest in Paris', 'Knuckle G'), lessThan(artworkConfidenceThreshold));
    expect(score('Biggest of the City', 'Knuckle G'), greaterThanOrEqualTo(artworkConfidenceThreshold));
  });

  test('keys drop Latin accents and punctuation but keep other scripts', () {
    expect(recommendationKey('Beyoncé — Halo!'), 'beyonce halo');
    expect(recommendationKey('ＡＢＣ'), 'abc');
    expect(recommendationKey('流線 - ryusen'), '流線 ryusen');
    expect(recommendationKey('Sigur Rós'), 'sigur ros');
  });

  test('titles lose guests and remaster labels, not versions', () {
    expect(searchTitle('American Boy (feat. Kanye West)'), 'American Boy');
    expect(searchTitle('Song (Remix) feat. X'), 'Song (Remix)');
    expect(searchTitle('Song (with X Remix)'), 'Song (with X Remix)');
    expect(titleKey('Hey Jude - Remastered 2015'), 'hey jude');
    expect(titleKey('Hey Jude [Explicit]'), 'hey jude');
    expect(titleKey('Hey Jude (Live)'), isNot('hey jude'));
    expect(mainArtist('Estelle [feat. Joi]'), 'Estelle');
    expect(leadArtist('Tyler, The Creator, Kali Uchis'), 'Tyler, The Creator');
    expect(leadArtist('A; B'), 'A');
  });

  test('bilingual titles match either name', () {
    expect(recommendationTitles('流線 - ryusen'), [
      '流線 - ryusen',
      'ryusen',
      '流線',
    ]);
    expect(
      _match(_song('Artist', '流線'), [_song('Artist', '流線 - ryusen')]),
      isNotNull,
    );
  });

  test('a match needs the title and the artist', () {
    final wanted = _song('Estelle', 'American Boy');
    final right = _song(
      'Estelle feat. Kanye West',
      'American Boy (feat. Kanye West)',
    );
    expect(
      _match(wanted, [_song('Someone Else', 'American Boy'), right]),
      right,
    );
    expect(_match(wanted, [_song('Estelle', 'American Boy (Live)')]), isNull);
    expect(_match(wanted, [_song('Estelle', 'Grateful')]), isNull);
  });

  test('the same album wins, and lengths must agree when known', () {
    final wanted = _song('A', 'Song', album: 'First', seconds: 200);
    final compilation = _song('A', 'Song', album: 'Hits', seconds: 201);
    final album = _song('A', 'Song', album: 'First', seconds: 199);
    expect(_match(wanted, [compilation, album]), album);
    expect(_match(wanted, [_song('A', 'Song', seconds: 260)]), isNull);
  });

  test('YouTube uploads count only with the artist in the title', () {
    final wanted = _song('Daft Punk', 'One More Time');
    final upload = _song(
      'Some Channel',
      'Daft Punk - One More Time',
      youtube: true,
    );
    expect(_match(wanted, [upload]), upload);
    expect(
      _match(wanted, [_song('Some Channel', 'One More Time', youtube: true)]),
      isNull,
    );
  });

  test('queries try clean names first', () {
    final queries = recommendationQueries(
      _song('Estelle [feat. Kanye West]', 'American Boy (feat. Kanye West)'),
    );
    expect(queries.first, 'Estelle American Boy');
    expect(queries.length, lessThanOrEqualTo(6));
  });
}
