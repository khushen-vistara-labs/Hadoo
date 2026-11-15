import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:flick/l10n/l10n.dart';
import 'package:flick/models/lokal_remote_state.dart';
import 'package:flick/providers/library_scanner_provider.dart';
import 'package:flick/providers/lokal_remote_provider.dart';
import 'package:flick/services/library_organizer.dart';
import 'package:flick/services/link/file_copy_notification.dart';
import 'package:flick/widgets/lokal/settings/lokal_settings_kit.dart';

class LibraryOrganizerScreen extends ConsumerStatefulWidget {
  const LibraryOrganizerScreen({super.key});
  @override
  ConsumerState<LibraryOrganizerScreen> createState() =>
      _LibraryOrganizerScreenState();
}

class _LibraryOrganizerScreenState
    extends ConsumerState<LibraryOrganizerScreen> {
  final _organizer = LibraryOrganizer();
  final _notification = FileCopyNotification();
  OrganizePlan? _plan;
  OrganizeResult? _result;
  String? _error;
  bool _loading = true, _running = false, _cancel = false;
  int _processed = 0;
  @override
  void initState() {
    super.initState();
    _preview();
  }

  bool get _otherJob =>
      ref.read(isScanningProvider) ||
      ref.read(lokalRemoteControllerProvider).fileCopyProgress.busy ||
      ref.read(lokalRemoteControllerProvider).syncProgress.busy;
  Future<void> _preview() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _plan = null;
    });
    try {
      if (_otherJob)
        throw StateError(
          'Wait for the current scan, sync or file copy to finish.',
        );
      final plan = await _organizer.preview();
      if (mounted) setState(() => _plan = plan);
    } catch (error) {
      if (mounted)
        setState(
          () => _error = error is StateError ? error.message.toString() : 'Could not read the library. Check folder access and try again.',
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _run() async {
    final plan = _plan;
    if (plan == null || plan.moves.isEmpty || _running) return;
    final approved = await showLokalConfirmSheet(
      context: context,
      title: 'Organize ${plan.moves.length} files?',
      message: 'Move these files into Artist/Album folders inside their current library folders. Existing files will not be overwritten. Likes, playlists and history keep their song IDs.',
      confirmLabel: 'Organize files',
    );
    if (!approved || !mounted) return;
    if (_otherJob) {
      setState(
        () =>
            _error = 'Wait for the current scan, sync or file copy to finish.',
      );
      return;
    }
    setState(() {
      _running = true;
      _cancel = false;
      _processed = 0;
      _error = null;
    });
    var completed = false;
    try {
      await _notification.begin(
        'Library',
        title: 'Organizing library',
        completeTitle: 'Library organized',
        pausedTitle: 'Library organization paused',
      );
      final result = await _organizer.run(
        plan,
        cancelled: () => _cancel,
        onProgress: (count, name) {
          if (mounted) setState(() => _processed = count);
          _notification.update(
            LinkCopyProgress(
              phase: LinkCopyPhase.copying,
              total: plan.moves.length,
              processed: count,
              currentTitle: name,
            ),
          );
        },
      );
      completed = !result.cancelled;
      if (mounted)
        setState(() {
          _result = result;
          _plan = null;
        });
    } catch (error) {
      if (mounted)
        setState(
          () => _error = error is StateError
              ? error.message.toString()
              : 'Organization stopped safely. Refresh the preview to retry.',
        );
    } finally {
      await _notification.finish(
        LinkCopyProgress(
          phase: completed ? LinkCopyPhase.complete : LinkCopyPhase.paused,
          received: _result?.moved ?? 0,
          failures: _result?.failures ?? const [],
        ),
        message:
            '${_result?.moved ?? 0} files organized · ${_result?.failures.length ?? 0} failed',
      );
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_running,
    child: Scaffold(
      appBar: AppBar(title: Text(lokalText('Organize existing library'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 160),
        children: [
          Text(
            lokalText('Move existing music into Artist/Album folders'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            lokalText(
              'Uses the same folders as new downloads. Album artist is used when available. Files stay inside their current selected library folder.',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lokalText(
              'The currently loaded song, document-only files, inaccessible files and CUE audio files are skipped. Change tracks and retry to organize the loaded song. Folder artwork and other sidecar files stay in place.',
            ),
          ),
          const SizedBox(height: 20),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (_plan case final plan?) ...[
            Text(
              '${plan.moves.length} files to move · ${plan.organized} already organized · ${plan.skipped} skipped',
            ),
            const SizedBox(height: 12),
            for (final move in plan.moves.take(8))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('${p.basename(move.source)}\n→ ${move.target}'),
              ),
            if (plan.moves.length > 8)
              Text('… ${plan.moves.length - 8} more files'),
            if (_running) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: plan.moves.isEmpty ? 0 : _processed / plan.moves.length,
              ),
              Text('$_processed / ${plan.moves.length}'),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _running || _loading || plan.moves.isEmpty
                  ? null
                  : _run,
              child: Text(lokalText('Organize files')),
            ),
          ],
          if (_result case final result?) ...[
            Text(
              '${result.moved} files organized · ${result.failures.length} could not be moved${result.cancelled ? " · stopped" : ""}',
            ),
            for (final failure in result.failures.take(8))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(failure),
              ),
          ],
          const SizedBox(height: 8),
          if (_running)
            TextButton(
              onPressed: () => setState(() => _cancel = true),
              child: Text(lokalText('Stop after this file')),
            )
          else
            TextButton(
              onPressed: _loading ? null : _preview,
              child: Text(lokalText('Refresh preview')),
            ),
        ],
      ),
    ),
  );
}
