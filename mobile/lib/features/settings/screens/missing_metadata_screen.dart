import 'package:flutter/material.dart';

import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/data/repositories/song_repository.dart';
import 'package:flick/features/albums/widgets/identify_album_sheet.dart';
import 'package:flick/l10n/l10n.dart';
import 'package:flick/models/song.dart';
import 'package:flick/services/apple_music/album_identification_service.dart';
import 'package:flick/services/apple_music/auto_metadata_enricher.dart';
import 'package:flick/widgets/lokal/settings/lokal_settings_kit.dart';

/// Lists album folders still missing artist or album tags and opens the
/// identification sheet for each. Backed by the same grouping the background
/// auto-enricher uses, so ambiguous matches end up here.
class MissingMetadataScreen extends StatefulWidget {
  const MissingMetadataScreen({super.key});

  @override
  State<MissingMetadataScreen> createState() => _MissingMetadataScreenState();
}

class _MissingMetadataScreenState extends State<MissingMetadataScreen> {
  late Future<List<_UntaggedAlbum>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_UntaggedAlbum>> _load() async {
    final songs = await SongRepository().getAllSongs();
    final groups = AutoMetadataEnricher.groupMissingByFolder(songs);
    final albums = [
      for (final entry in groups.entries)
        _UntaggedAlbum(folder: entry.key, songs: entry.value),
    ];
    albums.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return albums;
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _identify(_UntaggedAlbum album) async {
    final result = await IdentifyAlbumSheet.show(
      context,
      songs: album.songs,
      initialArtist: album.artist,
      initialAlbum: album.album,
    );
    if (result != null) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<_UntaggedAlbum>>(
          future: _future,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState != ConnectionState.done;
            final albums = snapshot.data ?? const <_UntaggedAlbum>[];
            return ListView(
              padding: EdgeInsets.only(
                bottom: 40 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                LokalSettingsHeader(
                  title: l10n.fixMissingMetadata,
                  subtitle: loading || albums.isEmpty
                      ? null
                      : 'Tap an album to identify it with Apple Music.',
                ),
                if (loading)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: t.accent),
                    ),
                  )
                else if (albums.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Text(
                      l10n.everyAlbumHasArtistAndAlbum,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: t.muted),
                    ),
                  )
                else
                  LokalSettingsSection(
                    title: l10n.needsMetadata,
                    children: [
                      for (final album in albums)
                        LokalSettingLink(
                          icon: Icons.album_rounded,
                          label: album.title,
                          description: album.subtitle,
                          onTap: () => _identify(album),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UntaggedAlbum {
  _UntaggedAlbum({required this.folder, required this.songs});

  final String folder;
  final List<Song> songs;

  ({String artist, String album}) get _seeds =>
      AlbumIdentificationService.deriveFolderSeeds(songs);

  String get artist => _seeds.artist;

  String get album => _seeds.album;

  String get title => album.isNotEmpty ? album : l10n.unknownAlbum;

  String get subtitle {
    final count = songs.length;
    final files = l10n.files2(count);
    return artist.isEmpty ? files : '$files · $artist';
  }
}
