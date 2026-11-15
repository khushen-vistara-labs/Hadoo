import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/features/hadoo/youtube_library_provider.dart';
import 'package:flick/features/hadoo/youtube_public_playlist_provider.dart';
import 'package:flick/features/hadoo/youtube_playlist_actions.dart';
import 'package:flick/features/konnekted/konnekted_data.dart';
import 'package:flick/features/konnekted/konnekted_discovery.dart';
import 'package:flick/features/konnekted/library/lokal_library_kit.dart';
import 'package:flick/features/playlist_links/playlist_link_models.dart';
import 'package:flick/features/songs/widgets/song_actions_bottom_sheet.dart';
import 'package:flick/features/spotify/provider_playlist_track_browser.dart';
import 'package:flick/models/song.dart';
import 'package:flick/widgets/lokal/lokal_toast.dart';

import 'lastfm_discovery.dart';

/// Playlists in the signed-in YouTube Music account.
class YoutubeMusicPlaylistsScreen extends ConsumerWidget {
  const YoutubeMusicPlaylistsScreen({super.key, required this.onPlay});
  final void Function(Song song, List<Song> queue) onPlay;

  void _open(BuildContext context, String account, LokalDiscoveryMix playlist) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => YoutubeMusicPlaylistScreen(
          playlist: playlist,
          accountId: account,
          onPlay: onPlay,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(konnektedYoutubeMusicSessionProvider);
    final account = session.value?.signedIn == true
        ? session.value!.accountKey
        : null;
    final library = ref.watch(youtubeLibraryProvider);
    final value = library.value?.account == account ? library.value : null;
    final items = value?.playlists ?? <LokalDiscoveryMix>[];
    return Scaffold(
      backgroundColor: context.lokal.bg,
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            tooltip: 'New YouTube playlist',
            icon: const Icon(Icons.add),
            onPressed: () async {
              try {
                final created = await createYoutubePlaylist(context, ref);
                final current = ref.read(konnektedYoutubeMusicAccountProvider);
                if (created != null && current != null && context.mounted)
                  _open(context, current.session.accountKey, created);
              } catch (error) {
                if (context.mounted)
                  LokalToast.show(context, youtubeLibraryError(error));
              }
            },
          ),
          IconButton(
            tooltip: 'Refresh YouTube playlists',
            icon: const Icon(Icons.refresh),
            onPressed:
                account == null ||
                    library.isLoading ||
                    value?.refreshing == true
                ? null
                : () => ref.read(youtubeLibraryProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(youtubeLibraryProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 200),
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'YOUR YOUTUBE LIBRARY',
                style: TextStyle(color: context.lokal.accent),
              ),
            ),
            if (session.isLoading ||
                library.isLoading ||
                value?.refreshing == true)
              const LinearProgressIndicator(),
            if (account == null && !session.isLoading)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Sign in to see and create playlists in your YouTube account.',
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await connectYoutubeForPlaylists(context, ref);
                        } catch (error) {
                          if (context.mounted)
                            LokalToast.show(
                              context,
                              youtubeLibraryError(error),
                            );
                        }
                      },
                      child: const Text('Sign in to YouTube'),
                    ),
                  ],
                ),
              ),
            if (value?.error case final String error)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Semantics(liveRegion: true, child: Text(error)),
              ),
            if (account != null &&
                value != null &&
                items.isEmpty &&
                !value.refreshing &&
                value.error == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No YouTube playlists yet. Tap + to create one in your account.',
                ),
              ),
            for (final playlist in items)
              ListTile(
                leading: YoutubePlaylistArtwork(url: playlist.artworkUrl),
                title: Text(
                  playlist.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  playlist.author.isEmpty ? 'YouTube' : playlist.author,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(context, account!, playlist),
              ),
          ],
        ),
      ),
    );
  }
}

class YoutubePlaylistArtwork extends StatelessWidget {
  const YoutubePlaylistArtwork({super.key, required this.url});
  final String url;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 48,
    child: url.startsWith('https://')
        ? ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.queue_music),
            ),
          )
        : const Icon(Icons.queue_music),
  );
}

class YoutubeMusicPlaylistScreen extends ConsumerWidget {
  const YoutubeMusicPlaylistScreen({
    super.key,
    required this.playlist,
    required this.accountId,
    required this.onPlay,
    this.readOnly = false,
  });
  final LokalDiscoveryMix playlist;
  final String accountId;
  final bool readOnly;
  final void Function(Song song, List<Song> queue) onPlay;
  YoutubePlaylistKey get _key => (account: accountId, id: playlist.id);

