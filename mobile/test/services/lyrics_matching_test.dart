import 'package:flick/services/lyrics_matching.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalogue noise is removed but recording variants survive', () {
    expect(lyricsSearchTitle('Teardrop (Official Video)'), 'Teardrop');
    expect(lyricsSearchTitle('Song - 2011 Remaster'), 'Song');
    expect(
      lyricsSearchTitle('Song (Live at Wembley)'),
      'Song (Live at Wembley)',
    );
    expect(lyricsSearchTitle('Song (Club Remix)'), 'Song (Club Remix)');
  });
  test('featured credits are cleaned without breaking band names', () {
    expect(lyricsSearchArtist('Artist feat. Guest'), 'Artist');
    expect(lyricsSearchArtist('Earth, Wind & Fire'), 'Earth, Wind & Fire');
    expect(lyricsSearchArtist('AC/DC'), 'AC/DC');
  });
}
