import 'package:flutter_test/flutter_test.dart';
import 'package:flick/features/folders/screens/folders_screen.dart';
import 'package:flick/models/song.dart';

Song _song(
  String title,
  String filePath, {
  String folderUri = 'file:///storage/Music',
  String? relativeFolderPath,
}) => Song(
  id: title,
  title: title,
  artist: 'Artist',
  duration: const Duration(minutes: 3),
  fileType: 'FLAC',
  filePath: filePath,
  folderUri: folderUri,
  relativeFolderPath: relativeFolderPath,
);

void main() {
  test('groupByImmediateFolder at nested prefix splits subfolders and songs', () {
    final allSongs = [
      _song('Root', 'file:///storage/Music/Root.flac'),
      _song('A1', 'file:///storage/Music/Album/A1.flac'),
      _song('CD1a', 'file:///storage/Music/Album/CD1/CD1a.flac'),
    ];

    final (:subfolders, :songs) = groupByImmediateFolder(
      allSongs: allSongs,
      folderUri: 'file:///storage/Music',
      prefix: 'Album',
    );

    expect(subfolders.single.key, 'Album/CD1');
    expect(subfolders.single.songs.map((s) => s.title), ['CD1a']);
    expect(songs.map((s) => s.title), ['A1']);
  });

  test('groupByImmediateFolder maps a SAF folderUri onto raw filePaths', () {
    const folderUri =
        'content://com.android.externalstorage.documents/tree/primary%3AFlacs';
    final allSongs = [
      _song(
        'Root',
        '/storage/emulated/0/Flacs/Root.flac',
        folderUri: folderUri,
      ),
      _song(
        'A1',
        '/storage/emulated/0/Flacs/Albums/A1.flac',
        folderUri: folderUri,
      ),
      _song(
        'CD1a',
        '/storage/emulated/0/Flacs/Albums/CD1/CD1a.flac',
        folderUri: folderUri,
      ),
      _song(
        'L1',
        '/storage/emulated/0/Flacs/Live/L1.flac',
        folderUri: folderUri,
      ),
    ];

    final (:subfolders, :songs) = groupByImmediateFolder(
      allSongs: allSongs,
      folderUri: folderUri,
    );

    // The real immediate subfolders, not a synthetic storage/emulated/0 chain.
    expect(subfolders.map((f) => f.key), ['Albums', 'Live']);
    expect(subfolders.map((f) => f.name), ['Albums', 'Live']);
    expect(subfolders.map((f) => f.name), isNot(contains('storage')));
    expect(songs.map((s) => s.title), ['Root']);
  });

  test('groupByImmediateFolder prefers a recorded relativeFolderPath', () {
    // Opaque document ids cannot be decoded into a path, so only the recorded
    // field can tell these folders apart (issue #283).
    const folderUri =
        'content://com.android.externalstorage.documents/tree/1234-5678%3A';
    final allSongs = [
      _song(
        'Root',
        'content://provider/document/root-id',
        folderUri: folderUri,
        relativeFolderPath: '',
      ),
      _song(
        'M1',
        'content://provider/document/m1-id',
        folderUri: folderUri,
        relativeFolderPath: 'Music',
      ),
      _song(
        'A1',
        'content://provider/document/a1-id',
        folderUri: folderUri,
        relativeFolderPath: 'Music/Album',
      ),
      _song(
        'A2',
        'content://provider/document/a2-id',
        folderUri: folderUri,
        relativeFolderPath: 'Music/Album',
      ),
    ];

    final (:subfolders, :songs) = groupByImmediateFolder(
      allSongs: allSongs,
      folderUri: folderUri,
    );

    expect(subfolders.map((f) => f.key), ['Music']);
    expect(subfolders.single.songs.map((s) => s.title), ['M1', 'A1', 'A2']);
    expect(songs.map((s) => s.title), ['Root']);

    final nested = groupByImmediateFolder(
      allSongs: allSongs,
      folderUri: folderUri,
      prefix: 'Music',
    );
    expect(nested.subfolders.single.key, 'Music/Album');
    expect(nested.subfolders.single.songs.map((s) => s.title), ['A1', 'A2']);
    expect(nested.songs.map((s) => s.title), ['M1']);
  });

  test('groupByImmediateFolder falls back to path reconstruction when unrecorded', () {
    const folderUri =
        'content://com.android.externalstorage.documents/tree/primary%3AFlacs';
    final allSongs = [
      _song(
        'A1',
        '/storage/emulated/0/Flacs/Albums/A1.flac',
        folderUri: folderUri,
      ),
    ];

    final (:subfolders, :songs) = groupByImmediateFolder(
      allSongs: allSongs,
      folderUri: folderUri,
    );

    expect(subfolders.single.key, 'Albums');
    expect(songs, isEmpty);
  });
}
