import 'package:flick/features/classipod/classipod_data.dart';
import 'package:flick/models/song.dart';
import 'package:flick/providers/player_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Test-only metadata. Production Classipod obtains Song objects from the library.
const alpha = Song(
  id: 'alpha',
  title: 'Alpha track',
  artist: 'Artist one',
  album: 'First album',
  albumArt: '/test/first.jpg',
  trackNumber: 2,
  filePath: '/test/alpha.flac',
  duration: Duration(minutes: 3),
  fileType: 'FLAC',
);
const beta = Song(
  id: 'beta',
  title: 'Beta track',
  artist: 'Artist one',
  album: 'First album',
  trackNumber: 1,
  filePath: '/test/beta.flac',
  duration: Duration(minutes: 4),
  fileType: 'FLAC',
);
const gamma = Song(
  id: 'gamma',
  title: 'Gamma track',
  artist: 'Artist two',
  album: 'Second album',
  filePath: '/test/gamma.mp3',
  duration: Duration(minutes: 2),
  fileType: 'MP3',
);

class RecordingPlayback implements ClassipodPlayback {
  Song? song;
  List<Song>? queue;
  PlaybackContext? context;
  final calls = <String>[];
  Future<void> Function()? onPlay;

  @override
  Future<void> play(
    Song song,
    List<Song> queue,
    PlaybackContext context,
  ) async {
    this.song = song;
    this.queue = queue;
    this.context = context;
    calls.add('play:${song.id}');
    await onPlay?.call();
  }

  @override
  Future<void> togglePlayPause() async => calls.add('toggle');
  @override
  Future<void> next() async => calls.add('next');
  @override
  Future<void> previous() async => calls.add('previous');
  @override
  Future<void> playQueueIndex(int index) async => calls.add('queue:$index');
}

class FixtureLibrary extends Notifier<AsyncValue<List<Song>>> {
  @override
  AsyncValue<List<Song>> build() => const AsyncData([gamma, alpha, beta]);
  void update(AsyncValue<List<Song>> value) => state = value;
}

final fixtureLibraryProvider =
    NotifierProvider<FixtureLibrary, AsyncValue<List<Song>>>(
      FixtureLibrary.new,
    );

class FixturePlayer extends Notifier<PlayerState> {
  @override
  PlayerState build() => const PlayerState();
  void update(PlayerState value) => state = value;
}

final fixturePlayerProvider = NotifierProvider<FixturePlayer, PlayerState>(
  FixturePlayer.new,
);
