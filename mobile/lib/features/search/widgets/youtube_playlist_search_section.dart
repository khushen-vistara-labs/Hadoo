import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/features/discovery/lastfm_discovery.dart';
import 'package:flick/features/discovery/youtube_music_playlists_screen.dart';
import 'package:flick/features/hadoo/youtube_library_provider.dart';
import 'package:flick/features/konnekted/konnekted_discovery.dart';

class YoutubePlaylistSearchSection extends ConsumerStatefulWidget {
  const YoutubePlaylistSearchSection({
    super.key,
    required this.query,
    required this.search,
    required this.onOpen,
  });
  final String query;
  final Future<List<LokalDiscoveryMix>> Function(String) search;
  final ValueChanged<LokalDiscoveryMix> onOpen;

  @override
  ConsumerState<YoutubePlaylistSearchSection> createState() =>
      _PlaylistSearchState();
}

class _PlaylistSearchState extends ConsumerState<YoutubePlaylistSearchSection> {
  late Future<List<LokalDiscoveryMix>> _results;
  @override
  void initState() {
    super.initState();
    _results = widget.search(widget.query);
  }

  @override
  void didUpdateWidget(covariant YoutubePlaylistSearchSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query || oldWidget.search != widget.search) {
      _results = widget.search(widget.query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(youtubeLibraryProvider).value;
    final account = ref
        .watch(konnektedYoutubeMusicAccountProvider)
        ?.session
        .accountKey;
    final query = widget.query.toLowerCase();
    final own =
        (library?.account == account ? library?.playlists : null)
            ?.where((p) => p.title.toLowerCase().contains(query))
            .toList() ??
        <LokalDiscoveryMix>[];
    return FutureBuilder<List<LokalDiscoveryMix>>(
      future: _results,
      builder: (context, snapshot) {
        final seen = <String>{};
        final playlists = [
          for (final playlist in [...own, ...?snapshot.data])
            if (!playlist.id.startsWith('RD') && seen.add(playlist.id))
              playlist,
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'PLAYLISTS // YOUTUBE',
                style: TextStyle(color: context.lokal.accent),
              ),
            ),
            if (snapshot.connectionState != ConnectionState.done)
              const LinearProgressIndicator(),
            if (snapshot.hasError)
              const Text('YouTube playlist search is unavailable. Try again.'),
            if (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError &&
                playlists.isEmpty)
              const Text('No playlists found on YouTube Music.'),
            for (final playlist in playlists)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: YoutubePlaylistArtwork(url: playlist.artworkUrl),
                title: Text(
                  playlist.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  [
                    'Playlist',
                    'YouTube Music',
                    if (playlist.author.isNotEmpty) playlist.author,
                  ].join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => widget.onOpen(playlist),
              ),
          ],
        );
      },
    );
  }
}
