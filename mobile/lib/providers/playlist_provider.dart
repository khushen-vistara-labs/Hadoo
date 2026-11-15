import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:flick/data/database.dart';
import 'package:flick/models/playlist.dart';
import 'package:flick/models/song.dart';
import 'package:flick/services/playlist_service.dart';
import 'package:flick/services/sources/network_source_service.dart';
import 'package:flick/services/sources/subsonic_service.dart';

final playlistServiceProvider = Provider<PlaylistService>((ref) {
  return PlaylistService.instance;
});

final networkServersProvider = FutureProvider<List<NetworkServerEntity>>((
  ref,
) async {
  return await Database.networkServers.where().findAll();
});

class PlaylistsState {
  final List<Playlist> playlists;
  final bool isLoading;
  final String? error;

  const PlaylistsState({
    this.playlists = const [],
    this.isLoading = true,
    this.error,
  });

  PlaylistsState copyWith({
    List<Playlist>? playlists,
    bool? isLoading,
    String? error,
  }) {
    return PlaylistsState(
      playlists: playlists ?? this.playlists,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  Playlist? getPlaylist(String id) {
    try {
      return playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  int get count => playlists.length;
}

class PlaylistsNotifier extends AsyncNotifier<PlaylistsState> {
  @override
  Future<PlaylistsState> build() async {
    final service = ref.watch(playlistServiceProvider);
    final playlists = await service.getPlaylists();

    return PlaylistsState(playlists: playlists, isLoading: false);
  }

  Future<Playlist?> createPlaylist(
    String name, {
    int? serverId,
    List<Song> initialSongs = const [],
  }) async {
    if (name.trim().isEmpty) return null;

    final service = ref.read(playlistServiceProvider);
    final playlist = await service.createPlaylist(
      name.trim(),
      serverId: serverId,
      initialSongs: initialSongs,
    );
    if (playlist != null && ref.mounted) {
      // An invalidated autoDispose AsyncNotifier can briefly retain its old
      // AsyncData while the user stays on the Playlists page. Publish the
      // created playlist immediately, then reconcile against the service.
      final current = state.value;
      if (current != null) {
        final fresh = await service.getPlaylists();
        if (!ref.mounted) return playlist;
        state = AsyncData(current.copyWith(playlists: fresh, isLoading: false));
      } else {
        ref.invalidateSelf();
      }
    }

    return playlist;
  }

  /// Re-pull playlists from every Subsonic server. Returns the synced count.
  Future<int> syncServerPlaylists() async {
    final servers = await Database.networkServers.where().findAll();
    var synced = 0;
    for (final server in servers.where(
      (s) => s.protocol == NetworkProtocol.subsonic,
    )) {
      synced += await SubsonicService.instance.syncPlaylists(server);
    }
    if (ref.mounted) {
      ref.invalidateSelf();
    }
    return synced;
  }

  Future<bool> deletePlaylist(String id) async {
    final service = ref.read(playlistServiceProvider);
    final success = await service.deletePlaylist(id);

    if (success && ref.mounted) {
      ref.invalidateSelf();
    }

    return success;
  }

  Future<bool> renamePlaylist(String id, String newName) async {
    if (newName.trim().isEmpty) return false;

    final service = ref.read(playlistServiceProvider);
    final playlist = await service.getPlaylist(id);

    if (playlist == null) return false;

    final updated = await service.updatePlaylist(
      playlist.copyWith(name: newName.trim()),
    );

    if (updated != null) {
      if (ref.mounted) {
        ref.invalidateSelf();
      }
      return true;
    }

    return false;
  }

  Future<bool> addSongsToLocalPlaylist(
    String playlistId,
    List<Song> songs,
  ) async {
    final saved = await ref
        .read(playlistServiceProvider)
        .addSongsToLocalPlaylist(playlistId, songs);
    if (saved && ref.mounted) ref.invalidateSelf();
    return saved;
  }

  Future<bool> addSongToPlaylist(
    String playlistId,
    String songId, {
    Song? song,
  }) async {
    final service = ref.read(playlistServiceProvider);
    // Song objects from online search may not be in SongRepository yet.
    // Persist their metadata with the playlist rather than unexpectedly
    // adding the song to the playback queue.
    final success = await service.addSongToPlaylist(
      playlistId,
      songId,
      song: song,
    );

    if (success && ref.mounted) {
      ref.invalidateSelf();
    }

    return success;
  }

  Future<bool> setSongOrder(String playlistId, List<String> songIds) async {
    final service = ref.read(playlistServiceProvider);
    final ok = await service.setSongOrder(playlistId, songIds);
    if (ok && ref.mounted) ref.invalidateSelf();
    return ok;
  }

  Future<void> reorderSongs(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final service = ref.read(playlistServiceProvider);
    final success = await service.reorderSongs(playlistId, oldIndex, newIndex);

    if (success && ref.mounted) {
      ref.invalidateSelf();
    }
  }

  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    final service = ref.read(playlistServiceProvider);
    final success = await service.removeSongFromPlaylist(playlistId, songId);

    if (success && ref.mounted) {
      ref.invalidateSelf();
    }

    return success;
  }

  Future<PlaylistImportResult?> importM3uPlaylist() async {
    final service = ref.read(playlistServiceProvider);
    final result = await service.importM3uPlaylist();

    if (result != null && ref.mounted) {
      ref.invalidateSelf();
    }

    return result;
  }

  Future<PlaylistExportResult?> exportPlaylistAsM3u(
    String playlistId, {
    required bool utf8,
  }) async {
    final service = ref.read(playlistServiceProvider);
    return service.exportPlaylistAsM3u(playlistId, utf8: utf8);
  }
}

final playlistsProvider =
    AsyncNotifierProvider.autoDispose<PlaylistsNotifier, PlaylistsState>(
      PlaylistsNotifier.new,
    );

final playlistProvider = Provider.autoDispose.family<Playlist?, String>((
  ref,
  id,
) {
  return ref.watch(playlistsProvider).value?.getPlaylist(id);
});

final playlistsCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(playlistsProvider).value?.count ?? 0;
});
