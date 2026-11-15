import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flick/models/song.dart';
import 'package:flick/models/playback_state.dart';
import 'package:flick/services/audio_engine.dart';
import 'package:flick/services/audio_engine_manager.dart';

class _Engine implements AudioEngine {
  bool failLoad = false;
  @override
  Stream<PlaybackState> get playbackStateStream => const Stream.empty();
  @override
  Future<void> load(Song track) async {
    if (failLoad) throw StateError('Source error');
  }

  @override
  Future<void> play() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> seek(Duration position) async {}
  @override
  Future<void> dispose() async {}
  @override
  void updateTrack(Song track) {}
}

void main() {
  test(
    'failed replacement cannot resume the previously loaded source',
    () async {
      final manager = AudioEngineManager(), engine = _Engine();
      addTearDown(manager.dispose);
      await manager.attachEngine(engine);
      final song = Song(
        id: 'song',
        title: 'Song',
        artist: 'Artist',
        duration: Duration.zero,
        fileType: 'FLAC',
      );
      await manager.playTrack(song);
      expect(manager.canResumeCurrentTrack, isTrue);
      engine.failLoad = true;
      await expectLater(manager.playTrack(song), throwsStateError);
      expect(manager.canResumeCurrentTrack, isFalse);
      engine.failLoad = false;
      await manager.playTrack(song);
      manager.invalidateLoadedTrack();
      expect(manager.canResumeCurrentTrack, isFalse);
      await manager.playTrack(song);
      await manager.stop();
      expect(manager.canResumeCurrentTrack, isFalse);
    },
  );
}
