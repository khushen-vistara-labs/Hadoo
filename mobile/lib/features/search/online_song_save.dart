import 'dart:io';

import 'package:flick/features/discovery/discovery_models.dart';
import 'package:flick/features/search/library_download.dart';
import 'package:flick/models/song.dart';

/// Session-only source handoffs for downloaded and progressively streamed
/// online songs. A Media3 HTTP handle / growing Morneye FLAC is not a file:
/// saving it must resolve the original provider again with forDownload=true.
/// The registry holds source identity, never signed media URLs or tokens.
class OnlineSongSaveRegistry {
  OnlineSongSaveRegistry._();
  static final OnlineSongSaveRegistry instance = OnlineSongSaveRegistry._();

  static const maxEntries = 256;
  final _resolvers = <String, Future<Song> Function()>{};
  final _inFlight = <String, Future<LibraryDownloadResult>>{};

  void register(Song song, Future<Song> Function() download) {
    _resolvers.remove(song.id);
    _resolvers[song.id] = download;
    while (_resolvers.length > maxEntries) {
      _resolvers.remove(_resolvers.keys.first);
    }
  }

  bool canSave(Song song) {
    if (_resolvers.containsKey(song.id)) return true;
    final path = song.filePath;
    return path != null && path.isNotEmpty &&
        File(path).existsSync() &&
        (song.isExternal || (song.sourcePackage?.startsWith('konnekted.') ?? false));
  }

  Future<LibraryDownloadResult> save(
    Song song, {
    LibraryDownloader? downloader,
  }) {
    final existing = _inFlight[song.id];
    if (existing != null) return existing;
    final task = _save(song, downloader ?? LibraryDownloader());
    _inFlight[song.id] = task;
    return task.whenComplete(() { _inFlight.remove(song.id); });
  }

  Future<LibraryDownloadResult> _save(
    Song song,
    LibraryDownloader downloader,
  ) async {
    Song ready = song;
    // Pending queue items and live handles are not readable filesystem
    // paths. Use the same checked download route as Online Search.
    final path = song.filePath;
    if (path == null || !await File(path).exists()) {
      final resolver = _resolvers[song.id];
      if (resolver == null) {
        throw const DiscoveryException(
          'This stream no longer has a downloadable source. Search for the track again.',
        );
      }
      ready = await resolver();
      final downloaded = ready.filePath;
      if (downloaded == null || !await File(downloaded).exists()) {
        // A Discovery provider can first resolve to an online live stream:
        // follow its registered source download, not the live stream handle.
        final sourceResolver = _resolvers[ready.id];
        if (sourceResolver == null || ready.id == song.id) {
          throw const DiscoveryException(
            'The source did not return a downloadable audio file.',
          );
        }
        ready = await sourceResolver();
      }
    }
    return downloader.save(
      ready, artwork: song.albumArt ?? ready.albumArt,
    );
  }

  /// Test/reset hook, also clears references to stale source contexts.
  void clear() {
    _resolvers.clear();
    _inFlight.clear();
  }
}
