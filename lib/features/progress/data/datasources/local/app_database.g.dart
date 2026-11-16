// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SaveSlotsTable extends SaveSlots
    with TableInfo<$SaveSlotsTable, SaveSlotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaveSlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotIndexMeta = const VerificationMeta(
    'slotIndex',
  );
  @override
  late final GeneratedColumn<int> slotIndex = GeneratedColumn<int>(
    'slot_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerUserIdMeta = const VerificationMeta(
    'ownerUserId',
  );
  @override
  late final GeneratedColumn<String> ownerUserId = GeneratedColumn<String>(
    'owner_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GameProgress, String> payload =
      GeneratedColumn<String>(
        'payload',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<GameProgress>($SaveSlotsTable.$converterpayload);
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<String> caseId = GeneratedColumn<String>(
    'case_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sceneIdMeta = const VerificationMeta(
    'sceneId',
  );
  @override
  late final GeneratedColumn<String> sceneId = GeneratedColumn<String>(
    'scene_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playTimeSecondsMeta = const VerificationMeta(
    'playTimeSeconds',
  );
  @override
  late final GeneratedColumn<int> playTimeSeconds = GeneratedColumn<int>(
    'play_time_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _localRevisionMeta = const VerificationMeta(
    'localRevision',
  );
  @override
  late final GeneratedColumn<int> localRevision = GeneratedColumn<int>(
    'local_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _cloudRevisionMeta = const VerificationMeta(
    'cloudRevision',
  );
  @override
  late final GeneratedColumn<int> cloudRevision = GeneratedColumn<int>(
    'cloud_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtUtcMsMeta = const VerificationMeta(
    'updatedAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtcMs = GeneratedColumn<int>(
    'updated_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtUtcMsMeta = const VerificationMeta(
    'lastSyncedAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> lastSyncedAtUtcMs = GeneratedColumn<int>(
    'last_synced_at_utc_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    slotIndex,
    ownerUserId,
    schemaVersion,
    payload,
    caseId,
    chapterId,
    sceneId,
    playTimeSeconds,
    localRevision,
    cloudRevision,
    isDirty,
    updatedAtUtcMs,
    lastSyncedAtUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'save_slots';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaveSlotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot_index')) {
      context.handle(
        _slotIndexMeta,
        slotIndex.isAcceptableOrUnknown(data['slot_index']!, _slotIndexMeta),
      );
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
        _ownerUserIdMeta,
        ownerUserId.isAcceptableOrUnknown(
          data['owner_user_id']!,
          _ownerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('case_id')) {
      context.handle(
        _caseIdMeta,
        caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caseIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('scene_id')) {
      context.handle(
        _sceneIdMeta,
        sceneId.isAcceptableOrUnknown(data['scene_id']!, _sceneIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sceneIdMeta);
    }
    if (data.containsKey('play_time_seconds')) {
      context.handle(
        _playTimeSecondsMeta,
        playTimeSeconds.isAcceptableOrUnknown(
          data['play_time_seconds']!,
          _playTimeSecondsMeta,
        ),
      );
    }
    if (data.containsKey('local_revision')) {
      context.handle(
        _localRevisionMeta,
        localRevision.isAcceptableOrUnknown(
          data['local_revision']!,
          _localRevisionMeta,
        ),
      );
    }
    if (data.containsKey('cloud_revision')) {
      context.handle(
        _cloudRevisionMeta,
        cloudRevision.isAcceptableOrUnknown(
          data['cloud_revision']!,
          _cloudRevisionMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('updated_at_utc_ms')) {
      context.handle(
        _updatedAtUtcMsMeta,
        updatedAtUtcMs.isAcceptableOrUnknown(
          data['updated_at_utc_ms']!,
          _updatedAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMsMeta);
    }
    if (data.containsKey('last_synced_at_utc_ms')) {
      context.handle(
        _lastSyncedAtUtcMsMeta,
        lastSyncedAtUtcMs.isAcceptableOrUnknown(
          data['last_synced_at_utc_ms']!,
          _lastSyncedAtUtcMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slotIndex};
  @override
  SaveSlotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaveSlotRow(
      slotIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot_index'],
      )!,
      ownerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_user_id'],
      ),
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      payload: $SaveSlotsTable.$converterpayload.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payload'],
        )!,
      ),
      caseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      sceneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scene_id'],
      )!,
      playTimeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_time_seconds'],
      )!,
      localRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_revision'],
      )!,
      cloudRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cloud_revision'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      updatedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_ms'],
      )!,
      lastSyncedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at_utc_ms'],
      ),
    );
  }

  @override
  $SaveSlotsTable createAlias(String alias) {
    return $SaveSlotsTable(attachedDatabase, alias);
  }

  static TypeConverter<GameProgress, String> $converterpayload =
      const GameProgressConverter();
}