  Future<void> _manage(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Only playlists you own or collaborate on can be edited.',
              ),
            ),
            ListTile(
              title: const Text('Rename on YouTube'),
              onTap: () => Navigator.pop(sheet, 'rename'),
            ),
            ListTile(
              title: const Text('Delete from YouTube'),
              onTap: () => Navigator.pop(sheet, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    try {
      if (action == 'rename') {
        await editYoutubePlaylistName(
          context,
          title: 'Rename YouTube playlist',
          action: 'Save to YouTube',
          initial: playlist.title,
          save: (name) => ref
              .read(youtubeLibraryProvider.notifier)
              .rename(playlist.id, name),
        );
      } else if (action == 'delete') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialog) => AlertDialog(
            title: const Text('Delete from YouTube?'),
            content: Text(
              'Delete “${playlist.title}” from your YouTube account?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialog, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialog, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) return;
        await ref.read(youtubeLibraryProvider.notifier).delete(playlist.id);
        if (context.mounted) Navigator.pop(context);
      }
    } catch (error) {
      if (context.mounted) LokalToast.show(context, youtubeLibraryError(error));
    }
  }

  Future<void> _trackActions(
    BuildContext context,
    WidgetRef ref,
    LokalDiscoveryTrack track,
    bool editable,
  ) async {
    final library = KonnektedLibraryIndex.of(
      ref.read(konnektedLibraryProvider).value ?? const <Song>[],
    );
    final song = library.match(track) ?? discoveryPendingSong(track);
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Song options'),
              onTap: () => Navigator.pop(sheet, 'options'),
            ),
            if (editable && track.setVideoId != null)
              ListTile(
                title: const Text('Remove from YouTube playlist'),
                onTap: () => Navigator.pop(sheet, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (action == 'options') {
      await SongActionsBottomSheet.show(
        context,
        song,
        queueActions: false,
        hideMediaActions: true,
      );
    } else if (action == 'remove') {
      try {
        await ref
            .read(youtubeLibraryProvider.notifier)
            .remove(playlist.id, track);
        if (context.mounted)
          LokalToast.show(context, 'Removed from your YouTube playlist.');
      } catch (error) {
        if (context.mounted)
          LokalToast.show(context, youtubeLibraryError(error));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(konnektedYoutubeMusicAccountProvider);
    if ((!readOnly || accountId != 'public') &&
        api?.session.accountKey != accountId)
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('YouTube account changed. Reopen Playlists.'),
        ),
      );
    final result = readOnly
        ? ref.watch(youtubePublicPlaylistDetailsProvider(playlist.id))
        : ref.watch(youtubePlaylistDetailsProvider(_key));
    void refresh() => readOnly
        ? ref.invalidate(youtubePublicPlaylistDetailsProvider(playlist.id))
        : ref.invalidate(youtubePlaylistDetailsProvider(_key));
    final details = result.value;
    final tracks = details?.tracks ?? <LokalDiscoveryTrack>[];
    final current =
        ref
            .watch(youtubeLibraryProvider)
            .value
            ?.playlists
            .where((p) => p.id == playlist.id)
            .firstOrNull ??
        playlist;
    void play(List<int> indices, int start) {
      if (indices.isEmpty || start < 0 || start >= indices.length) return;
      final library = KonnektedLibraryIndex.of(
        ref.read(konnektedLibraryProvider).value ?? const <Song>[],
      );
      final queue = [
        for (final i in indices)
          library.match(tracks[i]) ?? discoveryPendingSong(tracks[i]),
      ];
      onPlay(queue[start], queue);
    }

    return Scaffold(
      backgroundColor: context.lokal.bg,
      body: details == null
          ? SafeArea(
              child: Column(
                children: [
                  LokalPageBar(
                    actions: [
                      LokalRoundAction(
                        icon: Icons.refresh,
                        label: 'Refresh playlist',
                        onPressed: refresh,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: result.hasError
                          ? Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(youtubeLibraryError(result.error!)),
                            )
                          : const CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            )
          : ProviderPlaylistTrackBrowser(
              tracks: tracks,
              source: PlaylistLinkSource.youtube,
              playlistId: playlist.id,
              accountId: accountId,
              header: Column(
                children: [
                  if (details.loadError case final String error)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(error),
                    ),
                  ProviderPlaylistHeader(
                    playlistId: 'youtube:$accountId:${playlist.id}',
                    title: current.title,
                    coverUrl: current.artworkUrl,
                    owner: current.author.isEmpty ? 'YouTube' : current.author,
                    tracks: tracks,
                  ),
                ],
              ),
              headerActions: [
                LokalRoundAction(
                  icon: Icons.refresh,
                  label: 'Refresh playlist',
                  onPressed: refresh,
                ),
                if (!readOnly &&
                    details.loadError == null &&
                    (details.editable || playlist.id.startsWith('PL')))
                  LokalRoundAction(
                    icon: Icons.more_horiz,
                    label: 'Playlist options',
                    onPressed: () => unawaited(_manage(context, ref)),
                  ),
              ],
              artworkBuilder: (track) =>
                  YoutubePlaylistArtwork(url: track.artworkUrl),
              onPlay: play,
              onSongActions: (index) => unawaited(
                _trackActions(
                  context,
                  ref,
                  tracks[index],
                  !readOnly &&
                      details.loadError == null &&
                      (details.editable || playlist.id.startsWith('PL')),
                ),
              ),
            ),
    );
  }
}
