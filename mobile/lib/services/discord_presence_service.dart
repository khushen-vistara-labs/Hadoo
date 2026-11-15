import 'package:flick/models/song.dart';
import 'package:flick/core/utils/app_log.dart';
import 'package:flick/features/discovery/discovery_artwork.dart';
import 'package:flick/features/discovery/discovery_http.dart';
import 'package:flick/services/graceful_http_client.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flick/services/player_service.dart';

/// Opt-in Listening activity using Mornye's official Discord Social SDK bridge.
/// Android uses the installed Discord app's session; no Discord tokens enter Dart.
class DiscordPresenceService extends ChangeNotifier {
  DiscordPresenceService._({
    MethodChannel? channel,
    bool? android,
    Future<String?> Function(Song)? artworkResolver,
  }) : _channel = channel ?? const MethodChannel('com.zarz.mornye/discord'),
       _android = android ?? Platform.isAndroid,
       _artworkResolver = artworkResolver;
  @visibleForTesting
  static DiscordPresenceService create({
    required MethodChannel channel,
    required bool android,
    Future<String?> Function(Song)? artworkResolver,
  }) => DiscordPresenceService._(
    channel: channel,
    android: android,
    artworkResolver: artworkResolver,
  );
  static final instance = DiscordPresenceService._();
  static const applicationId = String.fromEnvironment(
    'LOKAL_DISCORD_APPLICATION_ID',
    defaultValue: '1562522741817479302',
  );
  final MethodChannel _channel;
  final bool _android;
  final Future<String?> Function(Song)? _artworkResolver;
  // Last.fm/Discovery and Discord use exactly the same remote cover lookup.
  // Embedded local artwork remains private: Discord needs a public image URL.
  late final _artwork = createDiscoveryArtworkResolver(
    DiscoveryHttp(GracefulHttpClient(), timeout: const Duration(seconds: 8)),
    // Discord artwork may be credited to both the principal and guest artist.
    // Discovery keeps its original stricter matching by default.
    allowCollaborations: true,
    onSourceFailure: (host, reason) {
      // These diagnostics can distinguish a source API outage from an
      // unavailable recording without logging URLs or private file paths.
      AppLog.instance.add('[Discord cover] $host: $reason');
    },
  );
  final _covers = <String, String>{};
  final _coverJobs = <String>{};
  final _coverFailures = <String, DateTime>{};
  final _coverFailureCounts = <String, int>{};
  final _coverRetryTimers = <String, Timer>{};

  // After repeated misses/network failures, stop repeatedly searching the
  // same public APIs while a track is playing. A transient first failure
  // still gets a fast retry; prolonged outages back off to 15 minutes.
  @visibleForTesting
  static Duration coverRetryDelayForFailure(int failures) => switch (failures) {
    <= 1 => const Duration(seconds: 45),
    2 => const Duration(minutes: 2),
    3 => const Duration(minutes: 5),
    _ => const Duration(minutes: 15),
  };
  String? _lastPublishedKey;
  String _songKey(Song song) => '${song.id}|${song.title}|${song.artist}';
  static const _preference = 'lokal_discord_presence_enabled';
  static const _interval = Duration(seconds: 15);

  PlayerService? _player;
  Future<void>? _starting;
  Future<void> _tail = Future.value();
  Timer? _pending;
  DateTime? _lastSent;
  Duration _lastPosition = Duration.zero;
  bool _running = false;
  bool _sdkAvailable = false;
  bool _enabled = false;
  String _status = 'Checking availability…';
  String _artworkStatus = 'No cover checked yet';
  String get artworkStatus => _artworkStatus;
  String? _artworkStatusKey;

