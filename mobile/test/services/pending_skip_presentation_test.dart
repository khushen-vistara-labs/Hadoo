import 'package:flutter_test/flutter_test.dart';
import 'package:flick/models/song.dart';
import 'package:flick/services/player_service.dart';
import 'package:flick/services/queue_pre_resolver.dart';

Song _track(String id, {bool pending = false}) => Song(
  id: id,
  title: id,
  artist: 'Artist',
  duration: const Duration(minutes: 3),
  fileType: pending ? 'ONLINE' : 'FLAC',
  sourcePackage: pending ? Song.pendingSourcePackage : null,
  filePath: pending ? null : '/music/$id.flac',
);

void main() {
  test('old decoder stop cannot snap back during pending forward skip', () {
    final old = _track('old');
    final next = _track('pending:next', pending: true);
    expect(shouldHoldPendingPresentation(next.id, old), true);
    expect(shouldHoldPendingPresentation(next.id, null), true);
    expect(shouldHoldPendingPresentation(next.id, next), true);
    final resolved = _track('ready:next');
    expect(shouldHoldPendingPresentation(resolved.id, old), true);
    expect(shouldHoldPendingPresentation(resolved.id, resolved), false);
    expect(shouldHoldPendingPresentation(null, old), false);
  });

  test('Discovery mix queues next four in playback order for preload', () {
    final playlist = [_track('now'),
      for (var i = 1; i <= 7; i++)
        _track('pending:$i', pending: true)];
    final ahead = upcomingSongs(playlist, 0, repeatAll: false);
    expect(ahead.map((song) => song.id),
        ['pending:1', 'pending:2', 'pending:3', 'pending:4']);
    final afterSkip = upcomingSongs(playlist, 1, repeatAll: false);
    expect(afterSkip.map((song) => song.id),
        ['pending:2', 'pending:3', 'pending:4', 'pending:5']);
  });
}
