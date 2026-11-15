import 'link/link_protocol.dart' show linkUuid;

class CompletedReplayPlay {
  const CompletedReplayPlay(
    this.eventId,
    this.songId,
    this.playedAt,
    this.msPlayed,
  );
  final String eventId, songId;
  final DateTime playedAt;
  final int msPlayed;
}

class ReplayPlayTracker {
  ReplayPlayTracker({
    this.minimumPlayDuration = const Duration(seconds: 30),
    this.maxContinuousProgressGap = const Duration(seconds: 3),
    this.maxRealtimeDrift = const Duration(seconds: 2),
    DateTime Function()? now,
    this.onCompleted,
  }) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final void Function(CompletedReplayPlay)? onCompleted;
  String _eventId = linkUuid();
  DateTime? _startedAt;
  String get eventId => _eventId;
  DateTime get startedAt => _startedAt ?? _now();
  int get listenedMs => _listenedMs;
  void _complete() {
    if (_songId != null && _listenedMs >= minimumPlayDuration.inMilliseconds)
      onCompleted?.call(
        CompletedReplayPlay(_eventId, _songId!, startedAt, _listenedMs),
      );
  }

  final Duration maxRealtimeDrift;

  final Duration minimumPlayDuration;
  final Duration maxContinuousProgressGap;

  String? _songId;
  int _lastPositionMs = 0;
  int _listenedMs = 0;
  bool _hasCountedCurrentTrack = false;
  DateTime? _lastProgressAt;

  void startTrack(String songId, {Duration initialPosition = Duration.zero}) {
    _complete();
    _eventId = linkUuid();
    _startedAt = _now();
    _songId = songId;
    _lastPositionMs = initialPosition.inMilliseconds;
    _listenedMs = 0;
    _hasCountedCurrentTrack = false;
    _lastProgressAt = _now();
  }

  void clear() {
    _complete();
    _songId = null;
    _lastPositionMs = 0;
    _listenedMs = 0;
    _hasCountedCurrentTrack = false;
    _lastProgressAt = null;
  }

  void syncPosition({required String songId, required Duration position}) {
    if (_songId != songId) {
      startTrack(songId, initialPosition: position);
      return;
    }

    _lastPositionMs = position.inMilliseconds;
    _lastProgressAt = _now();
  }

  bool onPositionChanged({required String songId, required Duration position}) {
    if (_songId != songId) {
      startTrack(songId, initialPosition: position);
      return false;
    }

    final now = _now();
    final positionMs = position.inMilliseconds;
    final deltaMs = positionMs - _lastPositionMs;
    final wallDeltaMs = _lastProgressAt == null
        ? deltaMs
        : now.difference(_lastProgressAt!).inMilliseconds;

    _lastPositionMs = positionMs;
    _lastProgressAt = now;

    if (deltaMs <= 0) {
      return false;
    }

    if (deltaMs > maxContinuousProgressGap.inMilliseconds) {
      final driftMs = (deltaMs - wallDeltaMs).abs();
      if (wallDeltaMs <= 0 || driftMs > maxRealtimeDrift.inMilliseconds) {
        return false;
      }
    }

    _listenedMs += deltaMs;
    if (_hasCountedCurrentTrack ||
        _listenedMs < minimumPlayDuration.inMilliseconds) {
      return false;
    }

    _hasCountedCurrentTrack = true;
    return true;
  }
}
