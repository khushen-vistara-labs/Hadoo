// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_event_entities.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlayEventEntityCollection on Isar {
  IsarCollection<PlayEventEntity> get playEventEntitys => this.collection();
}

const PlayEventEntitySchema = CollectionSchema(
  name: r'PlayEventEntity',
  id: -5619018403901102741,
  properties: {
    r'deviceId': PropertySchema(
      id: 0,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'eventId': PropertySchema(id: 1, name: r'eventId', type: IsarType.string),
    r'fileHash': PropertySchema(
      id: 2,
      name: r'fileHash',
      type: IsarType.string,
    ),
    r'msPlayed': PropertySchema(id: 3, name: r'msPlayed', type: IsarType.long),
    r'playedAt': PropertySchema(id: 4, name: r'playedAt', type: IsarType.long),
    r'source': PropertySchema(id: 5, name: r'source', type: IsarType.string),
    r'trackJson': PropertySchema(
      id: 6,
      name: r'trackJson',
      type: IsarType.string,
    ),
    r'trackKey': PropertySchema(
      id: 7,
      name: r'trackKey',
      type: IsarType.string,
    ),
  },

  estimateSize: _playEventEntityEstimateSize,
  serialize: _playEventEntitySerialize,
  deserialize: _playEventEntityDeserialize,
  deserializeProp: _playEventEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'eventId': IndexSchema(
      id: -2707901133518603130,
      name: r'eventId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'eventId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'trackKey': IndexSchema(
      id: 994899472545006434,
      name: r'trackKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'trackKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'playedAt': IndexSchema(
      id: -3711549563919110219,
      name: r'playedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'playedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _playEventEntityGetId,
  getLinks: _playEventEntityGetLinks,
  attach: _playEventEntityAttach,
  version: '3.3.2',
);

int _playEventEntityEstimateSize(
  PlayEventEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.eventId.length * 3;
  {
    final value = object.fileHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.source.length * 3;
  bytesCount += 3 + object.trackJson.length * 3;
  bytesCount += 3 + object.trackKey.length * 3;
  return bytesCount;
}

void _playEventEntitySerialize(
  PlayEventEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.deviceId);
  writer.writeString(offsets[1], object.eventId);
  writer.writeString(offsets[2], object.fileHash);
  writer.writeLong(offsets[3], object.msPlayed);
  writer.writeLong(offsets[4], object.playedAt);
  writer.writeString(offsets[5], object.source);
  writer.writeString(offsets[6], object.trackJson);
  writer.writeString(offsets[7], object.trackKey);
}

PlayEventEntity _playEventEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlayEventEntity();
  object.deviceId = reader.readString(offsets[0]);
  object.eventId = reader.readString(offsets[1]);
  object.fileHash = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.msPlayed = reader.readLong(offsets[3]);
  object.playedAt = reader.readLong(offsets[4]);
  object.source = reader.readString(offsets[5]);
  object.trackJson = reader.readString(offsets[6]);
  object.trackKey = reader.readString(offsets[7]);
  return object;
}

P _playEventEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playEventEntityGetId(PlayEventEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playEventEntityGetLinks(PlayEventEntity object) {
  return [];
}

void _playEventEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  PlayEventEntity object,
) {
  object.id = id;
}

extension PlayEventEntityByIndex on IsarCollection<PlayEventEntity> {
  Future<PlayEventEntity?> getByEventId(String eventId) {
    return getByIndex(r'eventId', [eventId]);
  }

  PlayEventEntity? getByEventIdSync(String eventId) {
    return getByIndexSync(r'eventId', [eventId]);
  }

  Future<bool> deleteByEventId(String eventId) {
    return deleteByIndex(r'eventId', [eventId]);
  }

  bool deleteByEventIdSync(String eventId) {
    return deleteByIndexSync(r'eventId', [eventId]);
  }

  Future<List<PlayEventEntity?>> getAllByEventId(List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'eventId', values);
  }

  List<PlayEventEntity?> getAllByEventIdSync(List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'eventId', values);
  }

  Future<int> deleteAllByEventId(List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'eventId', values);
  }

  int deleteAllByEventIdSync(List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'eventId', values);
  }

  Future<Id> putByEventId(PlayEventEntity object) {
    return putByIndex(r'eventId', object);
  }

  Id putByEventIdSync(PlayEventEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'eventId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEventId(List<PlayEventEntity> objects) {
    return putAllByIndex(r'eventId', objects);
  }

  List<Id> putAllByEventIdSync(
    List<PlayEventEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'eventId', objects, saveLinks: saveLinks);
  }
}

