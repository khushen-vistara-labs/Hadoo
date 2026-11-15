import 'dart:async';
import 'dart:convert';

import 'package:flick/features/discovery/discovery_http.dart';
import 'package:flick/features/discovery/discovery_sources.dart';
import 'package:flick/models/song.dart';
import 'package:flick/providers/opt_in_source_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'music_video_match.dart';

const _matchesKey = 'lokal_music_video_matches';

@immutable
class MusicVideoIndex {
  const MusicVideoIndex({
    this.matches = const {},
    this.scanning = false,
    this.done = 0,
    this.total = 0,
  });

  /// Song id → video id; an empty id means "looked, none found".
  final Map<String, String> matches;
  final bool scanning;
  final int done;
  final int total;

  String? videoFor(String songId) {
    final id = matches[songId];
    return id == null || id.isEmpty ? null : id;
  }

  MusicVideoIndex copyWith({
    Map<String, String>? matches,
    bool? scanning,
    int? done,
    int? total,
  }) => MusicVideoIndex(
    matches: matches ?? this.matches,
    scanning: scanning ?? this.scanning,
    done: done ?? this.done,
    total: total ?? this.total,
  );
}

/// One card per actual video even when several song rows/credits point to it.
/// Prefer an owned copy as the representative without modifying the index.
List<Song> uniqueMusicVideoSongs(Iterable<Song> songs, MusicVideoIndex index) {
  final videos = <String, Song>{};
  for (final song in songs) {
    final id = index.videoFor(song.id);
    if (id == null) continue;
    final current = videos[id];
    if (current == null ||
        ((current.isNetworkSource || current.isPending) &&
            !song.isNetworkSource &&
            !song.isPending))
      videos[id] = song;
  }
  return videos.values.toList();
}

/// Which library songs have an official video, found by YouTube Music
/// search and kept on the device. Nothing is searched while music videos
/// are off.
class MusicVideoIndexNotifier extends Notifier<MusicVideoIndex> {
  bool _cancel = false;

  @override
  MusicVideoIndex build() {
    ref.listen<bool>(musicVideosEnabledProvider, (_, on) {
      if (!on) _cancel = true;
    });
    unawaited(_load());
    return const MusicVideoIndex();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final raw = prefs.getString(_matchesKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map || !ref.mounted) return;
      state = state.copyWith(
        matches: {
          for (final e in decoded.entries)
            if (e.key is String && e.value is String)
              e.key as String: e.value as String,
        },
      );
    } catch (_) {
      // A damaged index is rebuilt by the next search.
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_matchesKey, jsonEncode(state.matches));
  }

  void _put(String songId, String videoId) {
    state = state.copyWith(matches: {...state.matches, songId: videoId});
  }

  /// [song]'s video: the remembered one, else a search (when on).
  Future<String?> find(Song song, {bool force = false}) async {
    if (!force && state.matches.containsKey(song.id)) {
      return state.videoFor(song.id);
    }
    if (!ref.read(musicVideosEnabledProvider)) return null;
    final client = http.Client();
    try {
      final id = await findMusicVideo(
        YoutubeMusicCatalog(DiscoveryHttp(client)),
        song,
      );
      if (!ref.mounted) return id;
      _put(song.id, id ?? '');
      await _save();
      return id;
    } finally {
      client.close();
    }
  }

  /// Looks for every song not looked up yet, one search at a time.
  Future<void> scan(List<Song> songs) async {
    if (state.scanning || !ref.read(musicVideosEnabledProvider)) return;
    final todo = [
      for (final song in songs)
        if (!state.matches.containsKey(song.id)) song,
    ];
    if (todo.isEmpty) return;
    _cancel = false;
    state = state.copyWith(scanning: true, done: 0, total: todo.length);
    final client = http.Client();
    final catalog = YoutubeMusicCatalog(DiscoveryHttp(client));
    var failures = 0;
    try {
      for (final song in todo) {
        if (_cancel || !ref.mounted) break;
        try {
          final id = await findMusicVideo(catalog, song);
          if (!ref.mounted) break;
          _put(song.id, id ?? '');
          failures = 0;
        } catch (_) {
          // Offline or refused: stop after a few in a row, keep what we have.
          if (++failures >= 5) break;
        }
        if (!ref.mounted) break;
        state = state.copyWith(done: state.done + 1);
        if (state.done % 20 == 0) await _save();
        // Gentle on YouTube Music: one search every half second.
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    } finally {
      client.close();
      if (ref.mounted) {
        state = state.copyWith(scanning: false);
        await _save();
      }
    }
  }

  void cancel() => _cancel = true;
}

final musicVideoIndexProvider =
    NotifierProvider<MusicVideoIndexNotifier, MusicVideoIndex>(
      MusicVideoIndexNotifier.new,
    );
