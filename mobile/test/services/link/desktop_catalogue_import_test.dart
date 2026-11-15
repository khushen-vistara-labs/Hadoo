import 'package:flick/data/entities/song_entity.dart';
import 'package:flick/services/link/desktop_catalogue_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'copied original remains local after organization or phone tag edits',
    () {
      final row = SongEntity()
        ..id = 42
        ..remoteId = 'desktop-id'
        ..remoteServerId = 3
        ..filePath = '/Music/song.flac'
        ..title = 'Phone title';
      expect(isDownloadedDesktopOriginal(row), isTrue);
      row.filePath = '/Music/Artist/Album/song.flac';
      expect(isDownloadedDesktopOriginal(row), isTrue);
      row.filePath = 'content://documents/document/song.flac';
      expect(isDownloadedDesktopOriginal(row), isTrue);
      row.filePath = 'ghost://desktop/3/desktop-id';
      expect(isDownloadedDesktopOriginal(row), isFalse);
      row.filePath = 'lokal://3/desktop-id';
      expect(isDownloadedDesktopOriginal(row), isFalse);
      row.sourceType = 'lokal';
      expect(isDownloadedDesktopOriginal(row), isFalse);
    },
  );
}
