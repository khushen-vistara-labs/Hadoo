/// Replays desktop/mobile playlist journal operations in their original order.
///
/// The journal's numeric position is authoritative, *not* the track title or
/// track_key. Older/sparse entries without a usable position retain their
/// insertion order rather than being silently sorted alphabetically.
class LinkPlaylistOrder {
  const LinkPlaylistOrder({
    required this.name,
    required this.deleted,
    required this.members,
  });

  final String? name;
  final bool deleted;
  final List<LinkPlaylistMember> members;

  static LinkPlaylistOrder replay(Iterable<Map<String, dynamic>> operations) {
    final rows = operations.toList()
      ..sort((a, b) => _stamp(a).compareTo(_stamp(b)));
    String? name;
    var deleted = false;
    var nextOrdinal = 0;
    final members = <String, LinkPlaylistMember>{};

    for (final row in rows) {
      final op = row['op'];
      final rawFields = row['fields'];
      if (rawFields is! Map) continue;
      final fields = Map<String, dynamic>.from(rawFields);
      if (op == 'playlist.create') {
        if (deleted) members.clear(); // a fresh incarnation after deletion
        name = fields['name']?.toString() ?? 'Playlist';
        deleted = false;
      } else if (op == 'playlist.rename') {
        name = fields['name']?.toString() ?? name;
      } else if (op == 'playlist.delete') {
        deleted = true;
        members.clear();
      } else if (op == 'playlist.remove') {
        final key = fields['track_key'];
        if (key is String) members.remove(key);
      } else if (op == 'playlist.add' || op == 'playlist.move') {
        final key = fields['track_key'];
        if (key is! String || key.isEmpty) continue;
        final previous = members[key];
        members[key] = LinkPlaylistMember(
          trackKey: key,
          fields: {...?previous?.fields, ...fields},
          // Keep the first insertion's tie breaker through later moves.
          ordinal: previous?.ordinal ?? nextOrdinal++,
          position: _position(fields['position']) ?? previous?.position,
        );
      }
    }

    final ordered = members.values.toList()
      ..sort((a, b) {
        final left = a.position, right = b.position;
        if (left == null && right != null) return 1;
        if (left != null && right == null) return -1;
        final numeric = left == null ? 0 : left.compareTo(right!);
        return numeric != 0 ? numeric : a.ordinal.compareTo(b.ordinal);
      });
    return LinkPlaylistOrder(name: name, deleted: deleted, members: ordered);
  }

  /// Resolve only the tracks available on this phone. The synced snapshot
  /// must describe precisely that local projection, not unmatched remote
  /// members, or future local captures can send phantom removals to desktop.
  Future<({List<String> songIds, List<String> matchedKeys})> resolveMembers(
    Future<String?> Function(LinkPlaylistMember member) resolveSongId,
  ) async {
    final songIds = <String>[];
    final matchedKeys = <String>[];
    for (final member in members) {
      final songId = await resolveSongId(member);
      if (songId == null) continue;
      songIds.add(songId);
      matchedKeys.add(member.trackKey);
    }
    return (songIds: songIds, matchedKeys: matchedKeys);
  }

  static String _stamp(Map<String, dynamic> op) =>
      "${op['hlc'] ?? ''}:${op['device_id'] ?? ''}:${op['op_id'] ?? ''}";

  static double? _position(Object? value) {
    final position = value is num ? value.toDouble() :
        value is String ? double.tryParse(value) : null;
    return position != null && position.isFinite ? position : null;
  }
}

class LinkPlaylistMember {
  const LinkPlaylistMember({
    required this.trackKey,
    required this.fields,
    required this.ordinal,
    required this.position,
  });

  final String trackKey;
  final Map<String, dynamic> fields;
  final int ordinal;
  final double? position;
}