class SaveSlotRow extends DataClass implements Insertable<SaveSlotRow> {
  final int slotIndex;

  /// The account the save belongs to; null until the player has one.
  final String? ownerUserId;

  /// The version of the payload format, also stored inside the payload.
  final int schemaVersion;
  final GameProgress payload;
  final String caseId;
  final String chapterId;

  /// The scene the player is in; empty when the navigation stack is.
  final String sceneId;
  final int playTimeSeconds;

  /// Grows by one with every write on this device.
  final int localRevision;

  /// The revision the cloud had at the last sync; null before the first.
  final int? cloudRevision;

  /// True while the row has changes the cloud has not seen.
  final bool isDirty;
  final int updatedAtUtcMs;
  final int? lastSyncedAtUtcMs;
  const SaveSlotRow({
    required this.slotIndex,
    this.ownerUserId,
    required this.schemaVersion,
    required this.payload,
    required this.caseId,
    required this.chapterId,
    required this.sceneId,
    required this.playTimeSeconds,
    required this.localRevision,
    this.cloudRevision,
    required this.isDirty,
    required this.updatedAtUtcMs,
    this.lastSyncedAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot_index'] = Variable<int>(slotIndex);
    if (!nullToAbsent || ownerUserId != null) {
      map['owner_user_id'] = Variable<String>(ownerUserId);
    }
    map['schema_version'] = Variable<int>(schemaVersion);
    {
      map['payload'] = Variable<String>(
        $SaveSlotsTable.$converterpayload.toSql(payload),
      );
    }
    map['case_id'] = Variable<String>(caseId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['scene_id'] = Variable<String>(sceneId);
    map['play_time_seconds'] = Variable<int>(playTimeSeconds);
    map['local_revision'] = Variable<int>(localRevision);
    if (!nullToAbsent || cloudRevision != null) {
      map['cloud_revision'] = Variable<int>(cloudRevision);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['updated_at_utc_ms'] = Variable<int>(updatedAtUtcMs);
    if (!nullToAbsent || lastSyncedAtUtcMs != null) {
      map['last_synced_at_utc_ms'] = Variable<int>(lastSyncedAtUtcMs);
    }
    return map;
  }

  SaveSlotsCompanion toCompanion(bool nullToAbsent) {
    return SaveSlotsCompanion(
      slotIndex: Value(slotIndex),
      ownerUserId: ownerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUserId),
      schemaVersion: Value(schemaVersion),
      payload: Value(payload),
      caseId: Value(caseId),
      chapterId: Value(chapterId),
      sceneId: Value(sceneId),
      playTimeSeconds: Value(playTimeSeconds),
      localRevision: Value(localRevision),
      cloudRevision: cloudRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudRevision),
      isDirty: Value(isDirty),
      updatedAtUtcMs: Value(updatedAtUtcMs),
      lastSyncedAtUtcMs: lastSyncedAtUtcMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAtUtcMs),
    );
  }

