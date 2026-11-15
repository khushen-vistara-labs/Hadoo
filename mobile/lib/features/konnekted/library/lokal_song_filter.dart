import 'package:flick/models/song.dart';
import 'package:flick/widgets/lokal/lokal_quality.dart';

enum LokalSongLocation {
  all('All songs'),
  phone('Mobile'),
  pc('PC'),
  other('Other sources');

  const LokalSongLocation(this.label);
  final String label;

  bool includes(Song song) => switch (this) {
    all => true,
    phone =>
      !song.isNetworkSource &&
          (song.filePath?.isNotEmpty ?? false) &&
          !song.isPending,
    pc => song.sourceType == 'lokal',
    other => song.isNetworkSource && song.sourceType != 'lokal',
  };
}

/// Quality and exact PCM resolution share one mutually exclusive menu.
String libraryAudioFilterLabel(String filter) {
  if (filter == 'all') return 'All formats and qualities';
  if (filter.startsWith('quality:')) {
    return LokalQualityTier.values.byName(filter.substring(8)).label;
  }
  final parts = filter.split(':');
  final rate = int.parse(parts[2]) / 1000;
  return '${parts[1]}-bit / ${rate == rate.roundToDouble() ? rate.toInt() : rate} kHz';
}

List<String> libraryAudioFormats(Iterable<Song> songs) {
  final formats =
      <(int, int)>{
        for (final song in songs)
          if ((song.bitDepth ?? 0) > 0 && (song.sampleRate ?? 0) > 0)
            (song.bitDepth!, song.sampleRate!),
      }.toList()..sort((a, b) {
        final bits = a.$1.compareTo(b.$1);
        return bits != 0 ? bits : a.$2.compareTo(b.$2);
      });
  return [for (final (bits, rate) in formats) 'format:$bits:$rate'];
}

bool matchesLibraryFilters(
  Song song,
  LokalSongLocation location,
  String audioFilter,
) {
  if (!location.includes(song)) return false;
  if (audioFilter == 'all') return true;
  if (audioFilter.startsWith('quality:')) {
    return (LokalQualityTier.of(song) ?? LokalQualityTier.unknown).name ==
        audioFilter.substring(8);
  }
  return audioFilter == 'format:${song.bitDepth}:${song.sampleRate}';
}