extension PlayEventEntityQueryWhereSort
    on QueryBuilder<PlayEventEntity, PlayEventEntity, QWhere> {
  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhere> anyPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'playedAt'),
      );
    });
  }
}

extension PlayEventEntityQueryWhere
    on QueryBuilder<PlayEventEntity, PlayEventEntity, QWhereClause> {
  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhereClause>
  eventIdEqualTo(String eventId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'eventId', value: [eventId]),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhereClause>
  eventIdNotEqualTo(String eventId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [],
                upper: [eventId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [eventId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [eventId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [],
                upper: [eventId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhereClause>
  trackKeyEqualTo(String trackKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'trackKey', value: [trackKey]),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhereClause>
  trackKeyNotEqualTo(String trackKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'trackKey',
                lower: [],
                upper: [trackKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'trackKey',
                lower: [trackKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'trackKey',
                lower: [trackKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'trackKey',
                lower: [],
                upper: [trackKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhereClause>
  playedAtEqualTo(int playedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'playedAt', value: [playedAt]),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhereClause>
  playedAtNotEqualTo(int playedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playedAt',
                lower: [],
                upper: [playedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playedAt',
                lower: [playedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playedAt',
                lower: [playedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playedAt',
                lower: [],
                upper: [playedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhereClause>
  playedAtGreaterThan(int playedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'playedAt',
          lower: [playedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhereClause>
  playedAtLessThan(int playedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'playedAt',
          lower: [],
          upper: [playedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterWhereClause>
  playedAtBetween(
    int lowerPlayedAt,
    int upperPlayedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'playedAt',
          lower: [lowerPlayedAt],
          includeLower: includeLower,
          upper: [upperPlayedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PlayEventEntityQueryFilter
    on QueryBuilder<PlayEventEntity, PlayEventEntity, QFilterCondition> {
  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  deviceIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deviceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  deviceIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  deviceIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'deviceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deviceId', value: ''),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'deviceId', value: ''),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  eventIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  eventIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  eventIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  eventIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'eventId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  eventIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  eventIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  eventIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  eventIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'eventId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  eventIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'eventId', value: ''),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  eventIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'eventId', value: ''),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  fileHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fileHash'),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  fileHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fileHash'),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  fileHashEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fileHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  fileHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  fileHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  fileHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileHash',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  fileHashStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fileHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  fileHashEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fileHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  fileHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fileHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  fileHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fileHash',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  fileHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileHash', value: ''),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  fileHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fileHash', value: ''),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  msPlayedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'msPlayed', value: value),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  msPlayedGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'msPlayed',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  msPlayedLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'msPlayed',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  msPlayedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'msPlayed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  playedAtEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playedAt', value: value),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  playedAtGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  playedAtLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  playedAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  sourceEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  sourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  sourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  sourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'source',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  sourceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  sourceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  sourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  sourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'source',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'source', value: ''),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'source', value: ''),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'trackJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trackJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trackJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trackJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'trackJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'trackJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'trackJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'trackJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trackJson', value: ''),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'trackJson', value: ''),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'trackKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trackKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trackKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trackKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'trackKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'trackKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'trackKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'trackKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trackKey', value: ''),
      );
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterFilterCondition>
  trackKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'trackKey', value: ''),
      );
    });
  }
}

extension PlayEventEntityQueryObject
    on QueryBuilder<PlayEventEntity, PlayEventEntity, QFilterCondition> {}

extension PlayEventEntityQueryLinks
    on QueryBuilder<PlayEventEntity, PlayEventEntity, QFilterCondition> {}

extension PlayEventEntityQuerySortBy
    on QueryBuilder<PlayEventEntity, PlayEventEntity, QSortBy> {
  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy> sortByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  sortByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  sortByFileHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileHash', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  sortByFileHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileHash', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  sortByMsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msPlayed', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  sortByMsPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msPlayed', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  sortByPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedAt', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  sortByPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedAt', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  sortByTrackJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackJson', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  sortByTrackJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackJson', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  sortByTrackKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackKey', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  sortByTrackKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackKey', Sort.desc);
    });
  }
}

