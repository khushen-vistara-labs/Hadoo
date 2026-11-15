import 'package:flick/models/playlist.dart';
import 'package:flick/models/song.dart';
import 'package:flick/providers/playlist_provider.dart';
import 'package:flick/services/online_playlist_reference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'youtube_playlist_actions.dart';

Future<Playlist?> createHadooPlaylist(
  BuildContext context,
  WidgetRef ref, {
  List<Song> songs = const [],
}) async {
  Playlist? created;
  await editYoutubePlaylistName(
    context,
    title: 'New Hadoo playlist',
    action: 'Create',
    description: 'Save songs from any source in Hadoo.',
    errorMessage: (_) => 'Enter a playlist name that you haven’t used yet.',
    save: (name) async {
      created = await ref
          .read(playlistsProvider.notifier)
          .createPlaylist(
            name,
            initialSongs: songs.map(hadooPlaylistEntry).toList(),
          );
      if (created == null) throw StateError('Playlist name unavailable');
    },
  );
  return created;
}
