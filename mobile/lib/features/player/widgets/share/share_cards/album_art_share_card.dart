import 'package:flutter/material.dart';
import 'package:flick/models/song.dart';

import '../share_template.dart';
import 'konnekted_share_card.dart';

class AlbumArtShareCard extends StatelessWidget {
  const AlbumArtShareCard({super.key, required this.song, this.albumArtPath});
  final Song song;
  final String? albumArtPath;

  @override
  Widget build(BuildContext context) => KonnektedShareCard(
    song: song,
    template: ShareTemplate.albumArt,
    albumArtPath: albumArtPath,
  );
}
