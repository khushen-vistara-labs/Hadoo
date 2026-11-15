import 'dart:convert';
import 'dart:io';

import 'package:flick/data/entities/song_entity.dart';
import 'package:flick/services/library_organizer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late List<SongEntity> rows;
  late File source;
  SongEntity row(int id, String path) => SongEntity()
    ..id = id
    ..filePath = path
    ..title = 'Song'
    ..artist = 'Artist'
    ..album = 'Album';
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    root = await Directory.systemTemp.createTemp('library-organizer');
    source = await File(p.join(root.path, 'song.flac'))
        .writeAsBytes([1, 2, 3, 4]);
    rows = [row(42, source.path)];
  });
  tearDown(() async => root.delete(recursive: true));
  Future<void> move(String from, String to, String base, String uri) async {
    expect(p.isWithin(base, from), isTrue);
    expect(p.isWithin(base, to), isTrue);
    if (await File(to).exists()) throw const FileSystemException('collision');
    await Directory(p.dirname(to)).create(recursive: true);
    await File(from).rename(to);
  }

  Future<void> commit(OrganizeMove item) async {
    for (final entity in rows.where((r) => item.ids.contains(r.id))) {
      entity.filePath = item.target;
      entity.folderUri = item.folderUri;
      entity.relativeFolderPath = item.relative;
    }
  }

  LibraryOrganizer service({
    Future<void> Function(OrganizeMove)? persist,
    Future<void> Function(String, String, String, String)? mover,
    String? active,
  }) => LibraryOrganizer(
    rows: () async => rows,
    folders: () async => [OrganizeFolder('chosen-folder', root.path)],
    commit: persist ?? commit,
    moveFile: mover ?? move,
    afterMove: (_) async {},
    activePath: () => active,
  );
  test(
    'previews without moving and preserves row ID and bytes when organized',
    () async {
      final organizer = service();
      final plan = await organizer.preview();
      expect(plan.moves.length, 1);
      expect(source.existsSync(), isTrue);
      final result = await organizer.run(
        plan,
        cancelled: () => false,
        onProgress: (_, _) {},
      );
      expect(result.moved, 1);
      expect(result.failures, isEmpty);
      expect(rows.single.id, 42);
      expect(
        rows.single.filePath,
        p.join(root.path, 'Artist', 'Album', 'song.flac'),
      );
      expect(rows.single.relativeFolderPath, 'Artist/Album');
      expect(File(rows.single.filePath).readAsBytesSync(), [1, 2, 3, 4]);
      expect(source.existsSync(), isFalse);
      expect((await organizer.preview()).moves, isEmpty);
    },
  );
  test(
    'existing destination is kept and the moved file gets a numbered name',
    () async {
      final other = File(p.join(root.path, 'Artist', 'Album', 'song.flac'));
      await other.parent.create(recursive: true);
      await other.writeAsBytes([9]);
      final organizer = service();
      final plan = await organizer.preview();
      expect(p.basename(plan.moves.single.target), 'song (2).flac');
      await organizer.run(plan, cancelled: () => false, onProgress: (_, _) {});
      expect(other.readAsBytesSync(), [9]);
      expect(File(rows.single.filePath).readAsBytesSync(), [1, 2, 3, 4]);
    },
  );
  test('database failure rolls the file back and leaves its existing row untouched', () async {
    final organizer = service(
      persist: (_) async => throw StateError('commit failed'),
    );
    final result = await organizer.run(
      await organizer.preview(),
      cancelled: () => false,
      onProgress: (_, _) {},
    );
    expect(result.moved, 0);
    expect(result.failures.length, 1);
    expect(rows.single.filePath, source.path);
    expect(source.readAsBytesSync(), [1, 2, 3, 4]);
    expect(
      (await SharedPreferences.getInstance()).getString(
        LibraryOrganizer.journalKey,
      ),
      isNull,
    );
  });
  test(
    'interrupted rename is recovered into the same row before a new preview',
    () async {
      final organizer = service();
      final plan = await organizer.preview();
      final item = plan.moves.single;
      await (await SharedPreferences.getInstance()).setString(
        LibraryOrganizer.journalKey,
        jsonEncode(item.toJson()),
      );
      await move(item.source, item.target, item.root, item.folderUri);
      expect(rows.single.filePath, source.path);
      final recovered = await organizer.preview();
      expect(rows.single.id, 42);
      expect(rows.single.filePath, item.target);
      expect(recovered.moves, isEmpty);
      expect(
        (await SharedPreferences.getInstance()).getString(
          LibraryOrganizer.journalKey,
        ),
        isNull,
      );
    },
  );
  test(
    'channel failure after the native move still rolls it back safely',
    () async {
      var first = true;
      final organizer = service(
        mover: (from, to, base, uri) async {
          await move(from, to, base, uri);
          if (first) {
            first = false;
            throw StateError('channel disconnected after move');
          }
        },
      );
      final result = await organizer.run(
        await organizer.preview(),
        cancelled: () => false,
        onProgress: (_, _) {},
      );
      expect(result.failures.length, 1);
      expect(source.existsSync(), isTrue);
      expect(rows.single.filePath, source.path);
    },
  );
  test(
    'loaded songs, document-only sources and CUE audio are skipped',
    () async {
      var plan = await service(active: source.path).preview();
      expect(plan.moves, isEmpty);
      rows.single.startOffsetMs = 0;
      plan = await service().preview();
      expect(plan.moves, isEmpty);
      rows = [row(42, 'content://media/42')];
      plan = await service().preview();
      expect(plan.moves, isEmpty);
      expect(plan.skipped, 1);
    },
  );
  test(
    'cancel before the next file leaves originals and rows untouched',
    () async {
      final organizer = service();
      final result = await organizer.run(
        await organizer.preview(),
        cancelled: () => true,
        onProgress: (_, _) {},
      );
      expect(result.cancelled, isTrue);
      expect(result.moved, 0);
      expect(source.existsSync(), isTrue);
    },
  );
}
