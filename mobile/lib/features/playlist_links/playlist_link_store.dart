import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'playlist_link_models.dart';

abstract interface class PlaylistLinkMetadataStore {
  Future<List<PlaylistLinkRecord>> load();
  Future<void> save(List<PlaylistLinkRecord> records);
}

class PlaylistLinkStoreException implements Exception {
  final String message;

  const PlaylistLinkStoreException(this.message);

  @override
  String toString() => message;
}

class SharedPreferencesPlaylistLinkStore implements PlaylistLinkMetadataStore {
  static const String key = 'playlist_links.v1';

  @override
  Future<List<PlaylistLinkRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return [];
      final rawLinks = decoded['links'];
      if (rawLinks is! List) return [];
      return rawLinks
          .whereType<Map>()
          .map(
            (item) =>
                PlaylistLinkRecord.fromJson(Map<String, dynamic>.from(item)),
          )
          .where(
            (record) =>
                record.schemaVersion <= PlaylistLinkRecord.currentSchemaVersion,
          )
          .toList();
    } on Object catch (error) {
      throw PlaylistLinkStoreException(
        'Saved playlist links are invalid: $error',
      );
    }
  }

  @override
  Future<void> save(List<PlaylistLinkRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode({
      'schemaVersion': PlaylistLinkRecord.currentSchemaVersion,
      'links': records.map((record) => record.toJson()).toList(),
    });
    final saved = await prefs.setString(key, encoded);
    if (!saved) {
      throw const PlaylistLinkStoreException(
        'Could not save playlist link metadata.',
      );
    }
  }
}

class MemoryPlaylistLinkStore implements PlaylistLinkMetadataStore {
  List<PlaylistLinkRecord> _records;
  bool failWrites;

  MemoryPlaylistLinkStore({
    List<PlaylistLinkRecord> records = const [],
    this.failWrites = false,
  }) : _records = List<PlaylistLinkRecord>.from(records);

  @override
  Future<List<PlaylistLinkRecord>> load() async => List.from(_records);

  @override
  Future<void> save(List<PlaylistLinkRecord> records) async {
    if (failWrites) {
      throw const PlaylistLinkStoreException(
        'Injected metadata write failure.',
      );
    }
    _records = List<PlaylistLinkRecord>.from(records);
  }
}
