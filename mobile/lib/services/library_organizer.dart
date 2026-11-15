import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';
import '../data/entities/song_entity.dart';
import 'music_folder_service.dart';
import 'music_library_path.dart';
import 'player_service.dart';
import 'link/link_download_outbox.dart';

class OrganizeFolder {
  const OrganizeFolder(this.uri, this.path);
  final String uri, path;
}

class OrganizeMove {
  const OrganizeMove({
    required this.ids,
    required this.source,
    required this.target,
    required this.root,
    required this.folderUri,
    required this.relative,
    required this.bytes,
  });
  final List<int> ids;
  final String source, target, root, folderUri, relative;
  final int bytes;
  Map<String, Object> toJson() => {
    'ids': ids,
    'source': source,
    'target': target,
    'root': root,
    'folderUri': folderUri,
    'relative': relative,
    'bytes': bytes,
  };
  factory OrganizeMove.fromJson(Map<String, dynamic> value) => OrganizeMove(
    ids: (value['ids'] as List).cast<int>(),
    source: value['source'] as String,
    target: value['target'] as String,
    root: value['root'] as String,
    folderUri: value['folderUri'] as String,
    relative: value['relative'] as String,
    bytes: value['bytes'] as int,
  );
}

class OrganizePlan {
  const OrganizePlan(this.moves, {this.organized = 0, this.skipped = 0});
  final List<OrganizeMove> moves;
  final int organized, skipped;
}

class OrganizeResult {
  const OrganizeResult(this.moved, this.failures, this.cancelled);
  final int moved;
  final List<String> failures;
  final bool cancelled;
}

/// Explicit relocation under saved library roots. Song IDs are never recreated.
/// One durable pending move permits recovery after process death between the
/// filesystem rename and the database transaction. Never overwrite a file.
class LibraryOrganizer {
  LibraryOrganizer({
    Future<List<SongEntity>> Function()? rows,
    Future<List<OrganizeFolder>> Function()? folders,
    Future<void> Function(OrganizeMove)? commit,
    Future<void> Function(String, String, String, String)? moveFile,
    Future<void> Function(OrganizeMove)? afterMove,
    String? Function()? activePath,
  }) : _defaultRows = rows == null,
       _rows = rows ?? _readRows,
       _folders = folders ?? _readFolders,
       _commit = commit ?? _commitRows,
       _move = moveFile ?? _nativeMove,
       _afterMove = afterMove ?? _refresh,
       _active =
           activePath ??
           (() => PlayerService().currentSongNotifier.value?.filePath);
  static const journalKey = 'lokal.library.organizer.pending';
  static bool _running = false;
  final bool _defaultRows;
  final Future<List<SongEntity>> Function() _rows;
  final Future<List<OrganizeFolder>> Function() _folders;
  final Future<void> Function(OrganizeMove) _commit, _afterMove;
  final Future<void> Function(String, String, String, String) _move;
  final String? Function() _active;
  static Future<List<SongEntity>> _readRows() =>
      Database.songs.where().findAll();
  static Future<List<OrganizeFolder>> _readFolders() async {
    final service = MusicFolderService();
    final result = <OrganizeFolder>[];
    for (final folder in await service.getSavedFolders()) {
      final path = (await service.resolveStorageInfo(folder.uri)).fsPath;
      if (path != null && p.isAbsolute(path))
        result.add(OrganizeFolder(folder.uri, p.normalize(path)));
    }
    return result;
  }

  static Future<void> _nativeMove(
    String source,
    String target,
    String root,
    String folderUri,
  ) async {
    await const MethodChannel('com.mossapps.flick/storage')
        .invokeMethod<void>('moveLibraryMusicFile', {
          'source': source,
          'target': target,
          'root': root,
          'folderUri': folderUri,
        });
  }

  static Future<void> _commitRows(OrganizeMove move) =>
      Database.instance.writeTxn(() async {
        final rows = await Database.songs.getAll(move.ids);
        if (rows.any(
          (row) =>
              row == null ||
              (row.filePath != move.source && row.filePath != move.target),
        )) {
          throw StateError('Library changed. Preview the organization again.');
        }
        for (final row in rows.cast<SongEntity>()) {
          row.filePath = move.target;
          row.folderUri = move.folderUri;
          row.relativeFolderPath = move.relative;
          row.mediaStoreUri = null;
        }
        await Database.songs.putAll(rows.cast<SongEntity>());
      });
  static Future<void> _refresh(OrganizeMove move) async {
    PlayerService().syncSongFileLocation(
      oldPath: move.source,
      newPath: move.target,
      folderUri: move.folderUri,
      relativeFolderPath: move.relative,
    );
    await LinkDownloadOutbox.relocate(move.source, move.target);
    try {
      await MusicFolderService.removeFromMediaStore(move.source);
      await MusicFolderService().indexMediaFiles([move.target]);
    } catch (_) {
      /* The library already points at the moved original. */
    }
  }

  Future<void> _clear(SharedPreferences prefs) async {
    if (!await prefs.remove(journalKey))
      throw StateError(
        'Could not finish the move journal. Reopen this page to recover.',
      );
  }

