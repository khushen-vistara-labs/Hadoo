import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../features/discovery/lastfm_discovery.dart';
import '../features/discovery/discovery_models.dart';
import '../features/konnekted/konnekted_discovery.dart'
    show findDiscoverySong, playOnlineTrack;
import 'player_service.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import 'queue_pre_resolver.dart';

/// A local playlist saves a stable, portable *catalogue reference*, never
/// an expiring audio URL, a cache file, or a resolver closure.
const onlinePlaylistPrefix = 'pending:playlist:';

String? _catalogueVideoId(String? id) {
  if (id == null) return null;
  final match = RegExp(r'^(?:yt:)?([A-Za-z0-9_-]{11})$').firstMatch(id);
  return match?.group(1);
}

/// The library owns local and network files. Convert online streams into
/// catalogue references so saving never depends on a temporary audio URL.
Song hadooPlaylistEntry(Song song, {QueuePreResolver? resolver}) {
  if (song.id.startsWith(onlinePlaylistPrefix) || song.isNetworkSource) {
    return song;
  }
  if (song.onlineRecording != null ||
      song.isPending ||
      (song.sourcePackage?.startsWith('konnekted.') ?? false)) {
    return stableOnlinePlaylistSong(song, resolver: resolver);
  }
  return song;
}

/// Convert streamed or pending Flow items into a rehydratable playlist entry.
/// The hash is a cross-platform stable recording identity, independent of
/// ephemeral discovery cache IDs or the chosen playback extension.
Song stableOnlinePlaylistSong(Song song, {QueuePreResolver? resolver}) {
  final origin = song.onlineRecording;
  final recording =
      origin != null &&
          RegExp(r'^(?:yt|mono|sc|[aw]-[A-Za-z0-9_.:-]{1,249})$')
              .hasMatch(origin.sourceId) &&
          RegExp(r'^[A-Za-z0-9_.:/+-]{1,256}$').hasMatch(origin.trackId) &&
          !origin.trackId.contains('://')
      ? origin
      : null;
  final normalized = recording == null
      ? [
          song.artist.trim().toLowerCase(),
          song.title.trim().toLowerCase(),
          song.album?.trim().toLowerCase() ?? '',
        ].join('\u001f')
      : jsonEncode([recording.sourceId, recording.trackId]);
  final stable = sha256
      .convert(utf8.encode(normalized))
      .toString()
      .substring(0, 24);
  final id = '$onlinePlaylistPrefix$stable';
  return _onlinePending(
    id: id,
    title: song.title,
    artist: song.artist,
    album: song.album,
    artwork: song.albumArt,
    duration: song.duration,
    videoId: recording == null ? _catalogueVideoId(song.remoteId) : null,
    recording: recording,
    resolver: resolver,
  );
}

/// Re-register a resolver whenever a stored playlist is opened. A snapshot
/// alone would be a visible but permanently unplayable pending Song.
Song restoreOnlinePlaylistSong(
  String id,
  PlaylistSongSnapshot snapshot, {
  QueuePreResolver? resolver,
}) => _onlinePending(
  id: id,
  title: snapshot.title,
  artist: snapshot.artist,
  album: snapshot.album,
  artwork: snapshot.albumArt,
  duration: Duration(milliseconds: snapshot.durationMs),
  videoId: _catalogueVideoId(snapshot.remoteId),
  recording: snapshot.onlineRecording,
  resolver: resolver,
);

Song _onlinePending({
  required String id,
  required String title,
  required String artist,
  String? album,
  String? artwork,
  required Duration duration,
  String? videoId,
  ({String sourceId, String trackId})? recording,
  QueuePreResolver? resolver,
}) {
  if (!id.startsWith('pending:')) {
    throw ArgumentError.value(id, 'id', 'Expected pending track identity');
  }
  final record = LokalDiscoveryTrack(
    title: title,
    artist: artist,
    album: album ?? '',
    artworkUrl: artwork ?? '',
    videoId: videoId,
    duration: duration,
  );
  final queueResolver = resolver ?? QueuePreResolver.shared;
  final provider = recording;
  final song = queueResolver.pending(
    key: id.substring('pending:'.length),
    title: title,
    artist: artist,
    album: album,
    artwork: artwork,
    duration: duration,
    resolve: ({onStatus, cancel}) => provider == null
        ? findDiscoverySong(
            record,
            onStatus: onStatus,
            cancel: cancel,
            additionalProtectedPaths: () => queueResolver.resolvedPaths,
          )
        : playOnlineTrack(
            provider.sourceId,
            DiscoveryTrack(
              id: provider.trackId,
              title: title,
              artist: artist,
              album: album,
              artwork: artwork,
              duration: duration > Duration.zero ? duration : null,
              source: switch (provider.sourceId) {
                'yt' => DiscoverySource.youtubeMusic,
                'mono' => DiscoverySource.monochrome,
                'sc' => DiscoverySource.soundCloud,
                _ => DiscoverySource.addon,
              },
            ),
            onStatus: onStatus,
            cancel: cancel,
            additionalProtectedPaths: () => queueResolver.resolvedPaths,
            refreshCatalogueTrack:
                provider.sourceId.startsWith('a-') ||
                provider.sourceId.startsWith('w-'),
            mayRequestVerification: () =>
                PlayerService().currentSongNotifier.value?.id == id,
          ),
  );
  return song.copyWith(
    onlineRecording: provider,
    remoteId: switch (provider) {
      (sourceId: 'yt', :final trackId) => 'yt:$trackId',
      null when videoId != null => 'yt:$videoId',
      _ => null,
    },
  );
}
