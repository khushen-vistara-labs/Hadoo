import 'package:flick/services/music_library_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups by album artist when available and retains Unicode', () {
    expect(
      MusicLibraryPath.directories(
        artist: 'Track Artist',
        albumArtist: '宇多田ヒカル',
        album: '初恋',
      ),
      ['宇多田ヒカル', '初恋'],
    );
  });
  test('missing tags have stable artist and album folders', () {
    expect(MusicLibraryPath.directories(artist: ' ', album: null), [
      'Unknown Artist',
      'Unknown Album',
    ]);
  });
  test(
    'metadata cannot escape the selected folder or create arbitrary levels',
    () {
      for (final value in [
        '../',
        '..',
        '/storage/music',
        r'C:\music\album',
        'NUL',
        '.  ',
      ]) {
        final parts = MusicLibraryPath.directories(artist: value, album: value);
        for (final part in parts) {
          expect(part, isNot(isIn(['', '.', '..', 'NUL'])));
          expect(part.contains('/'), isFalse);
          expect(part.contains(r'\'), isFalse);
        }
      }
      expect(MusicLibraryPath.segment('a' * 200, 'fallback').length, 100);
    },
  );
}
