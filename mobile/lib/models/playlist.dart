import 'package:flick/models/song.dart';

class Playlist {
  /// URI scheme used in [sourcePath] for playlists mirrored from a Subsonic
  /// server: `subsonic://<serverId>/<remotePlaylistId>`.
  static const String networkSourceScheme = 'subsonic';

  final String id;
  final String name;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? sourcePath;

  /// Opaque coverArt ID supplied by the server for network playlists.
  /// Stored separately from song artwork; local playlists leave it null.
  final String? coverArt;

  /// Timestamp of when each song was added to this playlist, keyed by song id.
  /// Songs without an entry (legacy playlists, imported lists) fall back to
  /// their position in [songIds] when sorting by "Date Added".
  final Map<String, DateTime> songAddedAt;

  /// Metadata for entries added from online search/queues that have not
  /// entered the scanned song library. Do not persist signed streaming URLs.
  /// Old playlists without this field continue to load unchanged.
  final Map<String, PlaylistSongSnapshot> songSnapshots;

  /// True when this playlist is a mirror of a server-side (Subsonic) playlist.
  bool get isNetworkSource {
    final path = sourcePath;
    return path != null && path.startsWith('$networkSourceScheme://');
  }

  /// [NetworkServerEntity.id] of the owning server, null for local playlists.
  int? get networkServerId {
    final path = sourcePath;
    if (path == null) return null;
    final rest = path.startsWith('$networkSourceScheme://')
        ? path.substring('$networkSourceScheme://'.length)
        : '';
    final slash = rest.indexOf('/');
    return int.tryParse(slash == -1 ? rest : rest.substring(0, slash));
  }

  /// The server-assigned playlist id, null for local playlists.
  String? get networkRemoteId {
    final path = sourcePath;
    if (path == null) return null;
    final rest = path.startsWith('$networkSourceScheme://')
        ? path.substring('$networkSourceScheme://'.length)
        : '';
    final slash = rest.indexOf('/');
    if (slash == -1 || slash == rest.length - 1) return null;
    return rest.substring(slash + 1);
  }

  const Playlist({
    required this.id,
    required this.name,
    this.songIds = const [],
    required this.createdAt,
    this.updatedAt,
    this.sourcePath,
    this.coverArt,
    this.songAddedAt = const {},
    this.songSnapshots = const {},
  });

  Playlist copyWith({
    String? id,
    String? name,
    List<String>? songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sourcePath,
    String? coverArt,
    bool clearCoverArt = false,
    Map<String, DateTime>? songAddedAt,
    Map<String, PlaylistSongSnapshot>? songSnapshots,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sourcePath: sourcePath ?? this.sourcePath,
      coverArt: clearCoverArt ? null : (coverArt ?? this.coverArt),
      songAddedAt: songAddedAt ?? this.songAddedAt,
      songSnapshots: songSnapshots ?? this.songSnapshots,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songIds': songIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'sourcePath': sourcePath,
      'coverArt': coverArt,
      'songAddedAt': {
        for (final entry in songAddedAt.entries)
          entry.key: entry.value.toIso8601String(),
      },
      'songSnapshots': {
        for (final entry in songSnapshots.entries)
          entry.key: entry.value.toJson(),
      },
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final rawAddedAt = json['songAddedAt'] as Map<String, dynamic>? ?? {};
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      songIds: (json['songIds'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      sourcePath: json['sourcePath'] as String?,
      coverArt: json['coverArt'] as String?,
      songAddedAt: {
        for (final entry in rawAddedAt.entries)
          entry.key: DateTime.parse(entry.value as String),
      },
      songSnapshots: {
        for (final entry
            in (json['songSnapshots'] as Map<String, dynamic>? ?? {}).entries)
          if (entry.value is Map)
            entry.key: PlaylistSongSnapshot.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            ),
      },
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Playlist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Playlist(id: $id, name: $name, songCount: ${songIds.length})';
  }
}

/// Small, durable playlist-only metadata record. Online titles should not
/// disappear simply because they were added before being downloaded/scanned.
/// A live library row always wins over a saved snapshot.
class PlaylistSongSnapshot {
  const PlaylistSongSnapshot({
    required this.title,
    required this.artist,
    required this.durationMs,
    required this.fileType,
    this.album,
    this.albumArt,
    this.filePath,
    this.sourceType,
    this.sourcePackage,
    this.remoteId,
    this.remoteServerId,
    this.onlineRecording,
  });

  final String title;
  final String artist;
  final int durationMs;
  final String fileType;
  final String? album;
  final String? albumArt;
  final String? filePath;
  final String? sourceType;
  final String? sourcePackage;
  final String? remoteId;
  final int? remoteServerId;
  final ({String sourceId, String trackId})? onlineRecording;

  factory PlaylistSongSnapshot.fromSong(Song song) {
    final path = song.filePath;
    final transientStream =
        path != null &&
        (path.startsWith('https://') || path.startsWith('http://'));
    return PlaylistSongSnapshot(
      title: song.title,
      artist: song.artist,
      durationMs: song.duration.inMilliseconds,
      fileType: song.fileType,
      album: song.album,
      albumArt: song.albumArt,
      // Authenticated/signed audio URLs expire and must not be saved.
      filePath: transientStream ? null : path,
      sourceType: song.sourceType,
      sourcePackage: transientStream && song.sourcePackage == null
          ? Song.pendingSourcePackage
          : song.sourcePackage,
      remoteId: song.remoteId,
      remoteServerId: song.remoteServerId,
      onlineRecording: song.onlineRecording,
    );
  }

  Song toSong(String id) => Song(
    id: id,
    title: title,
    artist: artist,
    duration: Duration(milliseconds: durationMs),
    fileType: fileType,
    album: album,
    albumArt: albumArt,
    filePath: filePath,
    sourceType: sourceType,
    sourcePackage: sourcePackage,
    remoteId: remoteId,
    remoteServerId: remoteServerId,
    onlineRecording: onlineRecording,
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'artist': artist,
    'durationMs': durationMs,
    'fileType': fileType,
    'album': album,
    'albumArt': albumArt,
    'filePath': filePath,
    'sourceType': sourceType,
    'sourcePackage': sourcePackage,
    'remoteId': remoteId,
    'remoteServerId': remoteServerId,
    if (onlineRecording case final recording?) ...{
      'onlineSourceId': recording.sourceId,
      'onlineTrackId': recording.trackId,
    },
  };

  factory PlaylistSongSnapshot.fromJson(Map<String, dynamic> json) =>
      PlaylistSongSnapshot(
        onlineRecording: switch ((
          json['onlineSourceId'],
          json['onlineTrackId'],
        )) {
          (final String sourceId, final String trackId) => (
            sourceId: sourceId,
            trackId: trackId,
          ),
          _ => null,
        },
        title: json['title'] as String? ?? '',
        artist: json['artist'] as String? ?? '',
        durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
        fileType: json['fileType'] as String? ?? 'ONLINE',
        album: json['album'] as String?,
        albumArt: json['albumArt'] as String?,
        filePath: json['filePath'] as String?,
        sourceType: json['sourceType'] as String?,
        sourcePackage: json['sourcePackage'] as String?,
        remoteId: json['remoteId'] as String?,
        remoteServerId: (json['remoteServerId'] as num?)?.toInt(),
      );
}
