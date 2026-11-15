import '../models/song.dart';
import 'lyrics_matching.dart';

String _normalize(Object? value) {
  final widthFold = String.fromCharCodes(
    (value ?? '').toString().runes.map(
      (c) => c >= 0xFF01 && c <= 0xFF5E ? c - 0xFEE0 : c,
    ),
  );
  return lyricsMatchName(widthFold.replaceAll(RegExp(r'[\u0300-\u036F]'), ''));
}

/// Desktop's Bini scoring, including localized titles/artists and timing quality.
Map? pickBiniLyrics(List results, Song song) {
  final title = _normalize(lyricsSearchTitle(song.title));
  final artist = _normalize(lyricsSearchArtist(song.artist));
  Map? best;
  var bestScore = -double.infinity;
  for (var i = 0; i < results.length; i++) {
    final hit = results[i];
    if (hit is! Map) continue;
    var score = 0.0;
    final name = _normalize(
      lyricsSearchTitle(hit['track_name']?.toString() ?? ''),
    );
    if (name == title) {
      score += 4;
    } else if (name.isNotEmpty &&
        title.isNotEmpty &&
        (name.startsWith(title) || title.startsWith(name))) {
      score += 2;
    } else {
      score -= 2;
    }
    final by = _normalize(hit['artist_name']);
    if (by.isNotEmpty &&
        artist.isNotEmpty &&
        (by == artist || by.contains(artist) || artist.contains(by)))
      score += 2;
    final duration = (hit['duration'] as num?)?.toDouble();
    if (song.duration > Duration.zero && duration != null) {
      final diff = (duration - song.duration.inMilliseconds / 1000).abs();
      if (diff <= 2) {
        score += 3;
      } else if (diff <= 5) {
        score += 1;
      } else if (diff > 15) {
        score -= 5;
      }
    }
    score += switch (hit['timing_type']?.toString().toLowerCase()) {
      'word' => 3,
      'line' => 1,
      'none' => -2,
      _ => 0,
    };
    score -= i * .1;
    if (score > bestScore) {
      bestScore = score;
      best = hit;
    }
  }
  return bestScore > -1 ? best : null;
}
