import 'package:isar_community/isar.dart';

part 'recently_played_entity.g.dart';

/// Database entity for storing recently played song history.
@collection
class RecentlyPlayedEntity {
  Id id = Isar.autoIncrement;

  /// Song ID (references SongEntity.id)
  @Index()
  late int songId;

  @Index()
  String? eventId;

  /// Measured listen time for linked plays; null preserves legacy estimates.
  int? listenedMs;

  /// Timestamp when the song was played
  @Index()
  late DateTime playedAt;
}
