import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../l10n/l10n.dart';
import '../../models/lokal_remote_state.dart';

/// A separate, silent Android status notification; never owns the media session.
/// Empty periodic checks stay silent, while explicit merges show preparing at once.
class LibrarySyncNotification {
  static const _channel = MethodChannel('lokal/library_sync_notification');
  bool _visible = false;
  String _deviceName = '';
  LinkSyncProgress _last = const LinkSyncProgress();
  Timer? _timer;
  Map<String, Object?>? _pending;
  DateTime? _sentAt;
  Future<void> _tail = Future<void>.value();

  void begin({required String deviceName}) {
    _visible = true;
    _sentAt = null;
    update(
      const LinkSyncProgress(phase: LinkSyncPhase.preparing),
      deviceName: deviceName,
    );
  }

  void update(LinkSyncProgress progress, {required String deviceName}) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    _deviceName = deviceName;
    _last = progress;
    if (!_visible) {
      if (!progress.busy ||
          (progress.phase != LinkSyncPhase.catalog && progress.processed == 0))
        return;
      _visible = true;
    }
    final phase = progress.phase;
    final title = switch (phase) {
      LinkSyncPhase.complete => lokalText('Library sync complete'),
      LinkSyncPhase.paused => lokalText('Library sync paused'),
      _ => lokalText('Syncing library'),
    };
    final detail = switch (phase) {
      LinkSyncPhase.preparing ||
      LinkSyncPhase.idle => lokalText('Preparing your libraries…'),
      LinkSyncPhase.catalog => lokalText('Adding desktop songs…'),
      LinkSyncPhase.library => lokalText(
        'Syncing likes, playlists and metadata…',
      ),
      LinkSyncPhase.history => lokalText('Syncing listening history…'),
      LinkSyncPhase.metadata => lokalText('Checking copied audio details…'),
      LinkSyncPhase.lyrics => lokalText('Syncing saved lyrics…'),
      LinkSyncPhase.finalizing => lokalText('Updating your profile…'),
      LinkSyncPhase.complete => lokalText('Your libraries are up to date.'),
      LinkSyncPhase.paused => lokalText('Reconnect to your desktop to resume.'),
    };
    final count = progress.busy && progress.total != null && progress.total! > 0
        ? lokalText(
            '{done} of {total} songs',
            args: {'done': progress.processed, 'total': progress.total},
          )
        : progress.busy && progress.processed > 0
        ? lokalText(
            '{count} entries processed',
            args: {'count': progress.processed},
          )
        : null;
    _pending = {
      'title': title,
      'message': count == null ? detail : '$detail $count',
      'deviceName': deviceName,
      'busy': progress.busy,
      'processed': progress.processed,
      'total': progress.total,
    };
    final now = DateTime.now();
    final immediate =
        !progress.busy ||
        _sentAt == null ||
        now.difference(_sentAt!) >= const Duration(milliseconds: 500);
    if (!progress.busy) _visible = false;
    if (immediate) {
      _timer?.cancel();
      _timer = null;
      _flush();
    } else {
      _timer ??= Timer(const Duration(milliseconds: 500), () {
        _timer = null;
        _flush();
      });
    }
  }

  void pause() {
    if (!_visible) return;
    update(
      LinkSyncProgress(
        phase: LinkSyncPhase.paused,
        processed: _last.processed,
        total: _last.total,
      ),
      deviceName: _deviceName,
    );
  }

  void dispose() {
    pause();
    _timer?.cancel();
  }

  void _flush() {
    final payload = _pending;
    if (payload == null) return;
    _pending = null;
    _sentAt = DateTime.now();
    _tail = _tail.then((_) async {
      try {
        await _channel.invokeMethod<bool>('update', payload);
      } on PlatformException {
        // Notification permission/channel availability must not stop a merge.
      } on MissingPluginException {
        // Non-Android/test hosts and older native builds.
      }
    });
  }
}