  factory SaveSlotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaveSlotRow(
      slotIndex: serializer.fromJson<int>(json['slotIndex']),
      ownerUserId: serializer.fromJson<String?>(json['ownerUserId']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      payload: serializer.fromJson<GameProgress>(json['payload']),
      caseId: serializer.fromJson<String>(json['caseId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      sceneId: serializer.fromJson<String>(json['sceneId']),
      playTimeSeconds: serializer.fromJson<int>(json['playTimeSeconds']),
      localRevision: serializer.fromJson<int>(json['localRevision']),
      cloudRevision: serializer.fromJson<int?>(json['cloudRevision']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      updatedAtUtcMs: serializer.fromJson<int>(json['updatedAtUtcMs']),
      lastSyncedAtUtcMs: serializer.fromJson<int?>(json['lastSyncedAtUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slotIndex': serializer.toJson<int>(slotIndex),
      'ownerUserId': serializer.toJson<String?>(ownerUserId),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'payload': serializer.toJson<GameProgress>(payload),
      'caseId': serializer.toJson<String>(caseId),
      'chapterId': serializer.toJson<String>(chapterId),
      'sceneId': serializer.toJson<String>(sceneId),
      'playTimeSeconds': serializer.toJson<int>(playTimeSeconds),
      'localRevision': serializer.toJson<int>(localRevision),
      'cloudRevision': serializer.toJson<int?>(cloudRevision),
      'isDirty': serializer.toJson<bool>(isDirty),
      'updatedAtUtcMs': serializer.toJson<int>(updatedAtUtcMs),
      'lastSyncedAtUtcMs': serializer.toJson<int?>(lastSyncedAtUtcMs),
    };
  }

  SaveSlotRow copyWith({
    int? slotIndex,
    Value<String?> ownerUserId = const Value.absent(),
    int? schemaVersion,
    GameProgress? payload,
    String? caseId,
    String? chapterId,
    String? sceneId,
    int? playTimeSeconds,
    int? localRevision,
    Value<int?> cloudRevision = const Value.absent(),
    bool? isDirty,
    int? updatedAtUtcMs,
    Value<int?> lastSyncedAtUtcMs = const Value.absent(),
  }) => SaveSlotRow(
    slotIndex: slotIndex ?? this.slotIndex,
    ownerUserId: ownerUserId.present ? ownerUserId.value : this.ownerUserId,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    payload: payload ?? this.payload,
    caseId: caseId ?? this.caseId,
    chapterId: chapterId ?? this.chapterId,
    sceneId: sceneId ?? this.sceneId,
    playTimeSeconds: playTimeSeconds ?? this.playTimeSeconds,
    localRevision: localRevision ?? this.localRevision,
    cloudRevision: cloudRevision.present
        ? cloudRevision.value
        : this.cloudRevision,
    isDirty: isDirty ?? this.isDirty,
    updatedAtUtcMs: updatedAtUtcMs ?? this.updatedAtUtcMs,
    lastSyncedAtUtcMs: lastSyncedAtUtcMs.present
        ? lastSyncedAtUtcMs.value
        : this.lastSyncedAtUtcMs,
  );
  SaveSlotRow copyWithCompanion(SaveSlotsCompanion data) {
    return SaveSlotRow(
      slotIndex: data.slotIndex.present ? data.slotIndex.value : this.slotIndex,
      ownerUserId: data.ownerUserId.present
          ? data.ownerUserId.value
          : this.ownerUserId,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      payload: data.payload.present ? data.payload.value : this.payload,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      sceneId: data.sceneId.present ? data.sceneId.value : this.sceneId,
      playTimeSeconds: data.playTimeSeconds.present
          ? data.playTimeSeconds.value
          : this.playTimeSeconds,
      localRevision: data.localRevision.present
          ? data.localRevision.value
          : this.localRevision,
      cloudRevision: data.cloudRevision.present
          ? data.cloudRevision.value
          : this.cloudRevision,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      updatedAtUtcMs: data.updatedAtUtcMs.present
          ? data.updatedAtUtcMs.value
          : this.updatedAtUtcMs,
      lastSyncedAtUtcMs: data.lastSyncedAtUtcMs.present
          ? data.lastSyncedAtUtcMs.value
          : this.lastSyncedAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaveSlotRow(')
          ..write('slotIndex: $slotIndex, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('payload: $payload, ')
          ..write('caseId: $caseId, ')
          ..write('chapterId: $chapterId, ')
          ..write('sceneId: $sceneId, ')
          ..write('playTimeSeconds: $playTimeSeconds, ')
          ..write('localRevision: $localRevision, ')
          ..write('cloudRevision: $cloudRevision, ')
          ..write('isDirty: $isDirty, ')
          ..write('updatedAtUtcMs: $updatedAtUtcMs, ')
          ..write('lastSyncedAtUtcMs: $lastSyncedAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    slotIndex,
    ownerUserId,
    schemaVersion,
    payload,
    caseId,
    chapterId,
    sceneId,
    playTimeSeconds,
    localRevision,
    cloudRevision,
    isDirty,
    updatedAtUtcMs,
    lastSyncedAtUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveSlotRow &&
          other.slotIndex == this.slotIndex &&
          other.ownerUserId == this.ownerUserId &&
          other.schemaVersion == this.schemaVersion &&
          other.payload == this.payload &&
          other.caseId == this.caseId &&
          other.chapterId == this.chapterId &&
          other.sceneId == this.sceneId &&
          other.playTimeSeconds == this.playTimeSeconds &&
          other.localRevision == this.localRevision &&
          other.cloudRevision == this.cloudRevision &&
          other.isDirty == this.isDirty &&
          other.updatedAtUtcMs == this.updatedAtUtcMs &&
          other.lastSyncedAtUtcMs == this.lastSyncedAtUtcMs);
}

class SaveSlotsCompanion extends UpdateCompanion<SaveSlotRow> {
  final Value<int> slotIndex;
  final Value<String?> ownerUserId;
  final Value<int> schemaVersion;
  final Value<GameProgress> payload;
  final Value<String> caseId;
  final Value<String> chapterId;
  final Value<String> sceneId;
  final Value<int> playTimeSeconds;
  final Value<int> localRevision;
  final Value<int?> cloudRevision;
  final Value<bool> isDirty;
  final Value<int> updatedAtUtcMs;
  final Value<int?> lastSyncedAtUtcMs;
  const SaveSlotsCompanion({
    this.slotIndex = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.payload = const Value.absent(),
    this.caseId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.sceneId = const Value.absent(),
    this.playTimeSeconds = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.cloudRevision = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.updatedAtUtcMs = const Value.absent(),
    this.lastSyncedAtUtcMs = const Value.absent(),
  });
  SaveSlotsCompanion.insert({
    this.slotIndex = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    required int schemaVersion,
    required GameProgress payload,
    required String caseId,
    required String chapterId,
    required String sceneId,
    this.playTimeSeconds = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.cloudRevision = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int updatedAtUtcMs,
    this.lastSyncedAtUtcMs = const Value.absent(),
  }) : schemaVersion = Value(schemaVersion),
       payload = Value(payload),
       caseId = Value(caseId),
       chapterId = Value(chapterId),
       sceneId = Value(sceneId),
       updatedAtUtcMs = Value(updatedAtUtcMs);
  static Insertable<SaveSlotRow> custom({
    Expression<int>? slotIndex,
    Expression<String>? ownerUserId,
    Expression<int>? schemaVersion,
    Expression<String>? payload,
    Expression<String>? caseId,
    Expression<String>? chapterId,
    Expression<String>? sceneId,
    Expression<int>? playTimeSeconds,
    Expression<int>? localRevision,
    Expression<int>? cloudRevision,
    Expression<bool>? isDirty,
    Expression<int>? updatedAtUtcMs,
    Expression<int>? lastSyncedAtUtcMs,
  }) {
    return RawValuesInsertable({
      if (slotIndex != null) 'slot_index': slotIndex,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (payload != null) 'payload': payload,
      if (caseId != null) 'case_id': caseId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (sceneId != null) 'scene_id': sceneId,
      if (playTimeSeconds != null) 'play_time_seconds': playTimeSeconds,
      if (localRevision != null) 'local_revision': localRevision,
      if (cloudRevision != null) 'cloud_revision': cloudRevision,
      if (isDirty != null) 'is_dirty': isDirty,
      if (updatedAtUtcMs != null) 'updated_at_utc_ms': updatedAtUtcMs,
      if (lastSyncedAtUtcMs != null) 'last_synced_at_utc_ms': lastSyncedAtUtcMs,
    });
  }

  SaveSlotsCompanion copyWith({
    Value<int>? slotIndex,
    Value<String?>? ownerUserId,
    Value<int>? schemaVersion,
    Value<GameProgress>? payload,
    Value<String>? caseId,
    Value<String>? chapterId,
    Value<String>? sceneId,
    Value<int>? playTimeSeconds,
    Value<int>? localRevision,
    Value<int?>? cloudRevision,
    Value<bool>? isDirty,
    Value<int>? updatedAtUtcMs,
    Value<int?>? lastSyncedAtUtcMs,
  }) {
    return SaveSlotsCompanion(
      slotIndex: slotIndex ?? this.slotIndex,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      payload: payload ?? this.payload,
      caseId: caseId ?? this.caseId,
      chapterId: chapterId ?? this.chapterId,
      sceneId: sceneId ?? this.sceneId,
      playTimeSeconds: playTimeSeconds ?? this.playTimeSeconds,
      localRevision: localRevision ?? this.localRevision,
      cloudRevision: cloudRevision ?? this.cloudRevision,
      isDirty: isDirty ?? this.isDirty,
      updatedAtUtcMs: updatedAtUtcMs ?? this.updatedAtUtcMs,
      lastSyncedAtUtcMs: lastSyncedAtUtcMs ?? this.lastSyncedAtUtcMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slotIndex.present) {
      map['slot_index'] = Variable<int>(slotIndex.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(
        $SaveSlotsTable.$converterpayload.toSql(payload.value),
      );
    }
    if (caseId.present) {
      map['case_id'] = Variable<String>(caseId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (sceneId.present) {
      map['scene_id'] = Variable<String>(sceneId.value);
    }
    if (playTimeSeconds.present) {
      map['play_time_seconds'] = Variable<int>(playTimeSeconds.value);
    }
    if (localRevision.present) {
      map['local_revision'] = Variable<int>(localRevision.value);
    }
    if (cloudRevision.present) {
      map['cloud_revision'] = Variable<int>(cloudRevision.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (updatedAtUtcMs.present) {
      map['updated_at_utc_ms'] = Variable<int>(updatedAtUtcMs.value);
    }
    if (lastSyncedAtUtcMs.present) {
      map['last_synced_at_utc_ms'] = Variable<int>(lastSyncedAtUtcMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaveSlotsCompanion(')
          ..write('slotIndex: $slotIndex, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('payload: $payload, ')
          ..write('caseId: $caseId, ')
          ..write('chapterId: $chapterId, ')
          ..write('sceneId: $sceneId, ')
          ..write('playTimeSeconds: $playTimeSeconds, ')
          ..write('localRevision: $localRevision, ')
          ..write('cloudRevision: $cloudRevision, ')
          ..write('isDirty: $isDirty, ')
          ..write('updatedAtUtcMs: $updatedAtUtcMs, ')
          ..write('lastSyncedAtUtcMs: $lastSyncedAtUtcMs')
          ..write(')'))
        .toString();
  }
}

class $SaveBackupsTable extends SaveBackups
    with TableInfo<$SaveBackupsTable, SaveBackupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaveBackupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _slotIndexMeta = const VerificationMeta(
    'slotIndex',
  );
  @override
  late final GeneratedColumn<int> slotIndex = GeneratedColumn<int>(
    'slot_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMsMeta = const VerificationMeta(
    'createdAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcMs = GeneratedColumn<int>(
    'created_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    slotIndex,
    schemaVersion,
    payload,
    reason,
    createdAtUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'save_backups';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaveBackupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('slot_index')) {
      context.handle(
        _slotIndexMeta,
        slotIndex.isAcceptableOrUnknown(data['slot_index']!, _slotIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_slotIndexMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('created_at_utc_ms')) {
      context.handle(
        _createdAtUtcMsMeta,
        createdAtUtcMs.isAcceptableOrUnknown(
          data['created_at_utc_ms']!,
          _createdAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaveBackupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaveBackupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      slotIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot_index'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      createdAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_ms'],
      )!,
    );
  }

  @override
  $SaveBackupsTable createAlias(String alias) {
    return $SaveBackupsTable(attachedDatabase, alias);
  }
}

class SaveBackupRow extends DataClass implements Insertable<SaveBackupRow> {
  final int id;
  final int slotIndex;
  final int schemaVersion;
  final String payload;

  /// Why the save was set aside, for developers (e.g. the parse error).
  final String reason;
  final int createdAtUtcMs;
  const SaveBackupRow({
    required this.id,
    required this.slotIndex,
    required this.schemaVersion,
    required this.payload,
    required this.reason,
    required this.createdAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['slot_index'] = Variable<int>(slotIndex);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['payload'] = Variable<String>(payload);
    map['reason'] = Variable<String>(reason);
    map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs);
    return map;
  }

  SaveBackupsCompanion toCompanion(bool nullToAbsent) {
    return SaveBackupsCompanion(
      id: Value(id),
      slotIndex: Value(slotIndex),
      schemaVersion: Value(schemaVersion),
      payload: Value(payload),
      reason: Value(reason),
      createdAtUtcMs: Value(createdAtUtcMs),
    );
  }

  factory SaveBackupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaveBackupRow(
      id: serializer.fromJson<int>(json['id']),
      slotIndex: serializer.fromJson<int>(json['slotIndex']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      payload: serializer.fromJson<String>(json['payload']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAtUtcMs: serializer.fromJson<int>(json['createdAtUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'slotIndex': serializer.toJson<int>(slotIndex),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'payload': serializer.toJson<String>(payload),
      'reason': serializer.toJson<String>(reason),
      'createdAtUtcMs': serializer.toJson<int>(createdAtUtcMs),
    };
  }

  SaveBackupRow copyWith({
    int? id,
    int? slotIndex,
    int? schemaVersion,
    String? payload,
    String? reason,
    int? createdAtUtcMs,
  }) => SaveBackupRow(
    id: id ?? this.id,
    slotIndex: slotIndex ?? this.slotIndex,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    payload: payload ?? this.payload,
    reason: reason ?? this.reason,
    createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
  );
  SaveBackupRow copyWithCompanion(SaveBackupsCompanion data) {
    return SaveBackupRow(
      id: data.id.present ? data.id.value : this.id,
      slotIndex: data.slotIndex.present ? data.slotIndex.value : this.slotIndex,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      payload: data.payload.present ? data.payload.value : this.payload,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAtUtcMs: data.createdAtUtcMs.present
          ? data.createdAtUtcMs.value
          : this.createdAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaveBackupRow(')
          ..write('id: $id, ')
          ..write('slotIndex: $slotIndex, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('payload: $payload, ')
          ..write('reason: $reason, ')
          ..write('createdAtUtcMs: $createdAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    slotIndex,
    schemaVersion,
    payload,
    reason,
    createdAtUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveBackupRow &&
          other.id == this.id &&
          other.slotIndex == this.slotIndex &&
          other.schemaVersion == this.schemaVersion &&
          other.payload == this.payload &&
          other.reason == this.reason &&
          other.createdAtUtcMs == this.createdAtUtcMs);
}

class SaveBackupsCompanion extends UpdateCompanion<SaveBackupRow> {
  final Value<int> id;
  final Value<int> slotIndex;
  final Value<int> schemaVersion;
  final Value<String> payload;
  final Value<String> reason;
  final Value<int> createdAtUtcMs;
  const SaveBackupsCompanion({
    this.id = const Value.absent(),
    this.slotIndex = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.payload = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAtUtcMs = const Value.absent(),
  });
  SaveBackupsCompanion.insert({
    this.id = const Value.absent(),
    required int slotIndex,
    required int schemaVersion,
    required String payload,
    required String reason,
    required int createdAtUtcMs,
  }) : slotIndex = Value(slotIndex),
       schemaVersion = Value(schemaVersion),
       payload = Value(payload),
       reason = Value(reason),
       createdAtUtcMs = Value(createdAtUtcMs);
  static Insertable<SaveBackupRow> custom({
    Expression<int>? id,
    Expression<int>? slotIndex,
    Expression<int>? schemaVersion,
    Expression<String>? payload,
    Expression<String>? reason,
    Expression<int>? createdAtUtcMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slotIndex != null) 'slot_index': slotIndex,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (payload != null) 'payload': payload,
      if (reason != null) 'reason': reason,
      if (createdAtUtcMs != null) 'created_at_utc_ms': createdAtUtcMs,
    });
  }

  SaveBackupsCompanion copyWith({
    Value<int>? id,
    Value<int>? slotIndex,
    Value<int>? schemaVersion,
    Value<String>? payload,
    Value<String>? reason,
    Value<int>? createdAtUtcMs,
  }) {
    return SaveBackupsCompanion(
      id: id ?? this.id,
      slotIndex: slotIndex ?? this.slotIndex,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      payload: payload ?? this.payload,
      reason: reason ?? this.reason,
      createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (slotIndex.present) {
      map['slot_index'] = Variable<int>(slotIndex.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAtUtcMs.present) {
      map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaveBackupsCompanion(')
          ..write('id: $id, ')
          ..write('slotIndex: $slotIndex, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('payload: $payload, ')
          ..write('reason: $reason, ')
          ..write('createdAtUtcMs: $createdAtUtcMs')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SaveSlotsTable saveSlots = $SaveSlotsTable(this);
  late final $SaveBackupsTable saveBackups = $SaveBackupsTable(this);
  late final SaveSlotsDao saveSlotsDao = SaveSlotsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [saveSlots, saveBackups];
}

typedef $$SaveSlotsTableCreateCompanionBuilder =
    SaveSlotsCompanion Function({
      Value<int> slotIndex,
      Value<String?> ownerUserId,
      required int schemaVersion,
      required GameProgress payload,
      required String caseId,
      required String chapterId,
      required String sceneId,
      Value<int> playTimeSeconds,
      Value<int> localRevision,
      Value<int?> cloudRevision,
      Value<bool> isDirty,
      required int updatedAtUtcMs,
      Value<int?> lastSyncedAtUtcMs,
    });
typedef $$SaveSlotsTableUpdateCompanionBuilder =
    SaveSlotsCompanion Function({
      Value<int> slotIndex,
      Value<String?> ownerUserId,
      Value<int> schemaVersion,
      Value<GameProgress> payload,
      Value<String> caseId,
      Value<String> chapterId,
      Value<String> sceneId,
      Value<int> playTimeSeconds,
      Value<int> localRevision,
      Value<int?> cloudRevision,
      Value<bool> isDirty,
      Value<int> updatedAtUtcMs,
      Value<int?> lastSyncedAtUtcMs,
    });

class $$SaveSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $SaveSlotsTable> {
  $$SaveSlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get slotIndex => $composableBuilder(
    column: $table.slotIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GameProgress, GameProgress, String>
  get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sceneId => $composableBuilder(
    column: $table.sceneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playTimeSeconds => $composableBuilder(
    column: $table.playTimeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cloudRevision => $composableBuilder(
    column: $table.cloudRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMs => $composableBuilder(
    column: $table.updatedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAtUtcMs => $composableBuilder(
    column: $table.lastSyncedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SaveSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaveSlotsTable> {
  $$SaveSlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get slotIndex => $composableBuilder(
    column: $table.slotIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sceneId => $composableBuilder(
    column: $table.sceneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playTimeSeconds => $composableBuilder(
    column: $table.playTimeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cloudRevision => $composableBuilder(
    column: $table.cloudRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMs => $composableBuilder(
    column: $table.updatedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAtUtcMs => $composableBuilder(
    column: $table.lastSyncedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaveSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaveSlotsTable> {
  $$SaveSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get slotIndex =>
      $composableBuilder(column: $table.slotIndex, builder: (column) => column);

  GeneratedColumn<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GameProgress, String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get caseId =>
      $composableBuilder(column: $table.caseId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get sceneId =>
      $composableBuilder(column: $table.sceneId, builder: (column) => column);

  GeneratedColumn<int> get playTimeSeconds => $composableBuilder(
    column: $table.playTimeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cloudRevision => $composableBuilder(
    column: $table.cloudRevision,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get updatedAtUtcMs => $composableBuilder(
    column: $table.updatedAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedAtUtcMs => $composableBuilder(
    column: $table.lastSyncedAtUtcMs,
    builder: (column) => column,
  );
}

class $$SaveSlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaveSlotsTable,
          SaveSlotRow,
          $$SaveSlotsTableFilterComposer,
          $$SaveSlotsTableOrderingComposer,
          $$SaveSlotsTableAnnotationComposer,
          $$SaveSlotsTableCreateCompanionBuilder,
          $$SaveSlotsTableUpdateCompanionBuilder,
          (
            SaveSlotRow,
            BaseReferences<_$AppDatabase, $SaveSlotsTable, SaveSlotRow>,
          ),
          SaveSlotRow,
          PrefetchHooks Function()
        > {
  $$SaveSlotsTableTableManager(_$AppDatabase db, $SaveSlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaveSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaveSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaveSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> slotIndex = const Value.absent(),
                Value<String?> ownerUserId = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<GameProgress> payload = const Value.absent(),
                Value<String> caseId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String> sceneId = const Value.absent(),
                Value<int> playTimeSeconds = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int?> cloudRevision = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> updatedAtUtcMs = const Value.absent(),
                Value<int?> lastSyncedAtUtcMs = const Value.absent(),
              }) => SaveSlotsCompanion(
                slotIndex: slotIndex,
                ownerUserId: ownerUserId,
                schemaVersion: schemaVersion,
                payload: payload,
                caseId: caseId,
                chapterId: chapterId,
                sceneId: sceneId,
                playTimeSeconds: playTimeSeconds,
                localRevision: localRevision,
                cloudRevision: cloudRevision,
                isDirty: isDirty,
                updatedAtUtcMs: updatedAtUtcMs,
                lastSyncedAtUtcMs: lastSyncedAtUtcMs,
              ),
          createCompanionCallback:
              ({
                Value<int> slotIndex = const Value.absent(),
                Value<String?> ownerUserId = const Value.absent(),
                required int schemaVersion,
                required GameProgress payload,
                required String caseId,
                required String chapterId,
                required String sceneId,
                Value<int> playTimeSeconds = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int?> cloudRevision = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int updatedAtUtcMs,
                Value<int?> lastSyncedAtUtcMs = const Value.absent(),
              }) => SaveSlotsCompanion.insert(
                slotIndex: slotIndex,
                ownerUserId: ownerUserId,
                schemaVersion: schemaVersion,
                payload: payload,
                caseId: caseId,
                chapterId: chapterId,
                sceneId: sceneId,
                playTimeSeconds: playTimeSeconds,
                localRevision: localRevision,
                cloudRevision: cloudRevision,
                isDirty: isDirty,
                updatedAtUtcMs: updatedAtUtcMs,
                lastSyncedAtUtcMs: lastSyncedAtUtcMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaveSlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaveSlotsTable,
      SaveSlotRow,
      $$SaveSlotsTableFilterComposer,
      $$SaveSlotsTableOrderingComposer,
      $$SaveSlotsTableAnnotationComposer,
      $$SaveSlotsTableCreateCompanionBuilder,
      $$SaveSlotsTableUpdateCompanionBuilder,
      (
        SaveSlotRow,
        BaseReferences<_$AppDatabase, $SaveSlotsTable, SaveSlotRow>,
      ),
      SaveSlotRow,
      PrefetchHooks Function()
    >;
typedef $$SaveBackupsTableCreateCompanionBuilder =
    SaveBackupsCompanion Function({
      Value<int> id,
      required int slotIndex,
      required int schemaVersion,
      required String payload,
      required String reason,
      required int createdAtUtcMs,
    });
typedef $$SaveBackupsTableUpdateCompanionBuilder =
    SaveBackupsCompanion Function({
      Value<int> id,
      Value<int> slotIndex,
      Value<int> schemaVersion,
      Value<String> payload,
      Value<String> reason,
      Value<int> createdAtUtcMs,
    });

class $$SaveBackupsTableFilterComposer
    extends Composer<_$AppDatabase, $SaveBackupsTable> {
  $$SaveBackupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slotIndex => $composableBuilder(
    column: $table.slotIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SaveBackupsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaveBackupsTable> {
  $$SaveBackupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slotIndex => $composableBuilder(
    column: $table.slotIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaveBackupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaveBackupsTable> {
  $$SaveBackupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get slotIndex =>
      $composableBuilder(column: $table.slotIndex, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => column,
  );
}

class $$SaveBackupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaveBackupsTable,
          SaveBackupRow,
          $$SaveBackupsTableFilterComposer,
          $$SaveBackupsTableOrderingComposer,
          $$SaveBackupsTableAnnotationComposer,
          $$SaveBackupsTableCreateCompanionBuilder,
          $$SaveBackupsTableUpdateCompanionBuilder,
          (
            SaveBackupRow,
            BaseReferences<_$AppDatabase, $SaveBackupsTable, SaveBackupRow>,
          ),
          SaveBackupRow,
          PrefetchHooks Function()
        > {
  $$SaveBackupsTableTableManager(_$AppDatabase db, $SaveBackupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaveBackupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaveBackupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaveBackupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> slotIndex = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int> createdAtUtcMs = const Value.absent(),
              }) => SaveBackupsCompanion(
                id: id,
                slotIndex: slotIndex,
                schemaVersion: schemaVersion,
                payload: payload,
                reason: reason,
                createdAtUtcMs: createdAtUtcMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int slotIndex,
                required int schemaVersion,
                required String payload,
                required String reason,
                required int createdAtUtcMs,
              }) => SaveBackupsCompanion.insert(
                id: id,
                slotIndex: slotIndex,
                schemaVersion: schemaVersion,
                payload: payload,
                reason: reason,
                createdAtUtcMs: createdAtUtcMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaveBackupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaveBackupsTable,
      SaveBackupRow,
      $$SaveBackupsTableFilterComposer,
      $$SaveBackupsTableOrderingComposer,
      $$SaveBackupsTableAnnotationComposer,
      $$SaveBackupsTableCreateCompanionBuilder,
      $$SaveBackupsTableUpdateCompanionBuilder,
      (
        SaveBackupRow,
        BaseReferences<_$AppDatabase, $SaveBackupsTable, SaveBackupRow>,
      ),
      SaveBackupRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SaveSlotsTableTableManager get saveSlots =>
      $$SaveSlotsTableTableManager(_db, _db.saveSlots);
  $$SaveBackupsTableTableManager get saveBackups =>
      $$SaveBackupsTableTableManager(_db, _db.saveBackups);
}
