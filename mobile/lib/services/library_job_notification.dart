import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flick/features/library_jobs/library_jobs.dart';

/// Silent metadata-job progress, separate from playback and desktop sync.
class LibraryJobNotification {
  static const _channel = MethodChannel('lokal/library_sync_notification');
  Timer? _timer;
  Map<String, Object?>? _pending;
  DateTime? _sentAt;
  Future<void> _tail = Future.value();
  bool _visible = false;
  LibraryJobStatus? _last;

  void update(LibraryJobStatus status) {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android ||
        status.job == null)
      return;
    if (!status.running && !_visible) return;
    _last = status;
    _visible = status.running;
    _pending = {
      'kind': 'library_job',
      'title': status.running
          ? status.job!.label
          : status.cancelled
          ? '${status.job!.label} · Stopped'
          : '${status.job!.label} · Finished',
      'message': status.message,
      'busy': status.running,
      'processed': status.done,
      'total': status.total,
    };
    if (!status.running ||
        _sentAt == null ||
        DateTime.now().difference(_sentAt!) >=
            const Duration(milliseconds: 500)) {
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

  void _flush() {
    final payload = _pending;
    if (payload == null) return;
    _pending = null;
    _sentAt = DateTime.now();
    _tail = _tail.then((_) async {
      try {
        await _channel.invokeMethod<bool>('update', payload);
      } on PlatformException {
        // Denied notification permission must not abort the job.
      } on MissingPluginException {
        // Non-Android hosts and older builds.
      }
    });
  }

  void dispose() {
    final last = _last;
    if (_visible && last != null)
      update(
        LibraryJobStatus(
          job: last.job,
          done: last.done,
          total: last.total,
          cancelled: true,
        ),
      );
    _timer?.cancel();
  }
}
