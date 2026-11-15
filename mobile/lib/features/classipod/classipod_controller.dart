import 'dart:math' as math;

import 'package:flick/models/song.dart';
import 'package:flick/providers/player_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'classipod_data.dart';

enum ClassipodPage {
  menu,
  songs,
  albums,
  artists,
  coverFlow,
  albumTracks,
  artistTracks,
  nowPlaying,
  queue,
}

class _Frame {
  _Frame(this.page, this.title, [this.key]);
  final ClassipodPage page;
  final String title;
  final String? key;
  int selected = 0;
}

/// Route-local navigation only; the existing player remains the source of truth.
class ClassipodController extends ChangeNotifier {
  ClassipodController(this.playback);

  final ClassipodPlayback playback;
  final _stack = [_Frame(ClassipodPage.menu, 'Local library')];
  AsyncValue<ClassipodLibrary> library = const AsyncLoading();
  PlayerState player = const PlayerState();
  bool busy = false;
  String? playbackError;
  bool _disposed = false;

  static const menu = <(String, ClassipodPage)>[
    ('Songs', ClassipodPage.songs),
    ('Albums', ClassipodPage.albums),
    ('Artists', ClassipodPage.artists),
    ('Cover Flow', ClassipodPage.coverFlow),
    ('Now playing', ClassipodPage.nowPlaying),
    ('Queue', ClassipodPage.queue),
  ];

  ClassipodPage get page => _stack.last.page;
  String get title => _stack.last.title;
  Object get pageIdentity => _stack.last;
  int get selected => _stack.last.selected;
  bool get canGoBack => _stack.length > 1;
  bool get needsLibrary =>
      page != ClassipodPage.menu &&
      page != ClassipodPage.nowPlaying &&
      page != ClassipodPage.queue;
  ClassipodLibrary? get data =>
      library.isLoading || library.hasError ? null : library.asData?.value;

  List<Song> get tracks => switch (page) {
    ClassipodPage.songs => data?.songs ?? const [],
    ClassipodPage.albumTracks =>
      data?.songsForAlbum(_stack.last.key) ?? const [],
    ClassipodPage.artistTracks =>
      data?.artistSongs[_stack.last.key] ?? const [],
    ClassipodPage.queue => player.queue,
    _ => const [],
  };

  int get itemCount => switch (page) {
    ClassipodPage.menu => menu.length,
    ClassipodPage.albums || ClassipodPage.coverFlow => data?.albums.length ?? 0,
    ClassipodPage.artists => data?.artists.length ?? 0,
    ClassipodPage.nowPlaying => 0,
    _ => tracks.length,
  };

  bool get canSelect =>
      !busy &&
      (itemCount > 0 ||
          (page == ClassipodPage.nowPlaying && player.queue.isNotEmpty));

  void updateLibrary(AsyncValue<ClassipodLibrary> value) {
    library = value;
    _clamp();
    notifyListeners();
  }

  void updatePlayer(PlayerState value) {
    player = value;
    _clamp();
    notifyListeners();
  }

  void _clamp() {
    _stack.last.selected = selected.clamp(0, math.max(0, itemCount - 1));
  }

  void move(int steps) => selectIndex(selected + steps);

  void selectIndex(int index) {
    final bounded = index.clamp(0, math.max(0, itemCount - 1)).toInt();
    if (selected == bounded) return;
    _stack.last.selected = bounded;
    notifyListeners();
  }

  void open(ClassipodPage page, String title, [String? key]) {
    _stack.add(_Frame(page, title, key));
    notifyListeners();
  }

  bool back() {
    if (!canGoBack) return false;
    _stack.removeLast();
    _clamp();
    notifyListeners();
    return true;
  }

  Future<void> activate([int? index]) async {
    if (index != null) {
      if (index < 0 || index >= itemCount) return;
      selectIndex(index);
    }
    if (!canSelect) return;
    switch (page) {
      case ClassipodPage.menu:
        final entry = menu[selected];
        open(entry.$2, entry.$1);
      case ClassipodPage.albums:
      case ClassipodPage.coverFlow:
        final album = data!.albums[selected];
        open(ClassipodPage.albumTracks, album.albumName, album.key);
      case ClassipodPage.artists:
        final artist = data!.artists[selected];
        open(ClassipodPage.artistTracks, artist, artist);
      case ClassipodPage.nowPlaying:
        open(ClassipodPage.queue, 'Queue');
      case ClassipodPage.queue:
        await _run(() => playback.playQueueIndex(selected), showPlayer: true);
      case ClassipodPage.songs:
      case ClassipodPage.albumTracks:
      case ClassipodPage.artistTracks:
        final queue = List<Song>.unmodifiable(tracks);
        final song = queue[selected];
        final context = PlaybackContext(
          source: switch (page) {
            ClassipodPage.albumTracks => PlaybackSource.album,
            ClassipodPage.artistTracks => PlaybackSource.artist,
            _ => PlaybackSource.allSongs,
          },
          sourceId: _stack.last.key,
          sourceName: title,
        );
        await _run(() => playback.play(song, queue, context), showPlayer: true);
    }
  }

  Future<void> togglePlayPause() => _transport(playback.togglePlayPause);
  Future<void> next() => _transport(playback.next);
  Future<void> previous() => _transport(playback.previous);

  Future<void> _transport(Future<void> Function() action) async {
    if (!player.hasSong || busy) return;
    await _run(action);
  }

  Future<void> _run(
    Future<void> Function() action, {
    bool showPlayer = false,
  }) async {
    final origin = _stack.last;
    busy = true;
    playbackError = null;
    notifyListeners();
    try {
      await action();
      if (!_disposed && showPlayer && identical(origin, _stack.last)) {
        // Selecting the queue from Now playing should not grow an endless stack.
        if (_stack.length > 1 &&
            _stack[_stack.length - 2].page == ClassipodPage.nowPlaying) {
          _stack.removeLast();
        } else {
          _stack.add(_Frame(ClassipodPage.nowPlaying, 'Now playing'));
        }
      }
    } catch (_) {
      if (!_disposed) playbackError = 'Playback couldn’t complete. Try again.';
    } finally {
      if (!_disposed) {
        busy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Accumulates short signed angular deltas. Crossing ±pi is a short movement,
/// not a full turn; the center dead zone prevents accidental large jumps.
class ClassipodWheelTracker {
  double? _angle;
  double _remainder = 0;
  static const detent = math.pi / 8;

  void reset() {
    _angle = null;
    _remainder = 0;
  }

  int update(double dx, double dy, double radius) {
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance < radius * .4 || distance > radius * 1.2) {
      reset();
      return 0;
    }
    final angle = math.atan2(dy, dx);
    final previous = _angle;
    _angle = angle;
    if (previous == null) return 0;
    var delta = angle - previous;
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    _remainder += delta;
    final detents = _remainder / detent;
    // Trigonometric rounding must not drop a detent at an exact boundary.
    final steps = (detents + detents.sign * 1e-9).truncate();
    _remainder -= steps * detent;
    return steps;
  }
}
