import 'package:flutter/material.dart';
import 'package:flick/models/song.dart';

import '../share_template.dart';
import 'konnekted_share_card.dart';

class SolidColorShareCard extends StatelessWidget {
  const SolidColorShareCard({
    super.key,
    required this.song,
    this.albumArtPath,
    this.dominantColor,
  });
  final Song song;
  final String? albumArtPath;
  final Color? dominantColor;

  @override
  Widget build(BuildContext context) => KonnektedShareCard(
    song: song,
    template: ShareTemplate.solidColor,
    albumArtPath: albumArtPath,
    color: dominantColor,
  );
}