  Future<void> recover() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(journalKey);
    if (raw == null) return;
    final move = OrganizeMove.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    final oldExists = await File(move.source).exists(),
        newExists = await File(move.target).exists();
    if (oldExists && !newExists) {
      await _clear(prefs);
      return;
    }
    if (!oldExists &&
        newExists &&
        await File(move.target).length() == move.bytes) {
      await _commit(move);
      await _afterMove(move);
      await _clear(prefs);
      return;
    }
    throw StateError(
      'An interrupted move needs attention. Both paths were kept in the organizer journal; no file will be overwritten.',
    );
  }

  Future<OrganizePlan> preview() async {
    if (_running) throw StateError('Library organization is already running.');
    await recover();
    final folders = await _folders();
    folders.sort((a, b) => b.path.length.compareTo(a.path.length));
    final groups = <String, List<SongEntity>>{};
    var skipped = 0, organized = 0;
    for (final row in await _rows()) {
      if (!p.isAbsolute(row.filePath)) {
        // Cloud/history rows are not physical files to organize.
        if (row.filePath.startsWith('content://') ||
            row.filePath.startsWith('file://'))
          skipped++;
        continue;
      }
      groups.putIfAbsent(row.filePath, () => []).add(row);
    }
    final moves = <OrganizeMove>[], reserved = <String>{};
    for (final group in groups.entries) {
      final path = group.key;
      if (group.value.any(
        (row) => row.startOffsetMs != null || row.endOffsetMs != null,
      )) {
        skipped++;
        continue; // Moving audio alone would break its CUE sidecar references.
      }
      final folder = folders.where((f) => p.isWithin(f.path, path)).firstOrNull;
      if (folder == null ||
          path == _active() ||
          await FileSystemEntity.type(path, followLinks: false) !=
              FileSystemEntityType.file) {
        skipped++;
        continue;
      }
      final realRoot = await Directory(folder.path).resolveSymbolicLinks();
      final realSource = await File(path).resolveSymbolicLinks();
      if (!p.isWithin(realRoot, realSource)) {
        skipped++;
        continue;
      }
      final variants = group.value
          .map(
            (r) => MusicLibraryPath.directories(
              artist: r.artist,
              album: r.album,
              albumArtist: r.albumArtist,
            ).join('/'),
          )
          .toSet();
      if (variants.length != 1) {
        skipped++;
        continue;
      } // Conflicting CUE album identities.
      final relative = variants.single;
      final directory = p.joinAll([folder.path, ...relative.split('/')]);
      if (p.equals(p.dirname(path), directory)) {
        organized++;
        continue;
      }
      final name = MusicLibraryPath.segment(
        p.basenameWithoutExtension(path),
        'Song',
      );
      final extension = p.extension(path);
      var target = p.join(directory, '$name$extension');
      for (
        var n = 2;
        reserved.contains(target) ||
            await FileSystemEntity.type(target, followLinks: false) !=
                FileSystemEntityType.notFound;
        n++
      ) {
        target = p.join(directory, '$name ($n)$extension');
      }
      reserved.add(target);
      moves.add(
        OrganizeMove(
          ids: group.value.map((r) => r.id).toList(),
          source: path,
          target: target,
          root: folder.path,
          folderUri: folder.uri,
          relative: relative,
          bytes: await File(path).length(),
        ),
      );
    }
    return OrganizePlan(moves, organized: organized, skipped: skipped);
  }

  Future<OrganizeResult> run(
    OrganizePlan plan, {
    required bool Function() cancelled,
    required void Function(int, String) onProgress,
  }) async {
    if (_running) throw StateError('Library organization is already running.');
    _running = true;
    final errors = <String>[];
    var moved = 0, processed = 0;
    try {
      await recover();
      final prefs = await SharedPreferences.getInstance();
      for (final move in plan.moves) {
        if (cancelled()) break;
        onProgress(processed, p.basename(move.source));
        if (move.source == _active()) {
          errors.add(
            '${p.basename(move.source)}: currently loaded; try again after changing songs.',
          );
          processed++;
          continue;
        }
        var renamed = false;
        try {
          final rows = _defaultRows
              ? (await Database.songs.getAll(move.ids))
                    .whereType<SongEntity>()
                    .toList()
              : await _rows();
          if (!move.ids.every(
            (id) => rows.any((r) => r.id == id && r.filePath == move.source),
          ))
            throw StateError('Library changed; preview again.');
          if (await File(move.source).length() != move.bytes)
            throw StateError('File changed; preview again.');
          if (!await prefs.setString(journalKey, jsonEncode(move.toJson())))
            throw StateError('Could not save the move journal.');
          await _move(move.source, move.target, move.root, move.folderUri);
          renamed = true;
          await _commit(move);
          moved++;
        } catch (error) {
          // A channel failure may arrive after the native rename completed.
          if (!renamed && !await File(move.source).exists()) {
            if (await File(move.target).exists() &&
                await File(move.target).length() == move.bytes) {
              renamed = true;
            } else {
              throw StateError(
                'A file move was interrupted. Reopen this page to recover; the move journal was retained.',
              );
            }
          }
          if (renamed) {
            try {
              await _move(move.target, move.source, move.root, move.folderUri);
            } catch (_) {
              throw StateError(
                'Could not finish or undo a move. Reopen Organize existing library to recover it.',
              );
            }
          }
          errors.add(
            '${p.basename(move.source)}: could not move safely. Check folder access and refresh the preview.',
          );
          await _clear(prefs);
          processed++;
          continue;
        }
        // Keep the journal if a dependent path update fails after commit;
        // recovery can finish it without moving or recreating the song again.
        await _afterMove(move);
        await _clear(prefs);
        processed++;
        onProgress(processed, p.basename(move.target));
      }
      return OrganizeResult(moved, errors, cancelled());
    } finally {
      _running = false;
    }
  }
}
