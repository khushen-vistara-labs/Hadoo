import 'package:flick/models/playlist.dart';
import 'package:flick/services/playlist_service.dart';

abstract interface class LinkedPlaylistBackend {
  Future<List<Playlist>> getPlaylists();
  Future<Playlist?> getPlaylist(String id);
  Future<Playlist?> createPlaylist(String name);
  Future<bool> addSong(String playlistId, String songId);
  Future<bool> removeSong(String playlistId, String songId);
  Future<bool> reorderSongs(String playlistId, int oldIndex, int newIndex);
  Future<bool> deletePlaylist(String playlistId);
  Future<bool> replaceOrder(String playlistId, List<String> targetOrder);
}

/// Adapter around the process-wide service used by the existing playlists UI.
/// Tests can inject a small in-memory implementation without touching the
/// application's shared service or database.
class PlaylistServiceBackend implements LinkedPlaylistBackend {
  final PlaylistService service;

  PlaylistServiceBackend({PlaylistService? service})
    : service = service ?? PlaylistService.instance;

  @override
  Future<List<Playlist>> getPlaylists() => service.getPlaylists();

  @override
  Future<Playlist?> getPlaylist(String id) => service.getPlaylist(id);

  @override
  Future<Playlist?> createPlaylist(String name) => service.createPlaylist(name);

  @override
  Future<bool> addSong(String playlistId, String songId) =>
      service.addSongToPlaylist(playlistId, songId);

  @override
  Future<bool> removeSong(String playlistId, String songId) =>
      service.removeSongFromPlaylist(playlistId, songId);

  @override
  Future<bool> reorderSongs(String playlistId, int oldIndex, int newIndex) =>
      service.reorderSongs(playlistId, oldIndex, newIndex);

  @override
  Future<bool> deletePlaylist(String playlistId) =>
      service.deletePlaylist(playlistId);

  @override
  Future<bool> replaceOrder(String playlistId, List<String> targetOrder) async {
    final currentPlaylist = await service.getPlaylist(playlistId);
    if (currentPlaylist == null) return false;
    final working = List<String>.from(currentPlaylist.songIds);
    for (var targetIndex = 0; targetIndex < targetOrder.length; targetIndex++) {
      final id = targetOrder[targetIndex];
      final oldIndex = working.indexOf(id);
      if (oldIndex < 0 || oldIndex == targetIndex) continue;
      // PlaylistService follows Flutter's reorderable-list convention and
      // decrements newIndex when moving an item down.
      final serviceNewIndex = oldIndex < targetIndex
          ? targetIndex + 1
          : targetIndex;
      if (!await service.reorderSongs(playlistId, oldIndex, serviceNewIndex)) {
        return false;
      }
      working.removeAt(oldIndex);
      working.insert(targetIndex, id);
    }
    return working.length == targetOrder.length &&
        _sameOrder(working, targetOrder);
  }

  static bool _sameOrder(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
