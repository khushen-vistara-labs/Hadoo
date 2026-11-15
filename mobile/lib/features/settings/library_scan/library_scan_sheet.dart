import 'package:flutter/material.dart';

import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/l10n/l10n.dart';
import 'package:flick/services/library_scanner_service.dart' show ScanProgress;
import 'package:flick/services/scan_session_controller.dart';

import 'library_scan_flow.dart' show scanResultHeadline;

/// The scan's sheet: live progress while the session runs, then its outcome
/// with a Done button, in place on the same route.
///
/// Every button pops this sheet's own route (on the root navigator), never
/// the page underneath. Closing it while the scan runs hands progress to the
/// floating pill; closing it afterwards clears the outcome.
class LibraryScanSheet extends StatelessWidget {
  const LibraryScanSheet({super.key, required this.generation});

  /// The session this sheet reports.
  final int generation;

  /// Shows the sheet for [generation]; completes once it is closed.
  static Future<void> show(BuildContext context, {required int generation}) {
    final session = ScanSessionController.instance;
    final t = context.lokal;
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: t.surface,
      builder: (_) => LibraryScanSheet(generation: generation),
    ).whenComplete(() {
      if (session.isCurrent(generation)) {
        session.overlayDismissed(generation);
      } else {
        session.dismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = ScanSessionController.instance;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: ListenableBuilder(
          listenable: Listenable.merge([c.status, c.progress, c.result]),
          builder: (context, _) {
            final running =
                c.status.value == ScanSessionStatus.running &&
                c.isCurrent(generation);
            final title = c.session.value?.title ?? c.result.value?.title;
            return AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: running
                  ? _Running(
                      title: title ?? 'Scanning',
                      kind: c.session.value?.kind ?? ScanSessionKind.scan,
                      progress: c.progress.value,
                      onHide: () => Navigator.of(context).pop(),
                      onStop: () {
                        c.stop();
                        Navigator.of(context).pop();
                      },
                    )
                  : _Outcome(
                      status: c.status.value,
                      result: c.result.value,
                      title: title,
                      onDone: () => Navigator.of(context).pop(),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _Running extends StatelessWidget {
  const _Running({
    required this.title,
    required this.kind,
    required this.progress,
    required this.onHide,
    required this.onStop,
  });

  final String title;
  final ScanSessionKind kind;
  final ScanProgress? progress;
  final VoidCallback onHide;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    final p = progress;
    final total = p?.totalFiles ?? 0;
    final done = p?.filesProcessed ?? 0;
    final counting = p == null || (total == 0 && done == 0);
    final saving = total > 0 && done >= total;
    final phase = counting
        ? (kind == ScanSessionKind.scan
              ? 'Looking for music…'
              : 'Getting ready…')
        : saving
        ? 'Saving to your library…'
        : (p.phase ?? 'Reading files');
    final counts = <String>[
      if (total > 0) '$done / $total' else if (done > 0) '$done checked',
      if (kind == ScanSessionKind.scan && (p?.newSongs ?? 0) > 0)
        '${p!.newSongs} new',
      if ((p?.foldersTotal ?? 0) > 1)
        'folder ${p!.foldersCompleted ?? 0} of ${p.foldersTotal}',
    ];

    return Column(
      key: const ValueKey('scan-sheet-running'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(switch (kind) {
          ScanSessionKind.scan => 'SCANNING',
          ScanSessionKind.preload => 'PREPARING AUDIO',
          ScanSessionKind.replayGain => 'REPLAYGAIN',
        }, style: LokalTheme.label(t, color: t.accent)),
        const SizedBox(height: 6),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: LokalTheme.sans,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
            color: t.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          phase,
          style: TextStyle(
            fontFamily: LokalTheme.sans,
            fontSize: 13.5,
            color: t.muted,
          ),
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: total > 0 ? p!.progressFraction : null,
            minHeight: 6,
            backgroundColor: t.surface3,
            valueColor: AlwaysStoppedAnimation(t.accent),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          counts.isEmpty ? ' ' : counts.join(' · ').toUpperCase(),
          style: LokalTheme.label(t, size: 11),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: onHide,
                style: TextButton.styleFrom(
                  foregroundColor: t.text,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Hide'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: onStop,
                style: OutlinedButton.styleFrom(
                  foregroundColor: t.red,
                  side: BorderSide(color: t.red.withValues(alpha: .5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Stop'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.status,
    required this.result,
    required this.title,
    required this.onDone,
  });

  final ScanSessionStatus status;
  final ScanSessionResult? result;
  final String? title;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    final r = result;
    final (
      IconData icon,
      Color color,
      String headline,
      String? detail,
    ) = switch (status) {
      ScanSessionStatus.unavailable => (
        Icons.usb_off_rounded,
        t.muted,
        'Storage not connected',
        '${title ?? 'This folder'} is offline. Its songs stay in your '
            'library until it is back.',
      ),
      ScanSessionStatus.failed => (
        Icons.error_outline_rounded,
        t.red,
        'The scan stopped',
        'Something went wrong. Try again.',
      ),
      ScanSessionStatus.cancelled => (
        Icons.stop_circle_outlined,
        t.muted,
        'Scan stopped',
        null,
      ),
      _ when r != null => (
        Icons.check_circle_rounded,
        t.accent,
        scanResultHeadline(r),
        _detail(r),
      ),
      _ => (Icons.check_circle_rounded, t.accent, 'Done', null),
    };
    final emptyLibrary =
        r != null &&
        status == ScanSessionStatus.complete &&
        r.kind == ScanSessionKind.scan &&
        r.totalSongs == 0;
    final background =
        r != null &&
        status == ScanSessionStatus.complete &&
        r.kind == ScanSessionKind.scan &&
        r.newSongs > 0;

    return Column(
      key: ValueKey('scan-sheet-${status.name}'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icon, size: 44, color: color),
        const SizedBox(height: 12),
        if (status == ScanSessionStatus.complete && r != null) ...[
          Text(
            r.kind == ScanSessionKind.scan
                ? 'SCAN COMPLETE'
                : r.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: LokalTheme.label(t, color: t.accent),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          headline,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: LokalTheme.sans,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -.6,
            color: t.text,
          ),
        ),
        if (detail != null) ...[
          const SizedBox(height: 6),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: LokalTheme.sans,
              fontSize: 13.5,
              height: 1.4,
              color: t.muted,
            ),
          ),
        ],
        if (emptyLibrary) ...[
          const SizedBox(height: 10),
          Text(
            'No music found. Check that the folder has audio files, or turn '
            'on Deep scan in Settings › Library.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, height: 1.4, color: t.muted),
          ),
        ],
        if (background) ...[
          const SizedBox(height: 10),
          Text(
            'Covers and song details keep filling in in the background.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: t.muted2),
          ),
        ],
        const SizedBox(height: 22),
        FilledButton(
          onPressed: onDone,
          style: FilledButton.styleFrom(
            backgroundColor: t.accent,
            foregroundColor: t.onAccent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: const StadiumBorder(),
          ),
          child: const Text(
            'Done',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  static String _detail(ScanSessionResult r) {
    if (r.kind != ScanSessionKind.scan) {
      return 'Finished in ${_duration(r.elapsed)}.';
    }
    return [
      if (r.modifiedSongs > 0) '${r.modifiedSongs} updated',
      if (r.deletedSongs > 0) '${r.deletedSongs} removed',
      '${l10n.songsCount(r.totalSongs)} in your library',
    ].join(' · ');
  }

  static String _duration(Duration d) => d.inMinutes > 0
      ? '${d.inMinutes} min ${d.inSeconds.remainder(60)} s'
      : '${d.inSeconds} s';
}
