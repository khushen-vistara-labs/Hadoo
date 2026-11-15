import 'package:flick/models/playlist.dart';
import 'package:flick/models/song.dart';
import 'package:flick/services/playlist_service.dart';
import 'package:flick/services/online_playlist_reference.dart';
import 'package:flick/services/queue_pre_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Playlist _playlist({String? sourcePath}) => Playlist(
  id: 'p1',
  name: 'Test',
  createdAt: DateTime(2024),
  sourcePath: sourcePath,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'a Hadoo playlist preserves the order and identity of mixed sources',
    () async {
      final resolver = QueuePreResolver();
      addTearDown(resolver.reset);
      final songs = [
        for (final (sourceId, trackId) in [
          ('yt', 'abcdefghijk'),
          ('w-jiosaavn', 'song-123'),
          ('a-amazon', 'B000000000'),
        ])
          hadooPlaylistEntry(
            Song(
              id: 'temporary:$trackId',
              title: 'Song $trackId',
              artist: 'Artist',
              duration: const Duration(minutes: 3),
              fileType: 'ONLINE',
              filePath: 'https://media.example.com/signed?token=ephemeral',
              onlineRecording: (sourceId: sourceId, trackId: trackId),
            ),
            resolver: resolver,
          ),
      ];
      final service = PlaylistService();
      final playlist = await service.createPlaylist(
        'Mixed',
        initialSongs: songs.take(2).toList(),
      );
      expect(
        await service.addSongsToLocalPlaylist(playlist!.id, [
          songs[1],
          songs[2],
        ]),
        isTrue,
      );
      final saved = (await PlaylistService().getPlaylist(playlist.id))!;
      expect(saved.songIds, songs.map((song) => song.id));
      for (final entry in songs) {
        final snapshot = saved.songSnapshots[entry.id]!;
        final restored = restoreOnlinePlaylistSong(
          entry.id,
          snapshot,
          resolver: resolver,
        );
        expect(restored.onlineRecording, entry.onlineRecording);
        expect(restored.isPending, isTrue);
        expect(snapshot.filePath, isNull);
      }
    },
  );

  group('Playlist network source parsing', () {
    test('local playlists have no network identity', () {
      final playlist = _playlist();
      expect(playlist.isNetworkSource, isFalse);
      expect(playlist.networkServerId, isNull);
      expect(playlist.networkRemoteId, isNull);
    });

    test('parses serverId and remoteId from subsonic sourcePath', () {
      final playlist = _playlist(sourcePath: 'subsonic://7/pl-42');
      expect(playlist.isNetworkSource, isTrue);
      expect(playlist.networkServerId, 7);
      expect(playlist.networkRemoteId, 'pl-42');
    });

    test('remoteId may contain slashes', () {
      final playlist = _playlist(sourcePath: 'subsonic://7/a/b/c');
      expect(playlist.networkServerId, 7);
      expect(playlist.networkRemoteId, 'a/b/c');
    });

    test('non-subsonic sourcePaths stay local', () {
      final playlist = _playlist(sourcePath: 'content://documents/foo.m3u');
      expect(playlist.isNetworkSource, isFalse);
      expect(playlist.networkServerId, isNull);
    });
  });

  group('network playlist mirrors', () {
    test('upsertNetworkPlaylist creates then updates in place', () async {
      final service = PlaylistService();

      final created = await service.upsertNetworkPlaylist(
        serverId: 7,
        remoteId: 'pl-1',
        name: 'Driving',
        songIds: const ['a', 'b'],
      );
      expect(created.id, 'subsonic:7:pl-1');
      expect(created.sourcePath, 'subsonic://7/pl-1');
      expect(created.songIds, ['a', 'b']);

      await service.upsertNetworkPlaylist(
        serverId: 7,
        remoteId: 'pl-1',
        name: 'Driving v2',
        songIds: const ['a', 'b', 'c'],
      );

      final playlists = await service.getPlaylists();
      expect(playlists, hasLength(1));
      final updated = playlists.single;
      expect(updated.id, 'subsonic:7:pl-1');
      expect(updated.name, 'Driving v2');
      expect(updated.songIds, ['a', 'b', 'c']);
    });

    test('network playlist cover ID survives updates and reloads', () async {
      final service = PlaylistService();
      final initial = await service.upsertNetworkPlaylist(
        serverId: 7,
        remoteId: 'artwork',
        name: 'With art',
        coverArt: 'pl-cover-1',
      );
      expect(initial.coverArt, 'pl-cover-1');
      final readBack = PlaylistService();
      final persisted = await readBack.getPlaylist(initial.id);
      expect(persisted!.coverArt, 'pl-cover-1');

      final changed = await service.upsertNetworkPlaylist(
        serverId: 7,
        remoteId: 'artwork',
        name: 'New cover',
        coverArt: 'pl-cover-2',
      );
      expect(changed.coverArt, 'pl-cover-2');
      expect(Playlist.fromJson(changed.toJson()).coverArt, 'pl-cover-2');

      final removed = await service.upsertNetworkPlaylist(
        serverId: 7,
        remoteId: 'artwork',
        name: 'No cover',
      );
      expect(removed.coverArt, isNull);
    });

    test('mirrors survive a reload from prefs', () async {
      final service = PlaylistService();
      await service.upsertNetworkPlaylist(
        serverId: 7,
        remoteId: 'pl-1',
        name: 'Driving',
      );

      final reloaded = PlaylistService();
      final playlists = await reloaded.getPlaylists();
      expect(playlists, hasLength(1));
      expect(playlists.single.networkRemoteId, 'pl-1');
    });

    test('removeStaleNetworkPlaylists drops only stale mirrors', () async {
      final service = PlaylistService();
      await service.upsertNetworkPlaylist(
        serverId: 7,
        remoteId: 'keep',
        name: 'Keep',
      );
      await service.upsertNetworkPlaylist(
        serverId: 7,
        remoteId: 'stale',
        name: 'Stale',
      );
      await service.upsertNetworkPlaylist(
        serverId: 8,
        remoteId: 'other',
        name: 'Other server',
      );

      await service.removeStaleNetworkPlaylists('7', {'subsonic://7/keep'});

      final playlists = await service.getPlaylists();
      expect(playlists.map((p) => p.name), ['Keep', 'Other server']);
    });

    test('removeNetworkPlaylistsForServer purges the whole server', () async {
      final service = PlaylistService();
      await service.upsertNetworkPlaylist(
        serverId: 7,
        remoteId: 'a',
        name: 'A',
      );
      await service.upsertNetworkPlaylist(
        serverId: 7,
        remoteId: 'b',
        name: 'B',
      );
      await service.upsertNetworkPlaylist(
        serverId: 8,
        remoteId: 'c',
        name: 'C',
      );

      await service.removeNetworkPlaylistsForServer('7');

      final playlists = await service.getPlaylists();
      expect(playlists.map((p) => p.name), ['C']);
    });
  });

  group('bulk local playlist ordering', () {
    test(
      'saves one reordered list while preserving timestamps and snapshots',
      () async {
        final service = PlaylistService();
        final playlist = await service.createPlaylist('Order');
        await service.addSongToPlaylist(playlist!.id, 'a');
        await service.addSongToPlaylist(playlist.id, 'b');
        await service.addSongToPlaylist(playlist.id, 'c');
        final before = (await service.getPlaylist(playlist.id))!;

        expect(
          await service.setSongOrder(playlist.id, ['c', 'a', 'b']),
          isTrue,
        );
        final after = (await PlaylistService().getPlaylist(playlist.id))!;
        expect(after.songIds, ['c', 'a', 'b']);
        expect(after.songAddedAt, before.songAddedAt);
      },
    );

    test(
      'rejects omitted, new, or duplicated song IDs without losing tracks',
      () async {
        final service = PlaylistService();
        final playlist = await service.createPlaylist('Order guard');
        await service.addSongToPlaylist(playlist!.id, 'a');
        await service.addSongToPlaylist(playlist.id, 'b');

        expect(await service.setSongOrder(playlist.id, ['a']), isFalse);
        expect(await service.setSongOrder(playlist.id, ['b', 'c']), isFalse);
        expect(await service.setSongOrder(playlist.id, ['b', 'b']), isFalse);
        expect((await service.getPlaylist(playlist.id))!.songIds, ['a', 'b']);
      },
    );

    test('does not mutate synced server playlist mirrors', () async {
      final service = PlaylistService();
      final remote = await service.upsertNetworkPlaylist(
        serverId: 7,
        remoteId: 'remote',
        name: 'Remote',
        songIds: ['a', 'b'],
      );
      expect(await service.setSongOrder(remote.id, ['b', 'a']), isFalse);
      expect((await service.getPlaylist(remote.id))!.songIds, ['a', 'b']);
    });
  });

  group('playlist-only song metadata', () {
    const onlineSong = Song(
      id: 'online:stream-1',
      title: 'Stream title',
      artist: 'Stream artist',
      album: 'Album',
      duration: Duration(minutes: 3, seconds: 15),
      fileType: 'ONLINE',
      sourcePackage: Song.pendingSourcePackage,
    );

    test(
      'unscanned online track persists and survives service reload',
      () async {
        final service = PlaylistService();
        final playlist = await service.createPlaylist('Streams');
        expect(playlist, isNotNull);
        expect(
          await service.addSongToPlaylist(
            playlist!.id,
            onlineSong.id,
            song: onlineSong,
          ),
          isTrue,
        );

        final reopened = await PlaylistService().getPlaylist(playlist.id);
        expect(reopened!.songIds, [onlineSong.id]);
        final snapshot = reopened.songSnapshots[onlineSong.id]!;
        expect(snapshot.toSong(onlineSong.id).title, 'Stream title');
        expect(snapshot.toSong(onlineSong.id).artist, 'Stream artist');
        expect(snapshot.toSong(onlineSong.id).isPending, isTrue);
        expect(
          snapshot.toSong(onlineSong.id).duration,
          const Duration(minutes: 3, seconds: 15),
        );
      },
    );

    test(
      'existing entry can be repaired with newly supplied metadata',
      () async {
        final service = PlaylistService();
        final playlist = await service.createPlaylist('Existing');
        await service.addSongToPlaylist(playlist!.id, onlineSong.id);
        expect(
          (await service.getPlaylist(playlist.id))!.songSnapshots,
          isEmpty,
        );
        await service.addSongToPlaylist(
          playlist.id,
          onlineSong.id,
          song: onlineSong,
        );
        final fixed = await PlaylistService().getPlaylist(playlist.id);
        expect(fixed!.songIds, [onlineSong.id]);
        expect(fixed.songSnapshots[onlineSong.id]!.title, 'Stream title');
      },
    );

    test('removing an entry also drops its saved metadata', () async {
      final service = PlaylistService();
      final playlist = await service.createPlaylist('Remove');
      await service.addSongToPlaylist(
        playlist!.id,
        onlineSong.id,
        song: onlineSong,
      );
      await service.removeSongFromPlaylist(playlist.id, onlineSong.id);
      final updated = await PlaylistService().getPlaylist(playlist.id);
      expect(updated!.songIds, isEmpty);
      expect(updated.songSnapshots, isEmpty);
    });

    test('temporary signed streaming URL is not persisted', () {
      const stream = Song(
        id: 'stream',
        title: 'Signed',
        artist: 'Online',
        duration: Duration(minutes: 2),
        fileType: 'FLAC',
        filePath: 'https://cdn.example/song.flac?token=secret',
      );
      final stored = PlaylistSongSnapshot.fromSong(stream);
      expect(stored.filePath, isNull);
      expect(stored.sourcePackage, Song.pendingSourcePackage);
      expect(stored.toJson().toString(), isNot(contains('secret')));
    });

    test('legacy playlists without metadata still deserialize', () {
      final old = Playlist.fromJson({
        'id': 'old',
        'name': 'Legacy',
        'songIds': ['id-1'],
        'createdAt': DateTime(2024).toIso8601String(),
      });
      expect(old.songIds, ['id-1']);
      expect(old.songSnapshots, isEmpty);
    });
  });

  group('song added-at timestamps', () {
    test('addSongToPlaylist records the add timestamp', () async {
      final service = PlaylistService();
      final playlist = await service.createPlaylist('Test');
      expect(playlist, isNotNull);

      await service.addSongToPlaylist(playlist!.id, 'song-1');
      await service.addSongToPlaylist(playlist.id, 'song-2');

      final updated = await service.getPlaylist(playlist.id);
      expect(updated!.songIds, ['song-1', 'song-2']);
      expect(updated.songAddedAt['song-1'], isNotNull);
      expect(updated.songAddedAt['song-2'], isNotNull);
      expect(
        updated.songAddedAt['song-2']!.isAfter(updated.songAddedAt['song-1']!),
        isTrue,
      );
    });

    test('timestamps are pruned when a song is removed', () async {
      final service = PlaylistService();
      final playlist = await service.createPlaylist('Test');
      await service.addSongToPlaylist(playlist!.id, 'song-1');
      await service.addSongToPlaylist(playlist.id, 'song-2');

      await service.removeSongFromPlaylist(playlist.id, 'song-1');

      final updated = await service.getPlaylist(playlist.id);
      expect(updated!.songIds, ['song-2']);
      expect(updated.songAddedAt.containsKey('song-1'), isFalse);
      expect(updated.songAddedAt.containsKey('song-2'), isTrue);
    });

    test('timestamps survive a reload from prefs', () async {
      final service = PlaylistService();
      final playlist = await service.createPlaylist('Test');
      await service.addSongToPlaylist(playlist!.id, 'song-1');
      final addedAt = (await service.getPlaylist(playlist.id))!
          .songAddedAt['song-1'];

      final reloaded = PlaylistService();
      final updated = await reloaded.getPlaylist(playlist.id);
      expect(updated!.songAddedAt['song-1'], addedAt);
    });

    test('legacy playlists without timestamps stay readable', () async {
      final legacy = Playlist.fromJson({
        'id': 'p1',
        'name': 'Legacy',
        'songIds': ['song-1'],
        'createdAt': DateTime(2024).toIso8601String(),
      });
      expect(legacy.songAddedAt, isEmpty);
      expect(legacy.songIds, ['song-1']);
    });
  });
}
