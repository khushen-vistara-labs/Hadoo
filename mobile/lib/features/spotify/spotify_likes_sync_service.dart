import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'spotify_http.dart';
import 'spotify_models.dart';
import 'spotify_oauth.dart';
import 'spotify_storage.dart';
import 'spotify_sync.dart';
import 'spotify_web_api.dart';

/// Watches likes made after activation. Existing likes are never imported.
class SpotifyLikesSyncService {
  SpotifyLikesSyncService._({
    SpotifyWebApi Function()? apiFactory,
    Future<Set<String>> Function(List<SpotifyTrack>, SpotifyCancellation)?
    apply,
  }) : _apiFactory =
           apiFactory ??
           (() {
             final store = SecureSpotifyTokenStore();
             return SpotifyWebApi(
               store: store,
               oauth: SpotifyOAuthService(tokenStore: store),
             );
           }),
       _apply = apply;
  @visibleForTesting
  factory SpotifyLikesSyncService.testing({
    required SpotifyWebApi Function() apiFactory,
    required Future<Set<String>> Function(
      List<SpotifyTrack>,
      SpotifyCancellation,
    )
    apply,
  }) => SpotifyLikesSyncService._(apiFactory: apiFactory, apply: apply);
  static final instance = SpotifyLikesSyncService._();
  static const enabledKey = 'lokal.spotify.sync_likes';
  static const cursorKey = 'lokal.spotify.sync_likes_since';
  static const policyKey = 'lokal.spotify.likes_policy';
  final SpotifyWebApi Function() _apiFactory;
  final Future<Set<String>> Function(List<SpotifyTrack>, SpotifyCancellation)?
  _apply;
  final status = ValueNotifier<String?>(null);
  final _tries = <String, int>{};
  Timer? _timer;
  SpotifyCancellation? _cancel;
  Future<void>? _active;
  Future<bool> get enabled async =>
      (await SharedPreferences.getInstance()).getBool(enabledKey) ?? false;
  void resume() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(minutes: 3),
      (_) => unawaited(sync()),
    );
    unawaited(sync());
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> resetCursor() async {
    _cancel?.cancel();
    await _active;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(cursorKey);
    await prefs.remove(policyKey);
    _tries.clear();
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _cancel?.cancel();
    await _active;
    if (!value) {
      await prefs.setBool(enabledKey, false);
      status.value = null;
      return;
    }
    // Fail activation visibly if Spotify cannot establish a valid baseline.
    final api = _apiFactory();
    try {
      final batch = await api.likedSince(null);
      await prefs.setInt(
        cursorKey,
        batch.newest > 0 ? batch.newest : DateTime.now().millisecondsSinceEpoch,
      );
      await prefs.setInt(policyKey, 2);
      await prefs.setBool(enabledKey, true);
      _tries.clear();
      status.value =
          'Watching new Spotify likes. Existing likes are left as they are.';
    } finally {
      api.close();
    }
  }

  Future<void> sync() => _active ??= _sync().whenComplete(() => _active = null);
  Future<void> _sync() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(enabledKey) ?? false)) return;
    final cancel = SpotifyCancellation();
    _cancel = cancel;
    final api = _apiFactory();
    try {
      final cursor = prefs.getInt(policyKey) == 2
          ? prefs.getInt(cursorKey)
          : null;
      final batch = await api.likedSince(cursor, cancellation: cancel);
      cancel.check();
      if (cursor == null) {
        await prefs.setInt(
          cursorKey,
          batch.newest > 0
              ? batch.newest
              : DateTime.now().millisecondsSinceEpoch,
        );
        await prefs.setInt(policyKey, 2);
        status.value =
            'Watching new Spotify likes. Existing likes are left as they are.';
        return;
      }
      final items = batch.items.reversed
          .toList(); // Desktop applies oldest first.
      final tracks = items.map((item) => item.track).toList();
      Set<String> handled;
      if (_apply != null) {
        handled = await _apply(tracks, cancel);
      } else if (tracks.isEmpty) {
        handled = {};
      } else {
        final report = await SpotifySyncService(
          api: api,
          metadata: SpotifyMetadataStore(
            SharedPreferencesSpotifyPreferenceStore(),
          ),
        ).syncLikedSongs(suppliedTracks: tracks, cancellation: cancel);
        final unmatched = report.unmatchedTracks
            .map((t) => t.spotifyId)
            .toSet();
        handled = report.readbackVerified
            ? tracks
                  .where((t) => !unmatched.contains(t.id))
                  .map((t) => t.id)
                  .toSet()
            : {};
      }
      cancel.check();
      var through = cursor, blocked = false, skipped = 0;
      for (final item in items) {
        var done = handled.contains(item.track.id);
        if (done) {
          _tries.remove(item.track.id);
        } else {
          final count = (_tries[item.track.id] ?? 0) + 1;
          _tries[item.track.id] = count;
          if (count >= 3) {
            done = true;
            skipped++;
            _tries.remove(item.track.id);
          }
        }
        if (!done) {
          if (!blocked && through >= item.addedAt) through = item.addedAt - 1;
          blocked = true;
        } else if (!blocked) {
          through = item.addedAt;
        }
      }
      if (!blocked) through = batch.newest > through ? batch.newest : through;
      if (through > cursor) await prefs.setInt(cursorKey, through);
      status.value = blocked
          ? 'New Spotify likes are waiting for a matching library song; retrying.'
          : skipped > 0
          ? 'New likes checked. $skipped songs were not found in your library.'
          : 'New Spotify likes are up to date.';
    } catch (error) {
      status.value = cancel.isCancelled
          ? null
          : 'Spotify likes could not sync. Check your session and retry.';
    } finally {
      api.close();
      _cancel = null;
    }
  }
}
