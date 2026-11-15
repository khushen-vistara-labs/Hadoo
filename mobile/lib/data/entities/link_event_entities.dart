import 'package:isar_community/isar.dart';

part 'link_event_entities.g.dart';

/// A play is immutable and deduplicated across every paired device.
@collection
class PlayEventEntity {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String eventId;
  late String deviceId;
  @Index()
  late String trackKey;
  String? fileHash;
  @Index()
  late int playedAt;
  late int msPlayed;
  late String source;
  late String trackJson;
}

/// Append-only library intent. Deletions are explicit tombstones, never a missing row.
@collection
class LibraryOpEntity {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String opId;
  late String deviceId;
  late String hlc;
  late String entity;
  @Index()
  late String entityId;
  late String op;
  late String fieldsJson;
}
