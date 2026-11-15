import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'classipod_browse.dart';
import 'classipod_controller.dart';
import 'classipod_data.dart';
import 'classipod_wheel.dart';

/// Pushed above the main shell so its playback/runtime subscriptions stay alive.
class ClassipodScreen extends ConsumerStatefulWidget {
  const ClassipodScreen({super.key});

  static Route<void> route(BuildContext context) => PageRouteBuilder<void>(
    settings: const RouteSettings(name: '/classipod'),
    // No entry/exit animation, including when the system requests reduced motion.
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (_, _, _) => const ClassipodScreen(),
  );

  @override
  ConsumerState<ClassipodScreen> createState() => _ClassipodScreenState();
}

class _ClassipodScreenState extends ConsumerState<ClassipodScreen> {
  late final ClassipodController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ClassipodController(ref.read(classipodPlaybackProvider));
    ref.listenManual(
      classipodLibraryProvider,
      (_, next) => _controller.updateLibrary(next),
      fireImmediately: true,
    );
    ref.listenManual(
      classipodPlayerStateProvider,
      (_, next) => _controller.updatePlayer(next),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _back() {
    if (!_controller.back()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        ref.watch(classipodReduceMotionProvider) ||
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    final artwork = ref.watch(classipodArtworkProvider);
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff174b8c)),
        scaffoldBackgroundColor: const Color(0xffdce1e8),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => PopScope<void>(
          canPop: !_controller.canGoBack,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _controller.back();
          },
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                  _controller.move(1),
              const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                  _controller.move(-1),
              const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                  _controller.move(1),
              const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                  _controller.move(-1),
              const SingleActivator(LogicalKeyboardKey.enter):
                  _controller.activate,
              const SingleActivator(LogicalKeyboardKey.space):
                  _controller.togglePlayPause,
              const SingleActivator(LogicalKeyboardKey.escape): _back,
            },
            child: Focus(
              autofocus: true,
              child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: const Text('Classipod'),
                  actions: [
                    TextButton.icon(
                      key: const Key('classipod-exit'),
                      onPressed: () {
                        // PopScope guards nested pages, so first return to root.
                        while (_controller.back()) {}
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Exit'),
                    ),
                  ],
                ),
                body: SafeArea(
                  top: false,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final landscape = constraints.maxWidth >= 600;
                      final scale = math.max(
                        1.0,
                        MediaQuery.textScalerOf(context).scale(14) / 14,
                      );
                      final height = math.max(
                        260 * scale,
                        constraints.maxHeight - (landscape ? 24 : 356),
                      );
                      final display = SizedBox(
                        height: height,
                        child: _display(reduceMotion, artwork),
                      );
                      final wheel = ClassipodWheel(
                        controller: _controller,
                        onBack: _back,
                      );
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 920),
                            child: landscape
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(child: display),
                                      const SizedBox(width: 20),
                                      SizedBox(width: 260, child: wheel),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      display,
                                      const SizedBox(height: 16),
                                      wheel,
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _display(bool reduceMotion, ClassipodArtworkBuilder artwork) =>
      Material(
        color: const Color(0xfff5f8ee),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xff263343), width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ColoredBox(
              color: const Color(0xffc6d0db),
              child: Row(
                children: [
                  IconButton(
                    tooltip: _controller.canGoBack
                        ? 'Back to previous menu'
                        : 'Back to Library',
                    onPressed: _back,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        _controller.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (_controller.player.hasSong)
                    IconButton(
                      tooltip: 'Go to now playing',
                      onPressed: _controller.page == ClassipodPage.nowPlaying
                          ? null
                          : () => _controller.open(
                              ClassipodPage.nowPlaying,
                              'Now playing',
                            ),
                      icon: Icon(
                        _controller.player.isPlaying
                            ? Icons.graphic_eq
                            : Icons.pause,
                      ),
                    ),
                ],
              ),
            ),
            if (_controller.busy)
              const LinearProgressIndicator(
                semanticsLabel: 'Updating playback',
              ),
            if (_controller.playbackError != null)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _controller.playbackError!,
                    style: const TextStyle(color: Color(0xff98281a)),
                  ),
                ),
              ),
            Expanded(child: _content(reduceMotion, artwork)),
          ],
        ),
      );

  Widget _content(bool reduceMotion, ClassipodArtworkBuilder artwork) {
    final controller = _controller;
    if (controller.needsLibrary) {
      if (controller.library.isLoading) {
        return const _Message('Loading local library…', loading: true);
      }
      if (controller.library.hasError) {
        return _Message(
          'Couldn’t load your local library.',
          action: TextButton(
            onPressed: ref.read(classipodReloadProvider),
            child: const Text('Try again'),
          ),
        );
      }
      if (controller.itemCount == 0) {
        return const _Message(
          'No local music here yet.\nAdd music in Library → Manage library.',
        );
      }
    }
    if (controller.page == ClassipodPage.nowPlaying) {
      return _nowPlaying(artwork);
    }
    if (controller.page == ClassipodPage.queue && controller.tracks.isEmpty) {
      return const _Message(
        'The queue is empty.\nChoose a song from your local library.',
      );
    }
    if (controller.page == ClassipodPage.coverFlow) {
      return ClassipodCoverFlow(
        albums: controller.data!.albums,
        selected: controller.selected,
        onMove: controller.move,
        onOpen: controller.activate,
        artwork: artwork,
        reduceMotion: reduceMotion,
      );
    }
    final rows = switch (controller.page) {
      ClassipodPage.menu => [
        for (final entry in ClassipodController.menu)
          ClassipodRowData(entry.$1),
      ],
      ClassipodPage.albums => [
        for (final album in controller.data!.albums)
          ClassipodRowData(
            album.albumName,
            '${album.albumArtist} · ${album.songs.length} tracks',
          ),
      ],
      ClassipodPage.artists => [
        for (final artist in controller.data!.artists)
          ClassipodRowData(
            artist.isEmpty ? 'Unknown artist' : artist,
            '${controller.data!.artistSongs[artist]!.length} tracks',
          ),
      ],
      _ => [
        for (var i = 0; i < controller.tracks.length; i++)
          ClassipodRowData(
            controller.tracks[i].title,
            '${controller.page == ClassipodPage.queue && i == controller.player.currentIndex ? 'Current · ' : ''}'
            '${controller.tracks[i].artist} · ${controller.tracks[i].formattedDuration}',
          ),
      ],
    };
    return ClassipodList(
      key: ObjectKey(controller.pageIdentity),
      rows: rows,
      selected: controller.selected,
      onSelect: controller.busy ? null : controller.activate,
      reduceMotion: reduceMotion,
    );
  }

  Widget _nowPlaying(ClassipodArtworkBuilder artwork) {
    final player = _controller.player;
    final song = player.currentSong;
    if (song == null) {
      return const _Message(
        'No song playing.\nChoose a song from your local library.',
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox.square(
            dimension: 144,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: artwork(song),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(
              song.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Text(song.artist, textAlign: TextAlign.center),
          if (song.album?.isNotEmpty == true)
            Text(song.album!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: player.progress,
            semanticsLabel:
                'Playback progress: ${_time(player.position)} of ${_time(player.duration)}',
          ),
          const SizedBox(height: 6),
          Text(
            '${_time(player.position)} / ${_time(player.duration)} · '
            '${player.isPlaying ? 'Playing' : 'Paused'}',
          ),
          if (player.currentIndex >= 0 &&
              player.currentIndex < player.queue.length)
            Text('Track ${player.currentIndex + 1} of ${player.queue.length}'),
          TextButton.icon(
            onPressed: () => _controller.open(ClassipodPage.queue, 'Queue'),
            icon: const Icon(Icons.queue_music),
            label: Text('Queue (${player.queue.length})'),
          ),
        ],
      ),
    );
  }

  String _time(Duration duration) {
    final seconds = math.max(0, duration.inSeconds);
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}

class _Message extends StatelessWidget {
  const _Message(this.message, {this.loading = false, this.action});
  final String message;
  final bool loading;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading) const CircularProgressIndicator(),
          if (loading) const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text(message, textAlign: TextAlign.center),
          ),
          ?action,
        ],
      ),
    ),
  );
}
