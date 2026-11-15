import 'package:flutter/material.dart';
import 'package:flick/models/song.dart';

import '../share_template.dart';
import 'konnekted_share_card.dart';

class LyricShareCard extends StatelessWidget {
  const LyricShareCard({
    super.key,
    required this.song,
    this.albumArtPath,
    this.lyricLine,
    this.fontSizeOverride,
  });
  final Song song;
  final String? albumArtPath;
  final String? lyricLine;
  final double? fontSizeOverride;

  @override
  Widget build(BuildContext context) => KonnektedShareCard(
    song: song,
    template: ShareTemplate.lyric,
    albumArtPath: albumArtPath,
    lyric: lyricLine,
    lyricFontSize: fontSizeOverride,
  );
}
