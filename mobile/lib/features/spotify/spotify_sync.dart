import 'package:flick/models/playlist.dart';
import 'package:flick/models/song.dart';
import 'package:flick/data/repositories/song_repository.dart';
import 'package:flick/services/favorites_service.dart';
import 'package:flick/services/playlist_service.dart';

import 'spotify_api.dart';
import 'spotify_http.dart';
import 'spotify_models.dart';
import 'spotify_storage.dart';

abstract interface class SpotifyLocalLibrary {
  Future<List<Song>> allSongs();
}

class SongRepositorySpotifyLocalLibrary implements SpotifyLocalLibrary {
  SongRepositorySpotifyLocalLibrary({SongRepository? repository})
    : _repository = repository ?? SongRepository();
  final SongRepository _repository;
  @override
  Future<List<Song>> allSongs() => _repository.getAllSongs();
}

abstract interface class SpotifyPlaylistSink {
  Future<Playlist?> upsertPlaylist({
    required String? existingLocalId,
    required String name,
    required List<String> songIds,
    required String sourcePath,
  });
}

class PlaylistServiceSpotifySink implements SpotifyPlaylistSink {
  PlaylistServiceSpotifySink({PlaylistService? service})
    : _service = service ?? PlaylistService.instance;
  final PlaylistService _service;

  @override
  Future<Playlist?> upsertPlaylist({
    required String? existingLocalId,
    required String name,
    required List<String> songIds,
    required String sourcePath,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return null;
    if (existingLocalId != null) {
      final existing = await _service.getPlaylist(existingLocalId);
      if (existing != null) {
        return _service.updatePlaylist(
          existing.copyWith(
            name: cleanName,
            songIds: songIds,
            sourcePath: sourcePath,
          ),
        );
      }
    }
    final created = await _service.createPlaylist(cleanName);
    if (created == null) return null;
    return _service.updatePlaylist(
      created.copyWith(songIds: songIds, sourcePath: sourcePath),
    );
  }
}

abstract interface class SpotifyFavoritesSink {
  Future<bool> isFavorite(String songId);
  Future<void> addFavorite(String songId);
  Future<List<Song>> readFavorites();
}

class FavoritesServiceSpotifySink implements SpotifyFavoritesSink {
  FavoritesServiceSpotifySink({FavoritesService? service})
    : _service = service ?? FavoritesService();
  final FavoritesService _service;
  @override
  Future<bool> isFavorite(String songId) => _service.isFavorite(songId);
  @override
  Future<void> addFavorite(String songId) => _service.addFavorite(songId);
  @override
  Future<List<Song>> readFavorites() => _service.getFavorites();
}

class SpotifyMatcher {
  const SpotifyMatcher({this.durationToleranceMs = 0});

  final int durationToleranceMs;

  /// Returns a song only when exactly one library entry satisfies all supplied
  /// identifying fields. Ambiguous candidates remain explicitly unmatched.
  Song? match(SpotifyTrack track, Iterable<Song> songs) {
    final candidates = songs.where((song) {
      if (_key(song.title) != _key(track.title) ||
          _key(song.artist) != _key(track.artist)) {
        return false;
      }
      if (track.durationMs <= 0 || song.duration.inMilliseconds <= 0) {
        return false;
      }
      if ((song.duration.inMilliseconds - track.durationMs).abs() >
          durationToleranceMs) {
        return false;
      }
      final spotifyAlbum = _key(track.album);
      final localAlbum = _key(song.album);
      if (spotifyAlbum.isNotEmpty &&
          localAlbum.isNotEmpty &&
          spotifyAlbum != localAlbum) {
        return false;
      }
      return true;
    }).toList();
    return candidates.length == 1 ? candidates.single : null;
  }

  String _key(String? value) => value?.trim().toLowerCase() ?? '';
}

class SpotifySyncService {
  SpotifySyncService({
    required this._api,
    required this._metadata,
    SpotifyLocalLibrary? library,
    SpotifyPlaylistSink? playlists,
    SpotifyFavoritesSink? favorites,
    SpotifyMatcher? matcher,
    DateTime Function()? now,
  }) : _library = library ?? SongRepositorySpotifyLocalLibrary(),
       _playlists = playlists ?? PlaylistServiceSpotifySink(),
       _favorites = favorites ?? FavoritesServiceSpotifySink(),
       _matcher = matcher ?? const SpotifyMatcher(),
       _now = now ?? (() => DateTime.now().toUtc());