extension PlayEventEntityQuerySortThenBy
    on QueryBuilder<PlayEventEntity, PlayEventEntity, QSortThenBy> {
  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy> thenByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  thenByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  thenByFileHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileHash', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  thenByFileHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileHash', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  thenByMsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msPlayed', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  thenByMsPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msPlayed', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  thenByPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedAt', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  thenByPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedAt', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  thenByTrackJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackJson', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  thenByTrackJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackJson', Sort.desc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  thenByTrackKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackKey', Sort.asc);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QAfterSortBy>
  thenByTrackKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackKey', Sort.desc);
    });
  }
}

extension PlayEventEntityQueryWhereDistinct
    on QueryBuilder<PlayEventEntity, PlayEventEntity, QDistinct> {
  QueryBuilder<PlayEventEntity, PlayEventEntity, QDistinct> distinctByDeviceId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QDistinct> distinctByEventId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QDistinct> distinctByFileHash({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QDistinct>
  distinctByMsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'msPlayed');
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QDistinct>
  distinctByPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playedAt');
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QDistinct> distinctBySource({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QDistinct>
  distinctByTrackJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayEventEntity, PlayEventEntity, QDistinct> distinctByTrackKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackKey', caseSensitive: caseSensitive);
    });
  }
}

extension PlayEventEntityQueryProperty
    on QueryBuilder<PlayEventEntity, PlayEventEntity, QQueryProperty> {
  QueryBuilder<PlayEventEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlayEventEntity, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<PlayEventEntity, String, QQueryOperations> eventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventId');
    });
  }

  QueryBuilder<PlayEventEntity, String?, QQueryOperations> fileHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileHash');
    });
  }

  QueryBuilder<PlayEventEntity, int, QQueryOperations> msPlayedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'msPlayed');
    });
  }

  QueryBuilder<PlayEventEntity, int, QQueryOperations> playedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playedAt');
    });
  }

  QueryBuilder<PlayEventEntity, String, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<PlayEventEntity, String, QQueryOperations> trackJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackJson');
    });
  }

  QueryBuilder<PlayEventEntity, String, QQueryOperations> trackKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackKey');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLibraryOpEntityCollection on Isar {
  IsarCollection<LibraryOpEntity> get libraryOpEntitys => this.collection();
}

