import 'package:flick/models/song.dart';

/// A playlist returned by Spotify's Web API.
class SpotifyPlaylist {
  const SpotifyPlaylist({
    required this.id,
    required this.name,
    this.owner,
    this.imageUrl,
    this.tracksTotal = 0,
  });

  final String id;
  final String name;
  final String? owner;
  final String? imageUrl;
  final int tracksTotal;
}

/// Track metadata from Spotify. It describes a Spotify recording only; it is
/// never used as a playable or lossless local media object.
class SpotifyTrack {
  const SpotifyTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String artist;
  final String? album;
  final int durationMs;
  final String? imageUrl;

  SpotifyUnmatchedTrack toUnmatched() => SpotifyUnmatchedTrack(
        spotifyId: id,
        title: title,
        artist: artist,
        album: album,
        durationMs: durationMs,
      );
}

/// A Spotify item that could not be matched to exactly one local song.
class SpotifyUnmatchedTrack {
  const SpotifyUnmatchedTrack({
    required this.spotifyId,
    required this.title,
    required this.artist,
    this.album,
    required this.durationMs,
  });

  final String spotifyId;
  final String title;
  final String artist;
  final String? album;
  final int durationMs;

  Map<String, dynamic> toJson() => {
        'spotifyId': spotifyId,
        'title': title,
        'artist': artist,
        'album': album,
        'durationMs': durationMs,
      };

  factory SpotifyUnmatchedTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyUnmatchedTrack(
      spotifyId: json['spotifyId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      album: json['album'] as String?,
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
    );
  }
}

class SpotifyPlaylistImportReport {
  const SpotifyPlaylistImportReport({
    required this.playlist,
    required this.totalTracks,
    required this.matchedTracks,
    required this.savedSongIds,
    required this.unmatchedTracks,
    required this.localPlaylistName,
  });

  final SpotifyPlaylist playlist;
  final int totalTracks;
  final int matchedTracks;
  final List<String> savedSongIds;
  final List<SpotifyUnmatchedTrack> unmatchedTracks;
  final String localPlaylistName;
}

class SpotifyLikedSongsSyncReport {
  const SpotifyLikedSongsSyncReport({
    required this.totalTracks,
    required this.matchedTracks,
    required this.addedCount,
    required this.alreadyLikedCount,
    required this.unmatchedTracks,
    required this.readbackVerified,
  });

  final int totalTracks;
  final int matchedTracks;
  final int addedCount;
  final int alreadyLikedCount;
  final List<SpotifyUnmatchedTrack> unmatchedTracks;
  final bool readbackVerified;
}

/// Metadata retained separately from the app playlist model. This keeps the
/// Spotify source identity and every unmatched item available for a later
/// retry without pretending the Spotify record is local audio.
class SpotifyPlaylistMetadata {
  const SpotifyPlaylistMetadata({
    required this.playlistId,
    required this.sourceUri,
    required this.name,
    required this.lastImportedAt,
    required this.unmatchedTracks,
    this.localPlaylistId,
  });

  final String playlistId;
  final String sourceUri;
  final String name;
  final DateTime lastImportedAt;
  final List<SpotifyUnmatchedTrack> unmatchedTracks;
  final String? localPlaylistId;

  Map<String, dynamic> toJson() => {
        'playlistId': playlistId,
        'sourceUri': sourceUri,
        'name': name,
        'lastImportedAt': lastImportedAt.toIso8601String(),
        'unmatchedTracks': [
          for (final track in unmatchedTracks) track.toJson(),
        ],
        'localPlaylistId': localPlaylistId,
      };

  factory SpotifyPlaylistMetadata.fromJson(Map<String, dynamic> json) {
    final rawTracks = json['unmatchedTracks'];
    return SpotifyPlaylistMetadata(
      playlistId: json['playlistId'] as String? ?? '',
      sourceUri: json['sourceUri'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lastImportedAt: DateTime.tryParse(
            json['lastImportedAt'] as String? ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      unmatchedTracks: rawTracks is List
          ? [
              for (final item in rawTracks)
                if (item is Map)
                  SpotifyUnmatchedTrack.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
            ]
          : const [],
      localPlaylistId: json['localPlaylistId'] as String?,
    );
  }
}

class SpotifySyncMetadata {
  const SpotifySyncMetadata({
    this.playlists = const {},
    this.lastLikedSync,
  });

  static const int version = 1;

  final Map<String, SpotifyPlaylistMetadata> playlists;
  final DateTime? lastLikedSync;

  SpotifySyncMetadata copyWith({
    Map<String, SpotifyPlaylistMetadata>? playlists,
    DateTime? lastLikedSync,
  }) {
    return SpotifySyncMetadata(
      playlists: playlists ?? this.playlists,
      lastLikedSync: lastLikedSync ?? this.lastLikedSync,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'playlists': {
          for (final entry in playlists.entries) entry.key: entry.value.toJson(),
        },
        'lastLikedSync': lastLikedSync?.toIso8601String(),
      };

  factory SpotifySyncMetadata.fromJson(Map<String, dynamic> json) {
    if (json['version'] != version) {
      throw const FormatException('Unsupported Spotify metadata version.');
    }
    final rawPlaylists = json['playlists'];
    final playlists = <String, SpotifyPlaylistMetadata>{};
    if (rawPlaylists is Map) {
      for (final entry in rawPlaylists.entries) {
        if (entry.key is String && entry.value is Map) {
          playlists[entry.key as String] = SpotifyPlaylistMetadata.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
          );
        }
      }
    }
    return SpotifySyncMetadata(
      playlists: playlists,
      lastLikedSync: DateTime.tryParse(json['lastLikedSync'] as String? ?? ''),
    );
  }
}

/// A local song candidate retained here to keep the matcher API explicit.
typedef SpotifyLocalSong = Song;
