import 'package:flick/core/utils/artist_credits.dart';
import 'package:flutter/foundation.dart';
import 'package:flick/models/song.dart';
import 'package:flick/data/repositories/song_repository.dart';

String _key(String value) => value.trim().toLowerCase();

int _byTrack(Song a, Song b) {
  final disc = (a.discNumber ?? 1).compareTo(b.discNumber ?? 1);
  if (disc != 0) return disc;
  final track = (a.trackNumber ?? 9999).compareTo(b.trackNumber ?? 9999);
  return track != 0
      ? track
      : a.title.toLowerCase().compareTo(b.title.toLowerCase());
}

/// The library's albums, A to Z, each in track order.
List<AlbumGroup> lokalAlbums(Iterable<Song> library) {
  final groups = <String, List<Song>>{};
  for (final song in library) {
    final album = song.album?.trim();
    if (album == null || album.isEmpty) continue;
    final artist = song.albumArtist?.trim().isNotEmpty == true
        ? song.albumArtist!
        : song.artist;
    (groups['${_key(album)}|${_key(artist)}'] ??= []).add(song);
  }
  final albums = [
    for (final entry in groups.entries)
      AlbumGroup(
        key: entry.key,
        albumName: entry.value.first.album!.trim(),
        albumArtist: entry.value.first.albumArtist?.trim().isNotEmpty == true
            ? entry.value.first.albumArtist!
            : entry.value.first.artist,
        songs: entry.value..sort(_byTrack),
      ),
  ];
  albums.sort(
    (a, b) => a.albumName.toLowerCase().compareTo(b.albumName.toLowerCase()),
  );
  return albums;
}

/// One artist and their songs.
@immutable
class LokalArtist {
  const LokalArtist(this.name, this.songs);

  final String name;
  final List<Song> songs;
}

/// The library's credited performers, A to Z; collaborations share songs.
List<LokalArtist> lokalArtists(Iterable<Song> library) {
  final names = <String, String>{};
  final songs = <String, List<Song>>{};
  for (final song in library) {
    for (final name in songArtistNames(song)) {
      names.putIfAbsent(_key(name), () => name);
      (songs[_key(name)] ??= []).add(song);
    }
  }
  return [
    for (final entry in songs.entries)
      LokalArtist(names[entry.key]!, entry.value),
  ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}
