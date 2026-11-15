import 'package:flick/features/library_jobs/library_jobs.dart';
import 'package:flick/features/library_jobs/library_job_control.dart';

import 'dart:async';

import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/features/konnekted/konnekted_data.dart';
import 'package:flick/features/konnekted/library/lokal_library_kit.dart';
import 'package:flick/models/song.dart';
import 'package:flick/providers/opt_in_source_provider.dart';
import 'package:flick/widgets/lokal/lokal_opt_in_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'music_video_match.dart';
import 'music_video_player_page.dart';
import 'music_video_providers.dart';

/// Desktop's Music videos: the library songs that have an official video,
/// as a thumbnail grid. Off until music videos are turned on.
class MusicVideosPage extends ConsumerWidget {
  const MusicVideosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(musicVideosEnabledProvider)) {
      return LokalLibraryPage(
        title: 'Videos',
        slivers: [
          SliverToBoxAdapter(
            child: LokalOptInCard(
              icon: Icons.smart_display_rounded,
              title: 'Turn on music videos',
              message:
                  'Hadoo searches YouTube Music for the official video of '
                  'your songs (only the artist and title are sent) and plays '
                  'it in YouTube’s embedded player.',
              actionLabel: 'Turn on music videos',
              onTurnOn: () =>
                  ref.read(musicVideosEnabledProvider.notifier).set(true),
            ),
          ),
        ],
      );
    }
    final songs = ref.watch(konnektedLibraryProvider).value ?? const <Song>[];
    final index = ref.watch(musicVideoIndexProvider);
    final withVideo = uniqueMusicVideoSongs(songs, index);
    final unchecked = songs
        .where((s) => !index.matches.containsKey(s.id))
        .length;
    return LokalLibraryPage(
      title: 'Videos',
      subtitle: withVideo.isEmpty ? null : lokalSongCount(withVideo.length),
      slivers: [
        const SliverToBoxAdapter(child: LibraryJobControl(LibraryJob.videos)),
        if (withVideo.isEmpty && !index.scanning)
          SliverToBoxAdapter(
            child: LokalEmptyState(
              icon: Icons.smart_display_rounded,
              title: 'No videos yet',
              message: unchecked > 0
                  ? 'Find videos to see which of your songs have one.'
                  : 'None of your songs has an official video we could find.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 16 / 13,
              ),
              itemCount: withVideo.length,
              itemBuilder: (context, i) {
                final song = withVideo[i];
                final id = index.videoFor(song.id)!;
                return _VideoTile(
                  song: song,
                  videoId: id,
                  onTap: () => openMusicVideo(context, song, id),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({
    required this.song,
    required this.videoId,
    required this.onTap,
  });

  final Song song;
  final String videoId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    return Semantics(
      button: true,
      label: 'Watch ${song.title} by ${song.artist}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      musicVideoThumbnail(videoId),
                      fit: BoxFit.cover,
                      cacheWidth: 480,
                      errorBuilder: (_, _, _) => ColoredBox(color: t.surface2),
                    ),
                    Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        size: 40,
                        color: Colors.white.withValues(alpha: .9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600, color: t.text),
            ),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: t.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Watch video" for a song menu: finds the video (remembered or a search)
/// and opens it, or says there is none. Only offered while videos are on.
Future<void> watchMusicVideo(BuildContext context, Song song) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final container = ProviderScope.containerOf(context, listen: false);
  String? id;
  try {
    id = await container.read(musicVideoIndexProvider.notifier).find(song);
  } catch (_) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('Couldn’t reach YouTube Music.')),
    );
    return;
  }
  if (id == null) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('No official video found for this song.')),
    );
    return;
  }
  if (!context.mounted) return;
  await openMusicVideo(context, song, id);
}
