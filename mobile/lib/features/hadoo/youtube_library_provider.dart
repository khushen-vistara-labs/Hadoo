import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flick/features/discovery/lastfm_discovery.dart';
import 'package:flick/features/discovery/youtube_music_account.dart';
import 'package:flick/features/discovery/youtube_music_playlist_cache.dart';
import 'package:flick/features/discovery/youtube_music_playlist_writes.dart';
import 'package:flick/features/konnekted/konnekted_discovery.dart';
import 'package:flick/models/song.dart';

final youtubePlaylistCacheProvider = Provider(
  (ref) => YoutubeMusicPlaylistCache.instance,
);

class YoutubeLibraryState {
  const YoutubeLibraryState({
    this.account,
    this.playlists = const [],
    this.refreshing = false,
    this.error,
  });
  final String? account;
  final List<LokalDiscoveryMix> playlists;
  final bool refreshing;
  final String? error;
}

String youtubeLibraryError(Object error) => switch (error) {
  YoutubeMusicSignedOut() => 'Your YouTube session expired. Sign in again in Settings → Data → Accounts.',
  LokalDiscoveryFailure(:final message) => message,
  _ => 'Could not reach YouTube. Check your connection and refresh before retrying.',
};

/// Exact recording identity only. Never silently substitute a title match.
String? youtubeVideoIdForSong(Song song) {
  final raw = song.remoteId;
  if (raw == null) return null;
  final tagged = RegExp(r'^yt:([A-Za-z0-9_-]{11})$').firstMatch(raw);
  if (tagged != null) return tagged.group(1);
  if (song.sourceDisplayName == 'YouTube Music' &&
      RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(raw))
    return raw;
  return null;
}

List<String> youtubeIdsForSongs(List<Song> songs) => [
  for (final song in songs)
    youtubeVideoIdForSong(song) ??
        (throw const LokalDiscoveryFailure(
          'Add this recording from YouTube search so its exact YouTube track is known.',
        )),
];

final youtubeLibraryProvider =
    AsyncNotifierProvider<YoutubeLibraryNotifier, YoutubeLibraryState>(
      YoutubeLibraryNotifier.new,
    );

class YoutubePlaylistAddResult {
  const YoutubePlaylistAddResult({required this.added, required this.skipped});
  final int added;
  final int skipped;
  String get message => added == 0
      ? (skipped == 1
            ? 'This song is already in this YouTube playlist.'
            : 'These songs are already in this YouTube playlist.')
      : skipped == 0
      ? 'Saved to your YouTube playlist.'
      : 'Added $added; skipped $skipped already in this YouTube playlist.';
}

/// Remote playlists are authoritative. Disk stores a read cache, never an
/// independent playlist or an offline write queue. Writes are not retried.
class YoutubeLibraryNotifier extends AsyncNotifier<YoutubeLibraryState> {
  String? _account;
  int _revision = 0;
  bool _writing = false;

  @override
  Future<YoutubeLibraryState> build() async {
    final api = ref.watch(konnektedYoutubeMusicAccountProvider);
    final key = api?.session.accountKey;
    _account = key;
    final revision = ++_revision;
    if (key == null || api == null) return const YoutubeLibraryState();
    final cache = ref.read(youtubePlaylistCacheProvider);
    final saved = await cache.playlists(key);
    if (saved != null) {
      unawaited(
        Future<void>.delayed(Duration.zero, () async {
          if (_current(key, revision)) await refresh();
        }),
      );
      return YoutubeLibraryState(account: key, playlists: saved);
    }
    try {
      final playlists = await cache.refreshLibrary(api);
      return YoutubeLibraryState(account: key, playlists: playlists);
    } catch (error) {
      return YoutubeLibraryState(
        account: key,
        error: youtubeLibraryError(error),
      );
    }
  }

  bool _current(String account, int revision) =>
      ref.mounted &&
      _account == account &&
      revision == _revision &&
      ref.read(konnektedYoutubeMusicAccountProvider)?.session.accountKey ==
          account;

  Future<void> refresh() async {
    final api = ref.read(konnektedYoutubeMusicAccountProvider);
    if (api == null || _writing) return;
    final key = api.session.accountKey;
    final revision = ++_revision;
    final previous = state.value?.account == key
        ? state.value!.playlists
        : <LokalDiscoveryMix>[];
    state = AsyncData(
      YoutubeLibraryState(account: key, playlists: previous, refreshing: true),
    );
    try {
      final playlists = await ref
          .read(youtubePlaylistCacheProvider)
          .refreshLibrary(api);
      if (_current(key, revision))
        state = AsyncData(
          YoutubeLibraryState(account: key, playlists: playlists),
        );
    } catch (error) {
      if (_current(key, revision))
        state = AsyncData(
          YoutubeLibraryState(
            account: key,
            playlists: previous,
            error: youtubeLibraryError(error),
          ),
        );
    }
  }

