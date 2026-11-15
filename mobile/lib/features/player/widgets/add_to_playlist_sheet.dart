import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/features/hadoo/youtube_library_provider.dart';
import 'package:flick/features/hadoo/hadoo_playlist_actions.dart';
import 'package:flick/providers/playlist_provider.dart';
import 'package:flick/services/online_playlist_reference.dart';
import 'package:flick/features/hadoo/youtube_playlist_actions.dart';
import 'package:flick/features/konnekted/konnekted_discovery.dart';
import 'package:flick/models/song.dart';
import 'package:flick/widgets/lokal/lokal_toast.dart';

/// Choose the playlist that owns these tracks.
class AddToPlaylistSheet extends ConsumerStatefulWidget {
  const AddToPlaylistSheet({super.key, required this.songs});
  final List<Song> songs;

  static Future<void> show(BuildContext context, Song song) =>
      showSongs(context, [song]);
  static Future<void> showSongs(BuildContext context, List<Song> songs) async {
    if (songs.isEmpty) return;
    await showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AddToPlaylistSheet(songs: songs),
    );
  }

  @override
  ConsumerState<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends ConsumerState<AddToPlaylistSheet> {
  bool _busy = false;
  String? _error;

  Future<void> _save(String? id, {required bool youtube}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      String message = 'Saved to your YouTube playlist.';
      if (!youtube) {
        final saved = id == null
            ? await createHadooPlaylist(context, ref, songs: widget.songs) !=
                  null
            : await ref
                  .read(playlistsProvider.notifier)
                  .addSongsToLocalPlaylist(
                    id,
                    widget.songs.map(hadooPlaylistEntry).toList(),
                  );
        if (!saved) {
          if (id != null && mounted) {
            setState(
              () => _error = 'This Hadoo playlist is no longer available.',
            );
          }
          return;
        }
        message = 'Saved to your Hadoo playlist.';
      } else if (id == null) {
        final created = await createYoutubePlaylist(
          context,
          ref,
          songs: widget.songs,
        );
        if (created == null) return;
      } else {
        final result = await ref
            .read(youtubeLibraryProvider.notifier)
            .add(id, widget.songs);
        message = result.message;
      }
      if (mounted) {
        LokalToast.show(context, message);
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = youtube
              ? youtubeLibraryError(error)
              : 'Couldn’t save to your Hadoo playlist. Try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    final hadoo = ref.watch(playlistsProvider);
    final canUseYoutube = widget.songs.every(
      (song) => youtubeVideoIdForSong(song) != null,
    );
    final session = canUseYoutube
        ? ref.watch(konnektedYoutubeMusicSessionProvider)
        : null;
    final user = session?.value;
    final account = user?.signedIn == true ? user!.accountKey : null;
    final library = account == null ? null : ref.watch(youtubeLibraryProvider);
    final value = library?.value?.account == account ? library?.value : null;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add to playlist',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (_busy || hadoo.isLoading) const LinearProgressIndicator(),
              if (_error case final String error)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Semantics(liveRegion: true, child: Text(error)),
                ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const ListTile(title: Text('Hadoo playlists')),
                    ListTile(
                      leading: Icon(Icons.add, color: t.accent),
                      title: const Text('New Hadoo playlist'),
                      onTap: _busy ? null : () => _save(null, youtube: false),
                    ),
                    for (final playlist in hadoo.value?.playlists ?? [])
                      if (!playlist.isNetworkSource)
                        ListTile(
                          leading: const Icon(Icons.queue_music),
                          title: Text(playlist.name),
                          subtitle: const Text('Hadoo playlist'),
                          onTap: _busy
                              ? null
                              : () => _save(playlist.id, youtube: false),
                        ),
                    if (canUseYoutube) ...[
                      const ListTile(title: Text('YouTube playlists')),
                      if (session?.isLoading == true ||
                          library?.isLoading == true)
                        const LinearProgressIndicator(),
                      if (value?.error case final String error)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(error),
                        ),
                      if (account == null && session?.isLoading != true)
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () async {
                                  try {
                                    await connectYoutubeForPlaylists(
                                      context,
                                      ref,
                                    );
                                  } catch (error) {
                                    if (mounted) {
                                      setState(
                                        () =>
                                            _error = youtubeLibraryError(error),
                                      );
                                    }
                                  }
                                },
                          child: const Text('Sign in to YouTube'),
                        ),
                      if (account != null)
                        ListTile(
                          leading: Icon(Icons.add, color: t.accent),
                          title: const Text('New YouTube playlist'),
                          onTap: _busy
                              ? null
                              : () => _save(null, youtube: true),
                        ),
                      for (final playlist in value?.playlists ?? [])
                        ListTile(
                          leading: const Icon(Icons.cloud_outlined),
                          title: Text(playlist.title),
                          subtitle: const Text('YouTube playlist'),
                          onTap: _busy
                              ? null
                              : () => _save(playlist.id, youtube: true),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