  final SpotifyLibraryApi _api;
  final SpotifyMetadataStore _metadata;
  final SpotifyLocalLibrary _library;
  final SpotifyPlaylistSink _playlists;
  final SpotifyFavoritesSink _favorites;
  final SpotifyMatcher _matcher;
  final DateTime Function() _now;

  Future<List<SpotifyPlaylist>> loadPlaylists({
    void Function(int loaded)? onProgress,
    SpotifyCancellation? cancellation,
  }) async {
    final playlists = await _api.getPlaylists(
      onProgress: onProgress,
      cancellation: cancellation,
    );
    return [
      const SpotifyPlaylist(
        id: 'liked',
        name: 'Liked Songs',
        imageUrl: 'https://misc.scdn.co/liked-songs/liked-songs-640.png',
      ),
      ...playlists,
    ];
  }

  Future<SpotifyPlaylistImportReport> importPlaylist(
    SpotifyPlaylist playlist, {
    void Function(int loaded)? onProgress,
    SpotifyCancellation? cancellation,
  }) async {
    if (playlist.id == 'liked') {
      throw const SpotifyFailure('Liked Songs uses the dedicated sync action.');
    }
    final tracks = await _api.getPlaylistTracks(
      playlist.id,
      onProgress: onProgress,
      cancellation: cancellation,
    );
    final songs = await _library.allSongs();
    final matchedIds = <String>[];
    final unmatched = <SpotifyUnmatchedTrack>[];
    for (final track in tracks) {
      final match = _matcher.match(track, songs);
      if (match == null) {
        unmatched.add(track.toUnmatched());
      } else if (!matchedIds.contains(match.id)) {
        matchedIds.add(match.id);
      }
    }
    final current = await _metadata.load();
    final previous = current.playlists[playlist.id];
    final saved = await _playlists.upsertPlaylist(
      existingLocalId: previous?.localPlaylistId,
      name: playlist.name,
      songIds: matchedIds,
      sourcePath: 'spotify://playlist/${playlist.id}',
    );
    if (saved == null) {
      throw const SpotifyFailure('Could not save the local playlist.');
    }
    await _metadata.savePlaylist(
      SpotifyPlaylistMetadata(
        playlistId: playlist.id,
        sourceUri: 'spotify:playlist:${playlist.id}',
        name: playlist.name,
        lastImportedAt: _now(),
        unmatchedTracks: unmatched,
        localPlaylistId: saved.id,
      ),
    );
    return SpotifyPlaylistImportReport(
      playlist: playlist,
      totalTracks: tracks.length,
      matchedTracks: matchedIds.length,
      savedSongIds: matchedIds,
      unmatchedTracks: unmatched,
      localPlaylistName: saved.name,
    );
  }

  /// One-way import: Spotify liked songs add local favorites only. Existing
  /// local favorites and all unmatched Spotify items are retained.
  Future<SpotifyLikedSongsSyncReport> syncLikedSongs({
    List<SpotifyTrack>? suppliedTracks,
    void Function(int loaded)? onProgress,
    SpotifyCancellation? cancellation,
  }) async {
    final tracks =
        suppliedTracks ??
        await _api.getLikedSongs(
          onProgress: onProgress,
          cancellation: cancellation,
        );
    final songs = await _library.allSongs();
    final matched = <Song>[];
    final unmatched = <SpotifyUnmatchedTrack>[];
    for (final track in tracks) {
      final match = _matcher.match(track, songs);
      if (match == null) {
        unmatched.add(track.toUnmatched());
      } else if (!matched.any((song) => song.id == match.id)) {
        matched.add(match);
      }
    }
    var added = 0;
    var alreadyLiked = 0;
    for (final song in matched) {
      cancellation?.check();
      if (await _favorites.isFavorite(song.id)) {
        alreadyLiked++;
      } else {
        await _favorites.addFavorite(song.id);
        added++;
      }
    }
    final readback = await _favorites.readFavorites();
    final readbackIds = readback.map((song) => song.id).toSet();
    final verified = matched.every((song) => readbackIds.contains(song.id));
    await _metadata.saveLikedSync(_now());
    return SpotifyLikedSongsSyncReport(
      totalTracks: tracks.length,
      matchedTracks: matched.length,
      addedCount: added,
      alreadyLikedCount: alreadyLiked,
      unmatchedTracks: unmatched,
      readbackVerified: verified,
    );
  }
}
