import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchTrack {
  const RecentSearchTrack({
    required this.title,
    required this.artist,
    this.songId,
    this.artwork,
  });
  final String title, artist;
  final String? songId, artwork;
  String get key =>
      '${title.trim().toLowerCase()}|${artist.trim().toLowerCase()}';
  Map<String, Object?> toJson() => {
    'title': title,
    'artist': artist,
    'songId': songId,
    'artwork': artwork,
  };
}

class RecentSearchTracks extends Notifier<List<RecentSearchTrack>> {
  static const _key = 'lokal.search.recent_tracks.v1';
  final _ready = Completer<void>();
  Future<void> _writes = Future.value();
  @override
  List<RecentSearchTrack> build() {
    unawaited(_load());
    return const [];
  }

  Future<void> _load() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw != null && ref.mounted) {
        final rows = jsonDecode(raw);
        if (rows is List) {
          state = rows
              .whereType<Map>()
              .where((r) => r['title'] is String && r['artist'] is String)
              .take(20)
              .map(
                (r) => RecentSearchTrack(
                  title: r['title'] as String,
                  artist: r['artist'] as String,
                  songId: r['songId'] as String?,
                  artwork: r['artwork'] as String?,
                ),
              )
              .toList();
        }
      }
    } catch (_) {
      /* An older/damaged history never blocks Search. */
    } finally {
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  Future<void> add(RecentSearchTrack track) async {
    await _ready.future;
    if (!ref.mounted) return;
    state = [
      track,
      ...state.where((row) => row.key != track.key),
    ].take(20).toList();
    await _save();
  }

  Future<void> clear() async {
    await _ready.future;
    if (!ref.mounted) return;
    state = [];
    await _save();
  }

  Future<void> _save() {
    final raw = jsonEncode(state.map((row) => row.toJson()).toList());
    _writes = _writes.catchError((Object _) {}).then((_) async {
      try {
        await (await SharedPreferences.getInstance()).setString(_key, raw);
      } catch (_) {
        // Keep this session's history usable when storage is unavailable.
      }
    });
    return _writes;
  }
}

final recentSearchTracksProvider =
    NotifierProvider<RecentSearchTracks, List<RecentSearchTrack>>(
      RecentSearchTracks.new,
    );
