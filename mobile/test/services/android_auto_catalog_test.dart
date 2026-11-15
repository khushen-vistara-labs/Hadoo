import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flick/data/repositories/song_repository.dart';
import 'package:flick/models/playback_context.dart';
import 'package:flick/models/song.dart';
import 'package:flick/services/android_auto_catalog.dart';
import 'package:flick/services/favorites_service.dart';
import 'package:flick/services/player_service.dart';
import 'package:flick/services/youtube_playlist_catalog.dart';
import 'package:flick/features/discovery/lastfm_discovery.dart';

const _a = Song(
  id: 'local:one/track',
  title: 'Autumn',
  artist: 'Artist A',
  album: 'First Album',
  duration: Duration(minutes: 3),
  fileType: 'FLAC',
);
const _b = Song(
  id: 'local:two',
  title: 'Blue Sky',
  artist: 'Artist B',
  album: 'First Album',
  duration: Duration(minutes: 4),
  fileType: 'MP3',
);

class _Songs implements SongRepository {
  _Songs([this.items = const [_a, _b]]);
  final List<Song> items;
  @override
  Future<List<Song>> getAllSongs() async => items;

  @override
  Future<Map<String, List<Song>>> getSongsByAlbum() async => {
    'First Album': [_a, _b],
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Likes implements FavoritesService {
  @override
  Future<List<Song>> getFavorites() async => [_b];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Playlists implements YoutubePlaylistCatalog {
  @override
  Future<List<LokalDiscoveryMix>> playlists() async => [
    const LokalDiscoveryMix(id: 'playlist/1', title: 'Road Trip'),
  ];
  @override
  Future<List<Song>> songs(String id, List<Song> library) async =>
      id == 'playlist/1' ? [_b, _a] : [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Player implements PlayerService {
  Song? selected;
  List<Song>? queued;
  PlaybackContext? context;

  @override
  Future<void> play(
    Song song, {
    List<Song>? playlist,
    int? playlistIndex,
    PlaybackContext? context,
  }) async {
    selected = song;
    queued = playlist;
    this.context = context;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AndroidAutoCatalog catalog;
  late _Player player;

  setUp(() {
    player = _Player();
    catalog = AndroidAutoCatalog(
      songs: _Songs(),
      favorites: _Likes(),
      playlists: _Playlists(),
      player: player,
    );
  });

  test('car root exposes four browsable sections', () async {
    final items = await catalog.browse(AndroidAutoCatalog.root);
    expect(items.map((e) => e['id']), [
      AndroidAutoCatalog.downloads,
      AndroidAutoCatalog.library,
      AndroidAutoCatalog.likes,
      AndroidAutoCatalog.playlists,
    ]);
    expect(items.every((e) => e['playable'] == false), isTrue);
  });

  test('song IDs are opaque and preserve path separators', () async {
    final buckets = await catalog.browse(AndroidAutoCatalog.songs);
    expect(buckets.map((e) => e['title']), containsAll(['A', 'B']));
    final songs = await catalog.browse('lokal/songs/A');
    expect(songs.single['playable'], isTrue);
    expect(songs.single['id'], isNot(contains('local:one/track')));
    expect(await catalog.playMediaId(songs.single['id'] as String), isTrue);
    expect(player.selected?.id, _a.id);
    expect(player.queued, hasLength(2));
  });

  test('liked songs are browsable and playable', () async {
    final liked = await catalog.browse(AndroidAutoCatalog.likes);
    expect(liked.single['title'], 'Blue Sky');
    expect(await catalog.playMediaId(liked.single['id'] as String), isTrue);
    expect(player.selected?.id, _b.id);
  });

  test(
    'playlist selections preserve playlist queue order and context',
    () async {
      final folders = await catalog.browse(AndroidAutoCatalog.playlists);
      expect(folders.single['title'], 'Road Trip');
      final children = await catalog.browse(folders.single['id'] as String);
      expect(children.map((e) => e['title']), ['Blue Sky', 'Autumn']);
      expect(await catalog.playMediaId(children.last['id'] as String), isTrue);
      expect(player.queued?.map((s) => s.id), [_b.id, _a.id]);
      expect(player.context?.source, PlaybackSource.playlist);
      expect(player.context?.sourceId, 'playlist/1');
    },
  );

  test('album browsing preserves source context', () async {
    final albums = await catalog.browse(AndroidAutoCatalog.albums);
    expect(albums.single['title'], 'First Album');
    final songs = await catalog.browse(albums.single['id'] as String);
    expect(songs.map((e) => e['title']), ['Autumn', 'Blue Sky']);
    expect(await catalog.playMediaId(songs.first['id'] as String), isTrue);
    expect(player.context?.source, PlaybackSource.album);
    expect(player.context?.sourceId, 'First Album');
  });

  test('car browser search returns playable results', () async {
    final results = await catalog.search('artist b');
    expect(results.single['title'], 'Blue Sky');
    expect(await catalog.playMediaId(results.single['id'] as String), isTrue);
    expect(player.selected?.id, _b.id);
    expect(await catalog.search('no match'), isEmpty);
  });

  test('car voice search queues matching library titles', () async {
    expect(await catalog.playSearch('BLUE'), isTrue);
    expect(player.selected?.id, _b.id);
    expect(await catalog.playSearch('missing title'), isFalse);
    expect(await catalog.playMediaId('lokal/track/not-valid'), isFalse);
  });

  test(
    'offline car selection excludes missing files and keeps the offline queue',
    () async {
      final temp = await Directory.systemTemp.createTemp('hadoo-car-');
      addTearDown(() => temp.delete(recursive: true));
      final file = await File('${temp.path}/saved.mp3').writeAsBytes([1, 2, 3]);
      final saved = _a.copyWith(filePath: file.path);
      final deleted = _b.copyWith(filePath: '${temp.path}/deleted.mp3');
      final offline = AndroidAutoCatalog(
        songs: _Songs([saved, deleted, _b]),
        favorites: _Likes(),
        playlists: _Playlists(),
        player: player,
      );
      final entries = await offline.browse(AndroidAutoCatalog.downloads);
      expect(entries.map((item) => item['title']), ['Autumn']);
      expect(await offline.playMediaId(entries.single['id'] as String), isTrue);
      expect(player.queued?.map((song) => song.id), [saved.id]);
      await file.delete();
      expect(
        await offline.playMediaId(entries.single['id'] as String),
        isFalse,
      );
    },
  );

  test(
    'large car collections remain reachable through bounded pages',
    () async {
      final songs = [
        for (var i = 0; i < 205; i++) _a.copyWith(id: '$i', title: 'Autumn $i'),
      ];
      final large = AndroidAutoCatalog(
        songs: _Songs(songs),
        favorites: _Likes(),
        playlists: _Playlists(),
        player: player,
      );
      final pages = await large.browse('lokal/songs/A');
      expect(pages, hasLength(3));
      final tracks = <Map<String, Object?>>[];
      for (final page in pages) {
        final children = await large.browse(page['id'] as String);
        expect(children.length, lessThanOrEqualTo(AndroidAutoCatalog.pageSize));
        tracks.addAll(children);
      }
      expect(tracks, hasLength(205));
      expect(tracks.map((track) => track['id']).toSet(), hasLength(205));
      expect(await large.playMediaId(tracks.last['id'] as String), isTrue);
      expect(player.queued, hasLength(205));
      expect(await large.browse('lokal/page/bad/-1'), isEmpty);
    },
  );
}
