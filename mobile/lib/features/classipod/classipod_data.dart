import 'package:flick/data/repositories/song_repository.dart';
import 'package:flick/features/konnekted/konnekted_data.dart';
import 'package:flick/models/song.dart';
import 'package:flick/providers/app_preferences_provider.dart';
import 'package:flick/providers/player_provider.dart';
import 'package:flick/providers/songs_provider.dart';
import 'package:flick/services/player_service.dart';
import 'package:flick/widgets/common/cached_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A local-only view of the existing library, retaining the original Songs.
/// Album identity and disc/track ordering follow the existing SongsState rules.
class ClassipodLibrary {
  ClassipodLibrary(List<Song> library) {
    final local = library
        .where((song) => !song.isNetworkSource && !song.isExternal)
        .toList();
    songs = List.unmodifiable(
      SongsState.computeSortedSongs(
        local,
        SongSortOption.title,
        SongFileTypeFilter.all,
      ),
    );
    albums = List.unmodifiable(
      SongsState(songs: local, sortOption: SongSortOption.album).albumGroups,
    );
    final grouped = <String, List<Song>>{};
    for (final song in songs) {
      grouped.putIfAbsent(song.artist, () => []).add(song);
    }
    artists = List.unmodifiable(
      grouped.keys.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
    );
    artistSongs = Map.unmodifiable(
      grouped.map(
        (key, value) => MapEntry(key, List<Song>.unmodifiable(value)),
      ),
    );
  }

  late final List<Song> songs;
  late final List<AlbumGroup> albums;
  late final List<String> artists;
  late final Map<String, List<Song>> artistSongs;

  List<Song> songsForAlbum(String? key) {
    for (final album in albums) {
      if (album.key == key) return album.songs;
    }
    return const [];
  }
}

final classipodLibraryProvider =
    Provider.autoDispose<AsyncValue<ClassipodLibrary>>(
      (ref) =>
          ref.watch(konnektedLibraryProvider).whenData(ClassipodLibrary.new),
    );

final classipodReloadProvider = Provider<VoidCallback>(
  (ref) =>
      () => ref.invalidate(songsProvider),
);

/// Separate seams keep platform playback, preferences and artwork out of tests.
final classipodPlayerStateProvider = Provider.autoDispose<PlayerState>(
  (ref) => ref.watch(playerProvider),
);

final classipodReduceMotionProvider = Provider.autoDispose<bool>(
  (ref) =>
      !ref.watch(appPreferencesProvider.select((p) => p.animationsEnabled)),
);

abstract interface class ClassipodPlayback {
  Future<void> play(Song song, List<Song> queue, PlaybackContext context);
  Future<void> togglePlayPause();
  Future<void> next();
  Future<void> previous();
  Future<void> playQueueIndex(int index);
}

/// Borrows the shell's service. Entering/exiting Classipod never initializes,
/// stops or disposes the playback runtime.
class PlayerServiceClassipodPlayback implements ClassipodPlayback {
  const PlayerServiceClassipodPlayback(this.service);

  final PlayerService service;

  @override
  Future<void> play(Song song, List<Song> queue, PlaybackContext context) =>
      service.play(song, playlist: queue, context: context);

  @override
  Future<void> togglePlayPause() => service.togglePlayPause();

  @override
  Future<void> next() => service.next();

  @override
  Future<void> previous() => service.previous();

  @override
  Future<void> playQueueIndex(int index) => service.playFromQueueIndex(index);
}

final classipodPlaybackProvider = Provider.autoDispose<ClassipodPlayback>(
  (ref) => PlayerServiceClassipodPlayback(ref.watch(playerServiceProvider)),
);

typedef ClassipodArtworkBuilder = Widget Function(Song song);

final classipodArtworkProvider = Provider<ClassipodArtworkBuilder>(
  (ref) =>
      (song) => CachedImageWidget(
        imagePath: song.albumArt,
        audioSourcePath: song.filePath,
        fit: BoxFit.cover,
        placeholder: const Center(child: Icon(Icons.album_outlined, size: 56)),
        errorWidget: const Center(child: Icon(Icons.album_outlined, size: 56)),
      ),
);

Song classipodAlbumArtwork(AlbumGroup album) => album.songs.firstWhere(
  (song) => song.albumArt?.isNotEmpty == true,
  orElse: () => album.songs.first,
);
