import 'package:flutter/material.dart';

import 'package:flick/core/theme/lokal_tokens.dart';

/// Lokal's placeholder for missing album art: a centred music note.
///
/// The class keeps its historical name so its many call sites (and the
/// [CachedImageWidget] fallbacks) need no change, but it no longer draws the
/// Flick logo. The note takes [color] when given, else the Lokal muted
/// colour (`context.lokal`, which falls back to the dark Lokal tokens
/// outside a Lokal-themed subtree), scaled to [size] and dimmed by
/// [opacity].
class FlickArtworkPlaceholder extends StatelessWidget {
  const FlickArtworkPlaceholder({
    super.key,
    this.size = 48,
    this.opacity = 1.0,
    this.color,
  });

  final double size;
  final double opacity;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final note = ExcludeSemantics(
      child: Icon(
        Icons.music_note_rounded,
        size: size,
        color: color ?? context.lokal.muted,
      ),
    );
    if (opacity >= 1.0) return Center(child: note);
    return Center(
      child: Opacity(opacity: opacity.clamp(0.0, 1.0), child: note),
    );
  }
}
