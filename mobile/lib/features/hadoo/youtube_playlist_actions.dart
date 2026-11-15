import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flick/features/discovery/lastfm_discovery.dart';
import 'package:flick/features/discovery/youtube_music_sign_in.dart';
import 'package:flick/features/konnekted/konnekted_discovery.dart';
import 'package:flick/models/song.dart';

import 'youtube_library_provider.dart';

Future<bool> connectYoutubeForPlaylists(
  BuildContext context,
  WidgetRef ref,
) async {
  await ref.read(konnektedYoutubeMusicSessionProvider.future);
  if (ref.read(konnektedYoutubeMusicAccountProvider) != null) return true;
  if (!context.mounted) return false;
  final session = await YoutubeMusicSignInSheet.show(context);
  if (session == null || !context.mounted) return false;
  await ref.read(konnektedYoutubeMusicSessionProvider.notifier).save(session);
  return true;
}

Future<LokalDiscoveryMix?> createYoutubePlaylist(
  BuildContext context,
  WidgetRef ref, {
  List<Song> songs = const [],
}) async {
  if (!await connectYoutubeForPlaylists(context, ref) || !context.mounted)
    return null;
  LokalDiscoveryMix? created;
  await editYoutubePlaylistName(
    context,
    title: 'New YouTube playlist',
    action: 'Create on YouTube',
    description: 'Saved to your YouTube account. New playlists are private.',
    save: (name) async {
      created = await ref
          .read(youtubeLibraryProvider.notifier)
          .create(name, songs: songs);
    },
  );
  return created;
}

Future<bool> editYoutubePlaylistName(
  BuildContext context, {
  required String title,
  required String action,
  required Future<void> Function(String) save,
  String initial = '',
  String? description,
  String Function(Object error) errorMessage = youtubeLibraryError,
}) async {
  final controller = TextEditingController(text: initial);
  var busy = false;
  String? error;
  try {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialog) => StatefulBuilder(
            builder: (dialog, update) => PopScope(
              canPop: !busy,
              child: AlertDialog(
                title: Text(title),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (description != null) ...[
                        Text(description),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: controller,
                        autofocus: true,
                        enabled: !busy,
                        maxLength: 150,
                        decoration: const InputDecoration(
                          labelText: 'Playlist name',
                        ),
                      ),
                      if (error != null)
                        Semantics(liveRegion: true, child: Text(error!)),
                      if (busy) const LinearProgressIndicator(),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: busy ? null : () => Navigator.pop(dialog, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () async {
                            update(() {
                              busy = true;
                              error = null;
                            });
                            try {
                              await save(controller.text);
                              if (dialog.mounted) Navigator.pop(dialog, true);
                            } catch (failure) {
                              if (dialog.mounted)
                                update(() {
                                  busy = false;
                                  error = errorMessage(failure);
                                });
                            }
                          },
                    child: Text(action),
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  } finally {
    controller.dispose();
  }
}
