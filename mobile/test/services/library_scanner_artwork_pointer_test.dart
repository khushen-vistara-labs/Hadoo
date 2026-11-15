import 'package:flutter_test/flutter_test.dart';

import 'package:flick/services/library_scanner_service.dart';

void main() {
  group('LibraryScannerService.canCarryArtworkPointer', () {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(1700000000000);

    test('drops a missing or empty pointer', () {
      expect(
        LibraryScannerService.canCarryArtworkPointer(
          albumArtPath: null,
          isCustom: false,
          existingLastModified: timestamp,
          existingFileSize: 100,
          lastModified: timestamp,
          fileSize: 100,
        ),
        isFalse,
      );
      expect(
        LibraryScannerService.canCarryArtworkPointer(
          albumArtPath: '',
          isCustom: false,
          existingLastModified: timestamp,
          existingFileSize: 100,
          lastModified: timestamp,
          fileSize: 100,
        ),
        isFalse,
      );
    });

    test('keeps custom artwork even when the file changed', () {
      expect(
        LibraryScannerService.canCarryArtworkPointer(
          albumArtPath: '/docs/album_art_overrides/abc.cover',
          isCustom: true,
          existingLastModified: timestamp,
          existingFileSize: 100,
          lastModified: timestamp.add(const Duration(days: 1)),
          fileSize: 200,
        ),
        isTrue,
      );
    });

    test('keeps auto artwork while timestamp and size match', () {
      expect(
        LibraryScannerService.canCarryArtworkPointer(
          albumArtPath: '/artwork/embedded-artwork:abc',
          isCustom: false,
          existingLastModified: timestamp,
          existingFileSize: 100,
          lastModified: timestamp,
          fileSize: 100,
        ),
        isTrue,
      );
    });

    test('drops auto artwork when the timestamp changes', () {
      expect(
        LibraryScannerService.canCarryArtworkPointer(
          albumArtPath: '/artwork/embedded-artwork:abc',
          isCustom: false,
          existingLastModified: timestamp,
          existingFileSize: 100,
          lastModified: timestamp.add(const Duration(seconds: 1)),
          fileSize: 100,
        ),
        isFalse,
      );
    });

    test('drops auto artwork when the size changes', () {
      expect(
        LibraryScannerService.canCarryArtworkPointer(
          albumArtPath: '/artwork/embedded-artwork:abc',
          isCustom: false,
          existingLastModified: timestamp,
          existingFileSize: 100,
          lastModified: timestamp,
          fileSize: 101,
        ),
        isFalse,
      );
    });

    test('keeps auto artwork when the new size is unknown', () {
      expect(
        LibraryScannerService.canCarryArtworkPointer(
          albumArtPath: '/artwork/embedded-artwork:abc',
          isCustom: false,
          existingLastModified: timestamp,
          existingFileSize: 100,
          lastModified: timestamp,
          fileSize: null,
        ),
        isTrue,
      );
    });
  });
}
