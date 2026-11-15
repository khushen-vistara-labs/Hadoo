import 'package:flutter/foundation.dart';

import 'audio_preload_service.dart';
import 'library_scanner_service.dart' show ScanProgress;

/// What kind of work a live session represents.
enum ScanSessionKind { scan, preload, replayGain }

/// Where the single user-visible session is in its life.
///
/// `idle → running → (complete | unavailable | failed | cancelled) → idle`.
/// The end states outlive the session itself so the scan sheet can keep
/// showing the outcome (and its Done button) after the work has stopped;
/// [ScanSessionController.dismiss] returns to [idle].
enum ScanSessionStatus {
  idle,
  running,
  complete,
  unavailable,
  failed,
  cancelled,
}

/// What a finished session did, for the completion sheet.
@immutable
class ScanSessionResult {
  const ScanSessionResult({
    required this.kind,
    required this.title,
    this.newSongs = 0,
    this.modifiedSongs = 0,
    this.deletedSongs = 0,
    this.totalSongs = 0,
    this.processed = 0,
    this.elapsed = Duration.zero,
  });

  final ScanSessionKind kind;
  final String title;

  /// Songs added to the library by this scan.
  final int newSongs;
  final int modifiedSongs;
  final int deletedSongs;

  /// Songs in the library once the scan finished.
  final int totalSongs;

  /// Files read (scan) or songs analysed (preload, ReplayGain).
  final int processed;
  final Duration elapsed;
}

/// Immutable snapshot of a user-visible scan/preload/ReplayGain session.
class ScanSession {
  final String title;
  final ScanSessionKind kind;
  final DateTime startedAt;
  final void Function() onCancel;

  const ScanSession({
    required this.title,
    this.kind = ScanSessionKind.scan,
    required this.startedAt,
    required this.onCancel,
  });
}

/// App-level state for the single user-visible scan session, shared between
/// the full-screen scanning overlay (library settings screen) and the
/// floating progress pill (main shell). Exactly one session exists at a
/// time; the overlay shows it full-screen until minimized, after which the
/// pill keeps reporting progress until the owning flow calls [end].
///
/// Silent background work (auto library sync, post-scan auto preload) never
/// touches this controller — the pill listens to
/// [AudioPreloadService.instance.progress] directly for that.
class ScanSessionController {
  static final ScanSessionController instance = ScanSessionController._();

  ScanSessionController._();

  final ValueNotifier<ScanSession?> session = ValueNotifier(null);
  final ValueNotifier<ScanProgress?> progress = ValueNotifier(null);
  final ValueNotifier<bool> minimized = ValueNotifier(false);

  /// True while the owning flow is doing post-scan work (artwork backfill)
  /// after the scan stream completed. Stop actions should ask to skip that
  /// work instead of cancelling the scan.
  final ValueNotifier<bool> postProcessing = ValueNotifier(false);

  /// Incremented every time the user asks to skip post-processing. The owning
  /// flow listens and proceeds without waiting for the background work.
  final ValueNotifier<int> skipRequests = ValueNotifier(0);

  /// Latches true when the owning flow finishes all work for the session.
  /// [end] does not reset it: the pill uses it to play a short completion
  /// outro even though the session is already gone. [begin] resets it.
  final ValueNotifier<bool> completed = ValueNotifier(false);

  /// The session's place in its life; see [ScanSessionStatus].
  final ValueNotifier<ScanSessionStatus> status = ValueNotifier(
    ScanSessionStatus.idle,
  );

  /// The outcome of the last finished session, while [status] is
  /// [ScanSessionStatus.complete].
  final ValueNotifier<ScanSessionResult?> result = ValueNotifier(null);

  void markCompleted() {
    if (session.value == null) return;
    completed.value = true;
  }

  void requestSkip() {
    if (!postProcessing.value) return;
    skipRequests.value++;
  }

  int _generation = 0;

  bool get isActive => session.value != null;

  /// True when the floating pill should render: a session exists but its
  /// overlay has been dismissed.
  bool get isVisible => session.value != null && minimized.value;

  /// True when [generation] still owns the active session. Stale flows (a
  /// scan that was stopped or replaced) use this to stop touching state.
  bool isCurrent(int generation) =>
      _generation == generation && session.value != null;

  /// Starts a new session, replacing any stale one. Returns a generation id;
  /// pass it to [update]/[end]/[overlayDismissed] so a superseded flow can't
  /// pollute a newer session.
  int begin({
    required String title,
    required ScanSessionKind kind,
    required void Function() onCancel,
  }) {
    final generation = ++_generation;
    session.value = ScanSession(
      title: title,
      kind: kind,
      startedAt: DateTime.now(),
      onCancel: onCancel,
    );
    progress.value = null;
    minimized.value = false;
    postProcessing.value = false;
    completed.value = false;
    result.value = null;
    status.value = ScanSessionStatus.running;
    // A visible session means the user started work again; lift the sticky
    // auto-preload suppression a previous Stop installed.
    AudioPreloadService.instance.clearAutoSuppression();
    return generation;
  }

  /// Stores the latest progress for [generation]. Ignored when the session is
  /// gone or was replaced, so stragglers can't resurrect the pill.
  void update(int generation, ScanProgress value) {
    if (!isCurrent(generation)) return;
    progress.value = value;
  }

  /// The [generation] overlay was dismissed without the work finishing — keep
  /// reporting via the floating pill.
  void overlayDismissed(int generation) {
    if (!isCurrent(generation)) return;
    minimized.value = true;
  }

  /// Invokes the session's cancel hook. Does not end the session; the owning
  /// flow's completion path calls [end].
  void cancel() => session.value?.onCancel();

  /// Cancels the active work and clears all state immediately. Stop actions
  /// use this so the UI disappears without waiting for the owning flow to
  /// observe the cancel; the flow's later [end] is a no-op.
  void stop() {
    final wasActive = isActive;
    cancel();
    end();
    if (wasActive) status.value = ScanSessionStatus.cancelled;
  }

  /// The [generation] flow finished all of its work: record [outcome], play
  /// the pill's completion outro and close the session. Background follow-up
  /// work (covers, audio preload, metadata) is not part of the session.
  void finish(int generation, ScanSessionResult outcome) {
    if (!isCurrent(generation)) return;
    result.value = outcome;
    markCompleted();
    status.value = ScanSessionStatus.complete;
    end(generation);
  }

  /// The [generation] scan found its storage unplugged.
  void markUnavailable(int generation) {
    if (!isCurrent(generation)) return;
    status.value = ScanSessionStatus.unavailable;
    end(generation);
  }

  /// The [generation] flow threw.
  void fail(int generation) {
    if (!isCurrent(generation)) return;
    status.value = ScanSessionStatus.failed;
    end(generation);
  }

  /// The user saw the outcome (Done): back to [ScanSessionStatus.idle]. A
  /// running session is not affected.
  void dismiss() {
    if (status.value == ScanSessionStatus.running) return;
    status.value = ScanSessionStatus.idle;
    result.value = null;
  }

  /// Clears session state. When [generation] is given, a stale flow's end is
  /// ignored and cannot clear a newer session. A session that ends without
  /// [finish]/[fail]/[markUnavailable] goes back to idle.
  void end([int? generation]) {
    if (generation != null && generation != _generation) return;
    session.value = null;
    progress.value = null;
    minimized.value = false;
    postProcessing.value = false;
    if (status.value == ScanSessionStatus.running) {
      status.value = ScanSessionStatus.idle;
    }
  }
}