  // Distinguish a failed lookup from an image that Discord fails to display.
  // Never write artwork URLs, credentials, or private file paths to logs.
  void _setArtworkStatus(String key, String message) {
    // A slow remote artwork lookup may finish after a next/previous action.
    // Never show the previous song's failure as the current song's status.
    final current = _player?.currentSongNotifier.value;
    if (current == null || _songKey(current) != key) return;
    if (_artworkStatusKey == key && _artworkStatus == message) return;
    _artworkStatusKey = key;
    _artworkStatus = message;
    AppLog.instance.add('[Discord cover] $message');
    notifyListeners();
  }
  bool get enabled => _enabled;
  bool get configured =>
      _android && (int.tryParse(applicationId) ?? 0) > 0 && _sdkAvailable;
  String get status => _status;

  Future<void> start(PlayerService player) => _starting ??= _start(player);

  Future<void> _start(PlayerService player) async {
    _player = player;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'status' && _enabled && _running) {
        _setStatus(switch (call.arguments) {
          'active' => 'Sharing your music on Discord',
          'unavailable' => 'Could not reach Discord. Check Discord’s activity privacy settings.',
          _ => 'Connecting to Discord…',
        });
      }
    });
    try {
      if (_android) {
        _sdkAvailable = await _channel.invokeMethod<bool>('available') ?? false;
      }
      _enabled =
          (await SharedPreferences.getInstance()).getBool(_preference) ?? false;
    } on PlatformException {
      _sdkAvailable = false;
    } on MissingPluginException {
      _sdkAvailable = false;
    }
    if (!configured) {
      _setStatus(
        (int.tryParse(applicationId) ?? 0) <= 0
            ? 'This build needs Hadoo’s Discord application configuration.'
            : 'Discord Social SDK is not included in this build.',
      );
      return;
    }
    player.currentSongNotifier.addListener(_schedule);
    player.isPlayingNotifier.addListener(_schedule);
    player.isNetworkLoadingNotifier.addListener(_schedule);
    player.durationNotifier.addListener(_schedule);
    player.playbackSpeedNotifier.addListener(_schedule);
    player.positionNotifier.addListener(_positionChanged);
    _setStatus(_enabled ? 'Ready when you play music' : 'Off');
    _schedule();
  }

  void _setStatus(String value) {
    _status = value;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    if (!configured) return;
    _enabled = value;
    await (await SharedPreferences.getInstance()).setBool(_preference, value);
    _setStatus(value ? 'Ready when you play music' : 'Off');
    if (!value) {
      for (final timer in _coverRetryTimers.values) { timer.cancel(); }
      _coverRetryTimers.clear();
    }
    _schedule();
  }

  void _positionChanged() {
    final position = _player!.positionNotifier.value;
    // Normal playback ticks need no request: Discord advances the timestamp.
    if ((position - _lastPosition).abs() > const Duration(seconds: 3)) {
      _schedule();
    }
    _lastPosition = position;
  }

  bool get _canPublish =>
      _enabled &&
      configured &&
      _player != null &&
      _player!.isPlayingNotifier.value &&
      !_player!.isNetworkLoadingNotifier.value &&
      _player!.currentSongNotifier.value != null;

  void _schedule() {
    _pending?.cancel();
    if (!_canPublish) {
      _enqueue(
        _stop,
      ); // Pause/stop/disable clear immediately, without rate limiting.
      return;
    }
    final key = _songKey(_player!.currentSongNotifier.value!);
    final interval = key != _lastPublishedKey
        ? const Duration(seconds: 2)
        : _interval;
    final elapsed = _lastSent == null
        ? interval
        : DateTime.now().difference(_lastSent!);
    final delay = elapsed >= interval ? Duration.zero : interval - elapsed;
    _pending = Timer(delay, () => _enqueue(_publish));
  }

  void _enqueue(Future<void> Function() action) {
    _tail = _tail.catchError((Object _) {}).then((_) async {
      try {
        await action();
      } catch (_) {
        await _failed();
      }
    });
  }

  Future<void> _failed() async {
    _running = false;
    try {
      await _channel
          .invokeMethod<void>('shutdown')
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      /* SDK already unavailable. */
    }
    if (_enabled) {
      _setStatus(
        'Discord is unavailable. Open Discord, then toggle sharing to retry.',
      );
    }
  }

  Future<void> _publish() async {
    if (!_canPublish) return;
    if (!_running) {
      _setStatus('Connecting to Discord…');
      _running =
          await _channel
              .invokeMethod<bool>('initialize', {
                'applicationId': applicationId,
              })
              .timeout(const Duration(seconds: 8)) ??
          false;
      if (!_running) {
        _setStatus(
          'Could not connect. Install Discord and sign in, then toggle sharing to retry.',
        );
        return;
      }
    }
    if (!_canPublish) return;
    final player = _player!;
    final song = player.currentSongNotifier.value!;
    final speed = player.playbackSpeedNotifier.value;
    final rate = speed > 0 ? speed : 1.0;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final duration = player.durationNotifier.value > Duration.zero
        ? player.durationNotifier.value
        : song.duration;
    final position = player.positionNotifier.value.inMilliseconds.clamp(
      0,
      duration.inMilliseconds > 0 ? duration.inMilliseconds : 1 << 53,
    );
    final start = now - (position / 1000 / rate).round();
    final end = duration > Duration.zero
        ? now + ((duration.inMilliseconds - position) / 1000 / rate).round()
        : 0;
    final key = _songKey(song);
    final image = publicArtwork(song.albumArt);
    final lastFailure = _coverFailures[key];
    final canRetry = lastFailure == null ||
        DateTime.now().difference(lastFailure) >=
            coverRetryDelayForFailure(_coverFailureCounts[key] ?? 1);
    if (image.isEmpty && !_covers.containsKey(key) &&
        canRetry && _coverJobs.add(key)) {
      _setArtworkStatus(key, 'Looking up public album artwork…');
      unawaited(_resolveCover(song, key));
    }
    final selectedArtwork = image.isNotEmpty ? image : _covers[key] ?? '';
    await _channel
        .invokeMethod<void>('update', {
          'title': String.fromCharCodes(song.title.runes.take(128)),
          'state': String.fromCharCodes(song.artist.runes.take(128)),
          'artwork': selectedArtwork,
          'album': String.fromCharCodes((song.album ?? '').runes.take(128)),
          'start': start,
          'end': end,
        })
        .timeout(const Duration(seconds: 8));
    _lastSent = DateTime.now();
    _lastPublishedKey = key;
    if (selectedArtwork.isNotEmpty) {
      final host = Uri.parse(selectedArtwork).host;
      _setArtworkStatus(key, 'Cover URL sent to Discord ($host); display unverified');
    } else if (!_coverJobs.contains(key) && !canRetry) {
      _setArtworkStatus(key, 'No usable public cover found; retry pending');
    }
  }

  Future<void> _resolveCover(Song song, String key) async {
    try {
      String? url;
      if (_artworkResolver != null) {
        url = await _artworkResolver(song);
      } else {
        final trackRequest = DiscoveryArtworkRequest(
          kind: DiscoveryArtworkKind.track,
          title: song.title,
          artist: song.artist,
        );
        // After a previous miss, bypass only the negative cache entry.
        // Otherwise the retry would return the cached empty result
        // for five minutes without making a single new lookup.
        if (_coverFailures.containsKey(key)) {
          _artwork.invalidateMiss(trackRequest);
        }
        url = await _artwork.resolve(trackRequest);
        if (publicArtwork(url).isEmpty &&
            song.album?.trim().isNotEmpty == true) {
          final albumRequest = DiscoveryArtworkRequest(
            kind: DiscoveryArtworkKind.album,
            title: song.album!,
            artist: song.albumArtist ?? song.artist,
          );
          if (_coverFailures.containsKey(key)) {
            _artwork.invalidateMiss(albumRequest);
          }
          url = await _artwork.resolve(albumRequest);
        }
      }
      final safe = publicArtwork(url);
      if (safe.isNotEmpty) {
        _covers[key] = safe;
        _setArtworkStatus(key, 'Public cover found; sending to Discord…');
        _coverFailures.remove(key);
        _coverFailureCounts.remove(key);
        _coverRetryTimers.remove(key)?.cancel();
      } else {
        _recordArtworkFailure(key);
        _setArtworkStatus(key, 'No matching public cover URL was found');
      }
      while (_covers.length > 100) {
        _covers.remove(_covers.keys.first);
      }
      if (safe.isNotEmpty &&
          _canPublish &&
          _songKey(_player!.currentSongNotifier.value!) == key) {
        _lastPublishedKey = null;
        _schedule();
      }
    } catch (_) {
      _recordArtworkFailure(key);
      _setArtworkStatus(key, 'Public cover lookup failed; will retry');
      /* Keep the current activity; never upload a local cover. */
    } finally {
      _coverJobs.remove(key);
    }
  }

  void _recordArtworkFailure(String key) {
    _coverFailures[key] = DateTime.now();
    final failures = (_coverFailureCounts[key] ?? 0) + 1;
    _coverFailureCounts[key] = failures;
    _coverRetryTimers.remove(key)?.cancel();
    _coverRetryTimers[key] = Timer(coverRetryDelayForFailure(failures), () {
      _coverRetryTimers.remove(key);
      final current = _player?.currentSongNotifier.value;
      if (_enabled && current != null && _songKey(current) == key) {
        _schedule();
      }
    });
    while (_coverFailures.length > 100) {
      final oldest = _coverFailures.keys.first;
      _coverFailures.remove(oldest);
      _coverFailureCounts.remove(oldest);
      _coverRetryTimers.remove(oldest)?.cancel();
    }
  }

  /// The Discord Social SDK accepts external HTTPS image URLs, not only the
  /// handful of Spotify/Deezer/iTunes hosts used by the initial implementation.
  /// Restrict private/local endpoints, signed URLs and embedded credentials:
  /// Discord receives an external URL, never a local file or LAN address.
  @visibleForTesting
  static String publicArtwork(String? value) {
    final uri = Uri.tryParse((value ?? '').trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.path.isEmpty ||
        (uri.hasPort && uri.port != 443) ||
        // ActivityAssets.SetLargeImage is limited to 300 characters.
        uri.toString().length > 300) {
      return '';
    }
    final host = uri.host.toLowerCase();
    // A local image path, localhost, an IP literal or intranet DNS name
    // must never be forwarded to Discord's external artwork fetcher.
    if (!host.contains('.') ||
        host == 'localhost' ||
        host.endsWith('.localhost') ||
        host.endsWith('.local') ||
        host.endsWith('.lan') ||
        host.endsWith('.internal') ||
        host.endsWith('.home.arpa') ||
        host.endsWith('.test') ||
        host.endsWith('.invalid') ||
        host.endsWith('.example') ||
        InternetAddress.tryParse(host) != null) {
      return '';
    }
    return uri.toString();
  }

  Future<void> _stop() async {
    if (_canPublish)
      return; // A queued transient stop must not clear a newer song.
    if (_running) {
      // Keep the SDK alive across pause/track-load gaps; only disable shuts down.
      await _channel
          .invokeMethod<void>(_enabled ? 'clear' : 'shutdown')
          .timeout(const Duration(seconds: 4));
    }
    if (!_enabled) _running = false;
    _lastSent = null;
    _lastPublishedKey = null;
    if (configured) _setStatus(_enabled ? 'Ready when you play music' : 'Off');
  }

  Future<void> stop() async {
    _pending?.cancel();
    for (final timer in _coverRetryTimers.values) { timer.cancel(); }
    _coverRetryTimers.clear();
    final player = _player;
    if (configured && player != null) {
      player.currentSongNotifier.removeListener(_schedule);
      player.isPlayingNotifier.removeListener(_schedule);
      player.isNetworkLoadingNotifier.removeListener(_schedule);
      player.durationNotifier.removeListener(_schedule);
      player.playbackSpeedNotifier.removeListener(_schedule);
      player.positionNotifier.removeListener(_positionChanged);
    }
    _player = null;
    await _tail;
    if (_running)
      await _channel
          .invokeMethod<void>('shutdown')
          .timeout(const Duration(seconds: 4));
    _running = false;
    _starting = null;
  }
}
