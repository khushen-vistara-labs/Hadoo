import 'package:flutter/material.dart';
import 'package:flick/widgets/lokal/lokal_toast.dart';
import 'package:flick/core/utils/navigation_helper.dart';
import 'package:flick/data/repositories/song_repository.dart';
import 'package:flick/features/konnekted/library/lokal_navigation.dart';
import 'package:flick/models/song.dart';
import 'package:flick/services/player_service.dart';
import 'package:flick/l10n/l10n.dart';

class PlayerNavigation {
  final PlayerService playerService;
  final SongRepository songRepository;

  const PlayerNavigation({
    required this.playerService,
    required this.songRepository,
  });

  Future<void> queueSong(BuildContext context, Song song) async {
    await playerService.addToQueue(song);
    if (!context.mounted) return;
    LokalToast.fromSnackBar(context, 
      SnackBar(
        content: Text(l10n.queued(song.title)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: l10n.viewQueue,
          onPressed: () {
            NavigationHelper.navigateToQueue(context);
          },
        ),
      ),
    );
  }

  Future<void> openQueue(BuildContext context) async {
    await NavigationHelper.navigateToQueue(context);
  }

  /// Opens the Library page of [song]'s artist (or [artistName]).
  Future<void> openArtistFromSong(
    BuildContext context,
    Song song, {
    String? artistName,
  }) => openLokalArtist(context, name: artistName, song: song);

  /// Opens the Library page of [song]'s album.
  Future<void> openAlbumFromSong(BuildContext context, Song song) =>
      openLokalAlbumForSong(context, song);
}
