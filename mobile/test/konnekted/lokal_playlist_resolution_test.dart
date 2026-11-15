import 'package:flick/features/konnekted/library/lokal_playlists.dart';
import 'package:flick/models/playlist.dart';
import 'package:flick/models/song.dart';
import 'package:flick/services/link/library_song_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('playlist keeps original IDs but displays phone copy of desktop song', () {
    const phone = Song(
      id: 'phone',
      title: 'Same track',
      artist: 'Artist',
      duration: Duration(minutes: 3),
      fileType: 'FLAC',
      filePath: '/music/track.flac',
    );
    const desktop = Song(
      id: 'desktop',
      title: 'Same track',
      artist: 'Artist',
      duration: Duration(minutes: 3),
      fileType: 'FLAC',
      filePath: 'lokal://1/track',
      sourceType: 'lokal',
    );
    final index = preferredLibrarySongIndex([desktop, phone]);
    final playlist = Playlist(
      id: 'p',
      name: 'Saved',
      songIds: const ['desktop', 'phone'],
      createdAt: DateTime(2024),
    );

    expect(index.visible, [phone]);
    expect(playlist.songIds, ['desktop', 'phone']);
    expect(lokalPlaylistSongs(playlist, index.byId), [phone, phone]);
    expect(lokalPlaylistSong(playlist, 'desktop', index.byId), same(phone));
  });

  test('playlist collage samples at most 64 tracks rather than full queue', () {
    final ids = List.generate(10000, (i) => 'song-$i');
    final byId = {
      for (var i = 0; i < 64; i++)
        'song-$i': Song(
          id: 'song-$i',
          title: 'Track $i',
          artist: 'Artist',
          album: 'Album ${i ~/ 8}',
          duration: const Duration(minutes: 3),
          fileType: 'FLAC',
        ),
    };
    final playlist = Playlist(
      id: 'large',
      name: 'Large',
      songIds: ids,
      createdAt: DateTime(2026),
    );
    final coverSongs = lokalPlaylistCoverSongs(playlist, byId);
    expect(coverSongs.map((song) => song.id), ['song-0', 'song-8', 'song-16', 'song-24']);
    expect(lokalPlaylistSongs(playlist, byId).length, 64);
    expect(playlist.songIds.length, 10000);
  });

  test('unscanned online entries use saved metadata and preserve order', () {
    const online = Song(
      id: 'pending-track',
      title: 'Online track',
      artist: 'Online artist',
      duration: Duration(minutes: 4),
      fileType: 'ONLINE',
      sourcePackage: Song.pendingSourcePackage,
    );
    const local = Song(
      id: 'library-track',
      title: 'Library track',
      artist: 'Local artist',
      duration: Duration(minutes: 2),
      fileType: 'FLAC',
    );
    final playlist = Playlist(
      id: 'p',
      name: 'Mixed',
      songIds: const ['pending-track', 'gone', 'library-track'],
      songSnapshots: {
        online.id: PlaylistSongSnapshot.fromSong(online),
      },
      createdAt: DateTime(2024),
    );
    final restored = Playlist.fromJson(playlist.toJson());
    final tracks = lokalPlaylistSongs(restored, {local.id: local});

    expect(tracks.map((s) => s.title), ['Online track', 'Library track']);
    expect(tracks.first.isPending, isTrue);
    expect(lokalPlaylistSong(restored, 'gone', {local.id: local}), isNull);
    expect(restored.songIds, ['pending-track', 'gone', 'library-track']);
  });
}