const LibraryOpEntitySchema = CollectionSchema(
  name: r'LibraryOpEntity',
  id: -9135385984303250558,
  properties: {
    r'deviceId': PropertySchema(
      id: 0,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'entity': PropertySchema(id: 1, name: r'entity', type: IsarType.string),
    r'entityId': PropertySchema(
      id: 2,
      name: r'entityId',
      type: IsarType.string,
    ),
    r'fieldsJson': PropertySchema(
      id: 3,
      name: r'fieldsJson',
      type: IsarType.string,
    ),
    r'hlc': PropertySchema(id: 4, name: r'hlc', type: IsarType.string),
    r'op': PropertySchema(id: 5, name: r'op', type: IsarType.string),
    r'opId': PropertySchema(id: 6, name: r'opId', type: IsarType.string),
  },

  estimateSize: _libraryOpEntityEstimateSize,
  serialize: _libraryOpEntitySerialize,
  deserialize: _libraryOpEntityDeserialize,
  deserializeProp: _libraryOpEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'opId': IndexSchema(
      id: -7257366839637970090,
      name: r'opId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'opId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'entityId': IndexSchema(
      id: 745355021660786263,
      name: r'entityId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entityId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _libraryOpEntityGetId,
  getLinks: _libraryOpEntityGetLinks,
  attach: _libraryOpEntityAttach,
  version: '3.3.2',
);

int _libraryOpEntityEstimateSize(
  LibraryOpEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.entity.length * 3;
  bytesCount += 3 + object.entityId.length * 3;
  bytesCount += 3 + object.fieldsJson.length * 3;
  bytesCount += 3 + object.hlc.length * 3;
  bytesCount += 3 + object.op.length * 3;
  bytesCount += 3 + object.opId.length * 3;
  return bytesCount;
}

void _libraryOpEntitySerialize(
  LibraryOpEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.deviceId);
  writer.writeString(offsets[1], object.entity);
  writer.writeString(offsets[2], object.entityId);
  writer.writeString(offsets[3], object.fieldsJson);
  writer.writeString(offsets[4], object.hlc);
  writer.writeString(offsets[5], object.op);
  writer.writeString(offsets[6], object.opId);
}

LibraryOpEntity _libraryOpEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LibraryOpEntity();
  object.deviceId = reader.readString(offsets[0]);
  object.entity = reader.readString(offsets[1]);
  object.entityId = reader.readString(offsets[2]);
  object.fieldsJson = reader.readString(offsets[3]);
  object.hlc = reader.readString(offsets[4]);
  object.id = id;
  object.op = reader.readString(offsets[5]);
  object.opId = reader.readString(offsets[6]);
  return object;
}

P _libraryOpEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _libraryOpEntityGetId(LibraryOpEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _libraryOpEntityGetLinks(LibraryOpEntity object) {
  return [];
}

void _libraryOpEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  LibraryOpEntity object,
) {
  object.id = id;
}

extension LibraryOpEntityByIndex on IsarCollection<LibraryOpEntity> {
  Future<LibraryOpEntity?> getByOpId(String opId) {
    return getByIndex(r'opId', [opId]);
  }

  LibraryOpEntity? getByOpIdSync(String opId) {
    return getByIndexSync(r'opId', [opId]);
  }

  Future<bool> deleteByOpId(String opId) {
    return deleteByIndex(r'opId', [opId]);
  }

  bool deleteByOpIdSync(String opId) {
    return deleteByIndexSync(r'opId', [opId]);
  }

  Future<List<LibraryOpEntity?>> getAllByOpId(List<String> opIdValues) {
    final values = opIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'opId', values);
  }

  List<LibraryOpEntity?> getAllByOpIdSync(List<String> opIdValues) {
    final values = opIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'opId', values);
  }

  Future<int> deleteAllByOpId(List<String> opIdValues) {
    final values = opIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'opId', values);
  }

  int deleteAllByOpIdSync(List<String> opIdValues) {
    final values = opIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'opId', values);
  }

  Future<Id> putByOpId(LibraryOpEntity object) {
    return putByIndex(r'opId', object);
  }

  Id putByOpIdSync(LibraryOpEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'opId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOpId(List<LibraryOpEntity> objects) {
    return putAllByIndex(r'opId', objects);
  }

  List<Id> putAllByOpIdSync(
    List<LibraryOpEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'opId', objects, saveLinks: saveLinks);
  }
}

