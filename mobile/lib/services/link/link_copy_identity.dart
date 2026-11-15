import '../../models/song.dart';
import 'link_protocol.dart';

/// Candidates only: the desktop must confirm the original file still exists.
/// IDs belong to one paired server and must never match another PC by accident.
class LinkCopyIdentity {
  LinkCopyIdentity({
    required this.serverId,
    required List<Map<String, dynamic>> tracks,
  }) {
    for (final track in tracks) {
      final id = track['id']?.toString();
      if (id == null || id.isEmpty) continue;
      _byId[id] = track;
      _byName
          .putIfAbsent(
            _key(
              track['artist']?.toString() ?? '',
              track['title']?.toString() ?? '',
            ),
            () => [],
          )
          .add(track);
    }
  }
  final int serverId;
  final _byId = <String, Map<String, dynamic>>{};
  final _byName = <String, List<Map<String, dynamic>>>{};
  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  static String _key(String artist, String title) =>
      '${_normalize(artist)}\u0000${_normalize(title)}';

  String resolverKey(Song song) {
    final original = song.remoteServerId == serverId
        ? _byId[song.remoteId]
        : null;
    final seconds = original?['duration'];
    if (original != null &&
        seconds is num &&
        seconds.isFinite &&
        seconds >= 0) {
      return linkTrackKey(
        original['artist']?.toString() ?? '',
        original['title']?.toString() ?? '',
        Duration(milliseconds: (seconds * 1000).round()),
      );
    }
    return linkTrackKey(song.artist, song.title, song.duration);
  }

  List<String> candidates(Song song) {
    final result = <String>{};
    if (song.remoteServerId == serverId && _byId.containsKey(song.remoteId)) {
      result.add(song.remoteId!);
    }
    // Metadata remains a fallback for independently scanned copies. Never use
    // a title alone, fuzzy substring matching or an unknown/zero duration.
    if (song.duration > Duration.zero &&
        song.artist.trim().isNotEmpty &&
        song.title.trim().isNotEmpty) {
      for (final track
          in _byName[_key(song.artist, song.title)] ??
              <Map<String, dynamic>>[]) {
        final duration = track['duration'];
        if (duration is num &&
            duration.isFinite &&
            duration > 0 &&
            (duration - song.duration.inMilliseconds / 1000).abs() <= 2) {
          result.add(track['id'].toString());
        }
      }
    }
    return result.toList();
  }
}
