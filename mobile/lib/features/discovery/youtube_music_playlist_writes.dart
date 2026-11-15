import 'lastfm_discovery.dart';
import 'youtube_music_account.dart';

/// Mutations use the same signed-in account as browsing. A response must
/// explicitly confirm the write; a network failure never creates a local list.
class YoutubeMusicPlaylistWrites {
  const YoutubeMusicPlaylistWrites(this.account);
  final YoutubeMusicAccount account;

  static String title(String value) {
    final result = value.trim();
    if (result.isEmpty ||
        result.length > 150 ||
        RegExp(r'[<>\x00-\x1f]').hasMatch(result)) {
      throw const LokalDiscoveryFailure(
        'Use a playlist name of 1–150 characters without < or >.',
      );
    }
    return result;
  }

  static String playlistId(String value) {
    if (!RegExp(r'^PL[A-Za-z0-9_-]{1,118}$').hasMatch(value)) {
      throw const LokalDiscoveryFailure(
        'This YouTube playlist cannot be edited.',
      );
    }
    return value;
  }

  static List<String> videoIds(Iterable<String> values) {
    final ids = values.toSet().toList(growable: false);
    if (ids.length > 500 ||
        ids.any((id) => !RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id))) {
      throw const LokalDiscoveryFailure(
        'Choose up to 500 YouTube tracks at a time.',
      );
    }
    return ids;
  }

  Future<Map<String, dynamic>> _request(
    String endpoint,
    Map<String, Object?> body,
  ) => account.request(endpoint, body, forbiddenMeansSignedOut: false);

  static void _confirmed(Map<String, dynamic> result) {
    if (result['error'] != null || result['status'] != 'STATUS_SUCCEEDED') {
      throw const LokalDiscoveryFailure(
        'YouTube did not confirm the change. Refresh the playlist before trying again.',
      );
    }
  }

  Future<String> create(
    String name, {
    Iterable<String> tracks = const [],
  }) async {
    final result = await _request('playlist/create', {
      'title': title(name),
      'description': '',
      'privacyStatus': 'PRIVATE',
      'videoIds': videoIds(tracks),
    });
    final id = result['playlistId'];
    if (result['error'] == null &&
        id is String &&
        RegExp(r'^PL[A-Za-z0-9_-]+$').hasMatch(id))
      return id;
    throw const LokalDiscoveryFailure(
      'YouTube did not confirm playlist creation. Check your YouTube library before retrying.',
    );
  }

  Future<void> _edit(String id, List<Map<String, Object?>> actions) async {
    _confirmed(
      await _request('browse/edit_playlist', {
        'playlistId': playlistId(id),
        'actions': actions,
      }),
    );
  }

  Future<void> rename(String id, String name) => _edit(id, [
    {'action': 'ACTION_SET_PLAYLIST_NAME', 'playlistName': title(name)},
  ]);

  Future<void> add(String id, Iterable<String> tracks) async {
    final ids = videoIds(tracks);
    if (ids.isEmpty)
      throw const LokalDiscoveryFailure('Choose a YouTube track first.');
    await _edit(id, [
      for (final video in ids)
        {'action': 'ACTION_ADD_VIDEO', 'addedVideoId': video},
    ]);
  }

  Future<void> remove(String id, LokalDiscoveryTrack track) async {
    final setId = track.setVideoId;
    final video = track.videoId;
    if (setId == null || setId.isEmpty || video == null) {
      throw const LokalDiscoveryFailure(
        'Refresh this playlist before removing a song.',
      );
    }
    videoIds([video]);
    await _edit(id, [
      {
        'action': 'ACTION_REMOVE_VIDEO',
        'removedVideoId': video,
        'setVideoId': setId,
      },
    ]);
  }

  Future<void> delete(String id) async => _confirmed(
    await _request('playlist/delete', {'playlistId': playlistId(id)}),
  );
}
