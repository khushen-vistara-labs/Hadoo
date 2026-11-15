enum PlaybackSource {
  album,
  artist,
  folder,
  playlist,
  allSongs,
  network,
  unknown;

}

class PlaybackContext {
  final PlaybackSource source;
  final String? sourceId;
  final String? sourceName;

  const PlaybackContext({
    required this.source,
    this.sourceId,
    this.sourceName,
  });

  static const unknown = PlaybackContext(source: PlaybackSource.unknown);

  PlaybackContext copyWith({
    PlaybackSource? source,
    String? sourceId,
    String? sourceName,
  }) {
    return PlaybackContext(
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      sourceName: sourceName ?? this.sourceName,
    );
  }
}