  Future<T> _write<T>(
    Future<T> Function(YoutubeMusicPlaylistWrites writes) operation,
    List<LokalDiscoveryMix> Function(List<LokalDiscoveryMix> items, T result)
    changed, {
    String? playlistId,
  }) async {
    if (_writing)
      throw const LokalDiscoveryFailure(
        'Wait for the current YouTube change to finish.',
      );
    final api = ref.read(konnektedYoutubeMusicAccountProvider);
    if (api == null)
      throw const YoutubeMusicSignedOut(
        'Sign in to YouTube before changing playlists.',
      );
    final key = api.session.accountKey;
    final revision = ++_revision; // retires any in-flight read
    _writing = true;
    try {
      final result = await operation(YoutubeMusicPlaylistWrites(api));
      if (!_current(key, revision))
        throw const LokalDiscoveryFailure(
          'The YouTube account changed. Refresh its library to check the completed change.',
        );
      final current = state.value?.account == key
          ? state.value!.playlists
          : <LokalDiscoveryMix>[];
      final updated = changed(current, result);
      state = AsyncData(YoutubeLibraryState(account: key, playlists: updated));
      // A cache-storage failure must not report a confirmed server write as
      // failed and invite a duplicate create/add operation.
      try {
        final cache = ref.read(youtubePlaylistCacheProvider);
        await cache.invalidate(key, playlistId: playlistId);
        await cache.storePlaylists(key, updated);
      } catch (_) {
        /* The server change already succeeded. */
      }
      if (playlistId != null)
        ref.invalidate(
          youtubePlaylistDetailsProvider((account: key, id: playlistId)),
        );
      return result;
    } finally {
      _writing = false;
    }
  }

  Future<LokalDiscoveryMix> create(
    String name, {
    List<Song> songs = const [],
  }) async {
    final title = YoutubeMusicPlaylistWrites.title(name);
    final ids = youtubeIdsForSongs(songs);
    final id = await _write(
      (writes) => writes.create(title, tracks: ids),
      (items, id) => [
        LokalDiscoveryMix(id: id, title: title),
        ...items.where((p) => p.id != id),
      ],
    );
    return LokalDiscoveryMix(id: id, title: title);
  }

  Future<YoutubePlaylistAddResult> add(
    String id,
    List<Song> songs,
  ) => _write<YoutubePlaylistAddResult>(
    (writes) async {
      YoutubeMusicPlaylistWrites.playlistId(id);
      final ids = YoutubeMusicPlaylistWrites.videoIds(
        youtubeIdsForSongs(songs),
      );
      if (ids.isEmpty)
        throw const LokalDiscoveryFailure('Choose a YouTube track first.');
      // Always read the server: the picker cache may predate another device's
      // edit. No offline fallback can establish whether a track is present.
      final details = await writes.account.libraryPlaylistDetails(id);
      if (ref.read(konnektedYoutubeMusicAccountProvider)?.session.accountKey !=
          writes.account.session.accountKey) {
        throw const LokalDiscoveryFailure(
          'The YouTube account changed. Reopen its playlist before adding songs.',
        );
      }
      final present = details.tracks.map((track) => track.videoId).toSet();
      final fresh = ids.where((video) => !present.contains(video)).toList();
      // Keep YouTube's own duplicate protection enabled to cover concurrent
      // edits and playlists larger than the metadata display limit.
      if (fresh.isNotEmpty) await writes.add(id, fresh);
      return YoutubePlaylistAddResult(
        added: fresh.length,
        skipped: ids.length - fresh.length,
      );
    },
    (items, _) => items,
    playlistId: id,
  );

  Future<void> rename(String id, String title) => _write<void>(
    (writes) => writes.rename(id, title),
    (items, _) => [
      for (final p in items)
        p.id == id
            ? LokalDiscoveryMix(
                id: id,
                title: title.trim(),
                author: p.author,
                artworkUrl: p.artworkUrl,
              )
            : p,
    ],
    playlistId: id,
  );

  Future<void> remove(String id, LokalDiscoveryTrack track) => _write<void>(
    (writes) => writes.remove(id, track),
    (items, _) => items,
    playlistId: id,
  );

  Future<void> delete(String id) => _write<void>(
    (writes) => writes.delete(id),
    (items, _) => items.where((p) => p.id != id).toList(),
    playlistId: id,
  );
}

typedef YoutubePlaylistKey = ({String account, String id});
final youtubePlaylistDetailsProvider = FutureProvider.autoDispose
    .family<YoutubeMusicPlaylistDetails, YoutubePlaylistKey>((ref, key) async {
      final api = ref.watch(konnektedYoutubeMusicAccountProvider);
      if (api == null || api.session.accountKey != key.account)
        throw const YoutubeMusicSignedOut();
      final cache = ref.read(youtubePlaylistCacheProvider);
      try {
        final details = await api.libraryPlaylistDetails(key.id);
        try {
          await cache.storeTracks(key.account, key.id, details.tracks);
        } catch (_) {}
        return details;
      } catch (error) {
        final saved = await cache.tracks(key.account, key.id);
        if (saved == null) rethrow;
        return YoutubeMusicPlaylistDetails(
          tracks: saved,
          editable: false,
          loadError: youtubeLibraryError(error),
        );
      }
    });

/// Home always follows the signed-in YouTube account, independent of optional
/// recommendation-provider preferences elsewhere in the app.
final hadooYoutubeHomeProvider =
    FutureProvider<({String account, LokalDiscovery data})?>((ref) async {
      final api = ref.watch(konnektedYoutubeMusicAccountProvider);
      if (api == null) return null;
      final account = api.session.accountKey;
      final data = await loadYoutubeMusicDiscovery(api, force: true);
      return (account: account, data: data);
    });