extension LibraryOpEntityQueryWhereSort
    on QueryBuilder<LibraryOpEntity, LibraryOpEntity, QWhere> {
  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LibraryOpEntityQueryWhere
    on QueryBuilder<LibraryOpEntity, LibraryOpEntity, QWhereClause> {
  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterWhereClause> opIdEqualTo(
    String opId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'opId', value: [opId]),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterWhereClause>
  opIdNotEqualTo(String opId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'opId',
                lower: [],
                upper: [opId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'opId',
                lower: [opId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'opId',
                lower: [opId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'opId',
                lower: [],
                upper: [opId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterWhereClause>
  entityIdEqualTo(String entityId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'entityId', value: [entityId]),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterWhereClause>
  entityIdNotEqualTo(String entityId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityId',
                lower: [],
                upper: [entityId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityId',
                lower: [entityId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityId',
                lower: [entityId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityId',
                lower: [],
                upper: [entityId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension LibraryOpEntityQueryFilter
    on QueryBuilder<LibraryOpEntity, LibraryOpEntity, QFilterCondition> {
  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  deviceIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deviceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  deviceIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  deviceIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'deviceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deviceId', value: ''),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'deviceId', value: ''),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entity',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entity', value: ''),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entity', value: ''),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entityId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entityId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entityId', value: ''),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entityId', value: ''),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  fieldsJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fieldsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  fieldsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fieldsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  fieldsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fieldsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  fieldsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fieldsJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  fieldsJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fieldsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  fieldsJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fieldsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  fieldsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fieldsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  fieldsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fieldsJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  fieldsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fieldsJson', value: ''),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  fieldsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fieldsJson', value: ''),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  hlcEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hlc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  hlcGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hlc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  hlcLessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hlc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  hlcBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  hlcStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'hlc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  hlcEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'hlc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  hlcContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'hlc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  hlcMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'hlc',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  hlcIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hlc', value: ''),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  hlcIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'hlc', value: ''),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'op',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'op',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opLessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'op',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'op',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'op',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'op',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'op',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'op',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'op', value: ''),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'op', value: ''),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'opId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'opId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'opId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'opId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'opId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'opId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'opId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'opId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'opId', value: ''),
      );
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterFilterCondition>
  opIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'opId', value: ''),
      );
    });
  }
}

extension LibraryOpEntityQueryObject
    on QueryBuilder<LibraryOpEntity, LibraryOpEntity, QFilterCondition> {}

extension LibraryOpEntityQueryLinks
    on QueryBuilder<LibraryOpEntity, LibraryOpEntity, QFilterCondition> {}

extension LibraryOpEntityQuerySortBy
    on QueryBuilder<LibraryOpEntity, LibraryOpEntity, QSortBy> {
  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy> sortByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  sortByEntityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.desc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  sortByFieldsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldsJson', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  sortByFieldsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldsJson', Sort.desc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy> sortByHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy> sortByHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.desc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy> sortByOp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'op', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy> sortByOpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'op', Sort.desc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy> sortByOpId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opId', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  sortByOpIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opId', Sort.desc);
    });
  }
}

extension LibraryOpEntityQuerySortThenBy
    on QueryBuilder<LibraryOpEntity, LibraryOpEntity, QSortThenBy> {
  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy> thenByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  thenByEntityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.desc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  thenByFieldsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldsJson', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  thenByFieldsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldsJson', Sort.desc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy> thenByHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy> thenByHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.desc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy> thenByOp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'op', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy> thenByOpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'op', Sort.desc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy> thenByOpId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opId', Sort.asc);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QAfterSortBy>
  thenByOpIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opId', Sort.desc);
    });
  }
}

extension LibraryOpEntityQueryWhereDistinct
    on QueryBuilder<LibraryOpEntity, LibraryOpEntity, QDistinct> {
  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QDistinct> distinctByDeviceId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QDistinct> distinctByEntity({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entity', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QDistinct> distinctByEntityId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QDistinct>
  distinctByFieldsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fieldsJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QDistinct> distinctByHlc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hlc', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QDistinct> distinctByOp({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'op', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryOpEntity, LibraryOpEntity, QDistinct> distinctByOpId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'opId', caseSensitive: caseSensitive);
    });
  }
}

extension LibraryOpEntityQueryProperty
    on QueryBuilder<LibraryOpEntity, LibraryOpEntity, QQueryProperty> {
  QueryBuilder<LibraryOpEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LibraryOpEntity, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<LibraryOpEntity, String, QQueryOperations> entityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entity');
    });
  }

  QueryBuilder<LibraryOpEntity, String, QQueryOperations> entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<LibraryOpEntity, String, QQueryOperations> fieldsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fieldsJson');
    });
  }

  QueryBuilder<LibraryOpEntity, String, QQueryOperations> hlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hlc');
    });
  }

  QueryBuilder<LibraryOpEntity, String, QQueryOperations> opProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'op');
    });
  }

  QueryBuilder<LibraryOpEntity, String, QQueryOperations> opIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'opId');
    });
  }
}
