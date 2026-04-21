// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ReminderEventsTable extends ReminderEvents
    with TableInfo<$ReminderEventsTable, ReminderEventData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skippedMeta = const VerificationMeta(
    'skipped',
  );
  @override
  late final GeneratedColumn<bool> skipped = GeneratedColumn<bool>(
    'skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    scheduledAt,
    completed,
    skipped,
    exerciseId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderEventData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('skipped')) {
      context.handle(
        _skippedMeta,
        skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta),
      );
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderEventData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderEventData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      skipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}skipped'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      ),
    );
  }

  @override
  $ReminderEventsTable createAlias(String alias) {
    return $ReminderEventsTable(attachedDatabase, alias);
  }
}

class ReminderEventData extends DataClass
    implements Insertable<ReminderEventData> {
  /// UUID primary key.
  final String id;

  /// Serialised [ReminderType] enum name (e.g. "water").
  final String type;

  /// UTC epoch milliseconds stored as a DateTime column.
  final DateTime scheduledAt;
  final bool completed;
  final bool skipped;

  /// Null for water/stretch reminders; references an exercise by its id.
  final String? exerciseId;
  const ReminderEventData({
    required this.id,
    required this.type,
    required this.scheduledAt,
    required this.completed,
    required this.skipped,
    this.exerciseId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['completed'] = Variable<bool>(completed);
    map['skipped'] = Variable<bool>(skipped);
    if (!nullToAbsent || exerciseId != null) {
      map['exercise_id'] = Variable<String>(exerciseId);
    }
    return map;
  }

  ReminderEventsCompanion toCompanion(bool nullToAbsent) {
    return ReminderEventsCompanion(
      id: Value(id),
      type: Value(type),
      scheduledAt: Value(scheduledAt),
      completed: Value(completed),
      skipped: Value(skipped),
      exerciseId: exerciseId == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseId),
    );
  }

  factory ReminderEventData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderEventData(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      completed: serializer.fromJson<bool>(json['completed']),
      skipped: serializer.fromJson<bool>(json['skipped']),
      exerciseId: serializer.fromJson<String?>(json['exerciseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'completed': serializer.toJson<bool>(completed),
      'skipped': serializer.toJson<bool>(skipped),
      'exerciseId': serializer.toJson<String?>(exerciseId),
    };
  }

  ReminderEventData copyWith({
    String? id,
    String? type,
    DateTime? scheduledAt,
    bool? completed,
    bool? skipped,
    Value<String?> exerciseId = const Value.absent(),
  }) => ReminderEventData(
    id: id ?? this.id,
    type: type ?? this.type,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    completed: completed ?? this.completed,
    skipped: skipped ?? this.skipped,
    exerciseId: exerciseId.present ? exerciseId.value : this.exerciseId,
  );
  ReminderEventData copyWithCompanion(ReminderEventsCompanion data) {
    return ReminderEventData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      completed: data.completed.present ? data.completed.value : this.completed,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderEventData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completed: $completed, ')
          ..write('skipped: $skipped, ')
          ..write('exerciseId: $exerciseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, scheduledAt, completed, skipped, exerciseId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderEventData &&
          other.id == this.id &&
          other.type == this.type &&
          other.scheduledAt == this.scheduledAt &&
          other.completed == this.completed &&
          other.skipped == this.skipped &&
          other.exerciseId == this.exerciseId);
}

class ReminderEventsCompanion extends UpdateCompanion<ReminderEventData> {
  final Value<String> id;
  final Value<String> type;
  final Value<DateTime> scheduledAt;
  final Value<bool> completed;
  final Value<bool> skipped;
  final Value<String?> exerciseId;
  final Value<int> rowid;
  const ReminderEventsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.completed = const Value.absent(),
    this.skipped = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderEventsCompanion.insert({
    required String id,
    required String type,
    required DateTime scheduledAt,
    this.completed = const Value.absent(),
    this.skipped = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       scheduledAt = Value(scheduledAt);
  static Insertable<ReminderEventData> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<DateTime>? scheduledAt,
    Expression<bool>? completed,
    Expression<bool>? skipped,
    Expression<String>? exerciseId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (completed != null) 'completed': completed,
      if (skipped != null) 'skipped': skipped,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<DateTime>? scheduledAt,
    Value<bool>? completed,
    Value<bool>? skipped,
    Value<String?>? exerciseId,
    Value<int>? rowid,
  }) {
    return ReminderEventsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completed: completed ?? this.completed,
      skipped: skipped ?? this.skipped,
      exerciseId: exerciseId ?? this.exerciseId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<bool>(skipped.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderEventsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completed: $completed, ')
          ..write('skipped: $skipped, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SkipRecordsTable extends SkipRecords
    with TableInfo<$SkipRecordsTable, SkipRecordData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkipRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    scope,
    createdAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skip_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SkipRecordData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SkipRecordData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SkipRecordData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
    );
  }

  @override
  $SkipRecordsTable createAlias(String alias) {
    return $SkipRecordsTable(attachedDatabase, alias);
  }
}

class SkipRecordData extends DataClass implements Insertable<SkipRecordData> {
  final String id;
  final String exerciseId;

  /// Serialised [SkipScope] enum name.
  final String scope;
  final DateTime createdAt;

  /// Null unless [scope] is "untilDate".
  final DateTime? expiresAt;
  const SkipRecordData({
    required this.id,
    required this.exerciseId,
    required this.scope,
    required this.createdAt,
    this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['scope'] = Variable<String>(scope);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    return map;
  }

  SkipRecordsCompanion toCompanion(bool nullToAbsent) {
    return SkipRecordsCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      scope: Value(scope),
      createdAt: Value(createdAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
    );
  }

  factory SkipRecordData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SkipRecordData(
      id: serializer.fromJson<String>(json['id']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      scope: serializer.fromJson<String>(json['scope']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'scope': serializer.toJson<String>(scope),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
    };
  }

  SkipRecordData copyWith({
    String? id,
    String? exerciseId,
    String? scope,
    DateTime? createdAt,
    Value<DateTime?> expiresAt = const Value.absent(),
  }) => SkipRecordData(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    scope: scope ?? this.scope,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
  );
  SkipRecordData copyWithCompanion(SkipRecordsCompanion data) {
    return SkipRecordData(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      scope: data.scope.present ? data.scope.value : this.scope,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SkipRecordData(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('scope: $scope, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, exerciseId, scope, createdAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SkipRecordData &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.scope == this.scope &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class SkipRecordsCompanion extends UpdateCompanion<SkipRecordData> {
  final Value<String> id;
  final Value<String> exerciseId;
  final Value<String> scope;
  final Value<DateTime> createdAt;
  final Value<DateTime?> expiresAt;
  final Value<int> rowid;
  const SkipRecordsCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.scope = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SkipRecordsCompanion.insert({
    required String id,
    required String exerciseId,
    required String scope,
    required DateTime createdAt,
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       exerciseId = Value(exerciseId),
       scope = Value(scope),
       createdAt = Value(createdAt);
  static Insertable<SkipRecordData> custom({
    Expression<String>? id,
    Expression<String>? exerciseId,
    Expression<String>? scope,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (scope != null) 'scope': scope,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SkipRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? exerciseId,
    Value<String>? scope,
    Value<DateTime>? createdAt,
    Value<DateTime?>? expiresAt,
    Value<int>? rowid,
  }) {
    return SkipRecordsCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      scope: scope ?? this.scope,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkipRecordsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('scope: $scope, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftOverridesTable extends ShiftOverrides
    with TableInfo<$ShiftOverridesTable, ShiftOverrideData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOutOfOfficeMeta = const VerificationMeta(
    'isOutOfOffice',
  );
  @override
  late final GeneratedColumn<int> isOutOfOffice = GeneratedColumn<int>(
    'is_out_of_office',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [date, isOutOfOffice];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shift_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShiftOverrideData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_out_of_office')) {
      context.handle(
        _isOutOfOfficeMeta,
        isOutOfOffice.isAcceptableOrUnknown(
          data['is_out_of_office']!,
          _isOutOfOfficeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  ShiftOverrideData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftOverrideData(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      isOutOfOffice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_out_of_office'],
      )!,
    );
  }

  @override
  $ShiftOverridesTable createAlias(String alias) {
    return $ShiftOverridesTable(attachedDatabase, alias);
  }
}

class ShiftOverrideData extends DataClass
    implements Insertable<ShiftOverrideData> {
  /// ISO-8601 date string, e.g. "2025-04-21". Acts as the primary key.
  final String date;

  /// 1 = out of office (reminders suspended), 0 = normal.
  final int isOutOfOffice;
  const ShiftOverrideData({required this.date, required this.isOutOfOffice});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['is_out_of_office'] = Variable<int>(isOutOfOffice);
    return map;
  }

  ShiftOverridesCompanion toCompanion(bool nullToAbsent) {
    return ShiftOverridesCompanion(
      date: Value(date),
      isOutOfOffice: Value(isOutOfOffice),
    );
  }

  factory ShiftOverrideData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftOverrideData(
      date: serializer.fromJson<String>(json['date']),
      isOutOfOffice: serializer.fromJson<int>(json['isOutOfOffice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'isOutOfOffice': serializer.toJson<int>(isOutOfOffice),
    };
  }

  ShiftOverrideData copyWith({String? date, int? isOutOfOffice}) =>
      ShiftOverrideData(
        date: date ?? this.date,
        isOutOfOffice: isOutOfOffice ?? this.isOutOfOffice,
      );
  ShiftOverrideData copyWithCompanion(ShiftOverridesCompanion data) {
    return ShiftOverrideData(
      date: data.date.present ? data.date.value : this.date,
      isOutOfOffice: data.isOutOfOffice.present
          ? data.isOutOfOffice.value
          : this.isOutOfOffice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftOverrideData(')
          ..write('date: $date, ')
          ..write('isOutOfOffice: $isOutOfOffice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, isOutOfOffice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftOverrideData &&
          other.date == this.date &&
          other.isOutOfOffice == this.isOutOfOffice);
}

class ShiftOverridesCompanion extends UpdateCompanion<ShiftOverrideData> {
  final Value<String> date;
  final Value<int> isOutOfOffice;
  final Value<int> rowid;
  const ShiftOverridesCompanion({
    this.date = const Value.absent(),
    this.isOutOfOffice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftOverridesCompanion.insert({
    required String date,
    this.isOutOfOffice = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<ShiftOverrideData> custom({
    Expression<String>? date,
    Expression<int>? isOutOfOffice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (isOutOfOffice != null) 'is_out_of_office': isOutOfOffice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftOverridesCompanion copyWith({
    Value<String>? date,
    Value<int>? isOutOfOffice,
    Value<int>? rowid,
  }) {
    return ShiftOverridesCompanion(
      date: date ?? this.date,
      isOutOfOffice: isOutOfOffice ?? this.isOutOfOffice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (isOutOfOffice.present) {
      map['is_out_of_office'] = Variable<int>(isOutOfOffice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftOverridesCompanion(')
          ..write('date: $date, ')
          ..write('isOutOfOffice: $isOutOfOffice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TreadmillSessionsTable extends TreadmillSessions
    with TableInfo<$TreadmillSessionsTable, TreadmillSessionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreadmillSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deviceModelMeta = const VerificationMeta(
    'deviceModel',
  );
  @override
  late final GeneratedColumn<String> deviceModel = GeneratedColumn<String>(
    'device_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startTime,
    endTime,
    steps,
    calories,
    deviceModel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'treadmill_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TreadmillSessionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('device_model')) {
      context.handle(
        _deviceModelMeta,
        deviceModel.isAcceptableOrUnknown(
          data['device_model']!,
          _deviceModelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TreadmillSessionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TreadmillSessionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      )!,
      deviceModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_model'],
      ),
    );
  }

  @override
  $TreadmillSessionsTable createAlias(String alias) {
    return $TreadmillSessionsTable(attachedDatabase, alias);
  }
}

class TreadmillSessionData extends DataClass
    implements Insertable<TreadmillSessionData> {
  final String id;
  final DateTime startTime;

  /// Null if the session is still active.
  final DateTime? endTime;
  final int steps;
  final int calories;

  /// BLE device model string reported by the treadmill.
  final String? deviceModel;
  const TreadmillSessionData({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.steps,
    required this.calories,
    this.deviceModel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['steps'] = Variable<int>(steps);
    map['calories'] = Variable<int>(calories);
    if (!nullToAbsent || deviceModel != null) {
      map['device_model'] = Variable<String>(deviceModel);
    }
    return map;
  }

  TreadmillSessionsCompanion toCompanion(bool nullToAbsent) {
    return TreadmillSessionsCompanion(
      id: Value(id),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      steps: Value(steps),
      calories: Value(calories),
      deviceModel: deviceModel == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceModel),
    );
  }

  factory TreadmillSessionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TreadmillSessionData(
      id: serializer.fromJson<String>(json['id']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      steps: serializer.fromJson<int>(json['steps']),
      calories: serializer.fromJson<int>(json['calories']),
      deviceModel: serializer.fromJson<String?>(json['deviceModel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'steps': serializer.toJson<int>(steps),
      'calories': serializer.toJson<int>(calories),
      'deviceModel': serializer.toJson<String?>(deviceModel),
    };
  }

  TreadmillSessionData copyWith({
    String? id,
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    int? steps,
    int? calories,
    Value<String?> deviceModel = const Value.absent(),
  }) => TreadmillSessionData(
    id: id ?? this.id,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    steps: steps ?? this.steps,
    calories: calories ?? this.calories,
    deviceModel: deviceModel.present ? deviceModel.value : this.deviceModel,
  );
  TreadmillSessionData copyWithCompanion(TreadmillSessionsCompanion data) {
    return TreadmillSessionData(
      id: data.id.present ? data.id.value : this.id,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      steps: data.steps.present ? data.steps.value : this.steps,
      calories: data.calories.present ? data.calories.value : this.calories,
      deviceModel: data.deviceModel.present
          ? data.deviceModel.value
          : this.deviceModel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TreadmillSessionData(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('steps: $steps, ')
          ..write('calories: $calories, ')
          ..write('deviceModel: $deviceModel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startTime, endTime, steps, calories, deviceModel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TreadmillSessionData &&
          other.id == this.id &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.steps == this.steps &&
          other.calories == this.calories &&
          other.deviceModel == this.deviceModel);
}

class TreadmillSessionsCompanion extends UpdateCompanion<TreadmillSessionData> {
  final Value<String> id;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int> steps;
  final Value<int> calories;
  final Value<String?> deviceModel;
  final Value<int> rowid;
  const TreadmillSessionsCompanion({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.steps = const Value.absent(),
    this.calories = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TreadmillSessionsCompanion.insert({
    required String id,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.steps = const Value.absent(),
    this.calories = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startTime = Value(startTime);
  static Insertable<TreadmillSessionData> custom({
    Expression<String>? id,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? steps,
    Expression<int>? calories,
    Expression<String>? deviceModel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (steps != null) 'steps': steps,
      if (calories != null) 'calories': calories,
      if (deviceModel != null) 'device_model': deviceModel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TreadmillSessionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<int>? steps,
    Value<int>? calories,
    Value<String?>? deviceModel,
    Value<int>? rowid,
  }) {
    return TreadmillSessionsCompanion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      deviceModel: deviceModel ?? this.deviceModel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (deviceModel.present) {
      map['device_model'] = Variable<String>(deviceModel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreadmillSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('steps: $steps, ')
          ..write('calories: $calories, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReminderEventsTable reminderEvents = $ReminderEventsTable(this);
  late final $SkipRecordsTable skipRecords = $SkipRecordsTable(this);
  late final $ShiftOverridesTable shiftOverrides = $ShiftOverridesTable(this);
  late final $TreadmillSessionsTable treadmillSessions =
      $TreadmillSessionsTable(this);
  late final ReminderDao reminderDao = ReminderDao(this as AppDatabase);
  late final SkipDao skipDao = SkipDao(this as AppDatabase);
  late final ShiftDao shiftDao = ShiftDao(this as AppDatabase);
  late final TreadmillDao treadmillDao = TreadmillDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    reminderEvents,
    skipRecords,
    shiftOverrides,
    treadmillSessions,
  ];
}

typedef $$ReminderEventsTableCreateCompanionBuilder =
    ReminderEventsCompanion Function({
      required String id,
      required String type,
      required DateTime scheduledAt,
      Value<bool> completed,
      Value<bool> skipped,
      Value<String?> exerciseId,
      Value<int> rowid,
    });
typedef $$ReminderEventsTableUpdateCompanionBuilder =
    ReminderEventsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<DateTime> scheduledAt,
      Value<bool> completed,
      Value<bool> skipped,
      Value<String?> exerciseId,
      Value<int> rowid,
    });

class $$ReminderEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderEventsTable> {
  $$ReminderEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReminderEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderEventsTable> {
  $$ReminderEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderEventsTable> {
  $$ReminderEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );
}

class $$ReminderEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderEventsTable,
          ReminderEventData,
          $$ReminderEventsTableFilterComposer,
          $$ReminderEventsTableOrderingComposer,
          $$ReminderEventsTableAnnotationComposer,
          $$ReminderEventsTableCreateCompanionBuilder,
          $$ReminderEventsTableUpdateCompanionBuilder,
          (
            ReminderEventData,
            BaseReferences<
              _$AppDatabase,
              $ReminderEventsTable,
              ReminderEventData
            >,
          ),
          ReminderEventData,
          PrefetchHooks Function()
        > {
  $$ReminderEventsTableTableManager(
    _$AppDatabase db,
    $ReminderEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
                Value<String?> exerciseId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderEventsCompanion(
                id: id,
                type: type,
                scheduledAt: scheduledAt,
                completed: completed,
                skipped: skipped,
                exerciseId: exerciseId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required DateTime scheduledAt,
                Value<bool> completed = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
                Value<String?> exerciseId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderEventsCompanion.insert(
                id: id,
                type: type,
                scheduledAt: scheduledAt,
                completed: completed,
                skipped: skipped,
                exerciseId: exerciseId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReminderEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderEventsTable,
      ReminderEventData,
      $$ReminderEventsTableFilterComposer,
      $$ReminderEventsTableOrderingComposer,
      $$ReminderEventsTableAnnotationComposer,
      $$ReminderEventsTableCreateCompanionBuilder,
      $$ReminderEventsTableUpdateCompanionBuilder,
      (
        ReminderEventData,
        BaseReferences<_$AppDatabase, $ReminderEventsTable, ReminderEventData>,
      ),
      ReminderEventData,
      PrefetchHooks Function()
    >;
typedef $$SkipRecordsTableCreateCompanionBuilder =
    SkipRecordsCompanion Function({
      required String id,
      required String exerciseId,
      required String scope,
      required DateTime createdAt,
      Value<DateTime?> expiresAt,
      Value<int> rowid,
    });
typedef $$SkipRecordsTableUpdateCompanionBuilder =
    SkipRecordsCompanion Function({
      Value<String> id,
      Value<String> exerciseId,
      Value<String> scope,
      Value<DateTime> createdAt,
      Value<DateTime?> expiresAt,
      Value<int> rowid,
    });

class $$SkipRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SkipRecordsTable> {
  $$SkipRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SkipRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SkipRecordsTable> {
  $$SkipRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SkipRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SkipRecordsTable> {
  $$SkipRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$SkipRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SkipRecordsTable,
          SkipRecordData,
          $$SkipRecordsTableFilterComposer,
          $$SkipRecordsTableOrderingComposer,
          $$SkipRecordsTableAnnotationComposer,
          $$SkipRecordsTableCreateCompanionBuilder,
          $$SkipRecordsTableUpdateCompanionBuilder,
          (
            SkipRecordData,
            BaseReferences<_$AppDatabase, $SkipRecordsTable, SkipRecordData>,
          ),
          SkipRecordData,
          PrefetchHooks Function()
        > {
  $$SkipRecordsTableTableManager(_$AppDatabase db, $SkipRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkipRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkipRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkipRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SkipRecordsCompanion(
                id: id,
                exerciseId: exerciseId,
                scope: scope,
                createdAt: createdAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String exerciseId,
                required String scope,
                required DateTime createdAt,
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SkipRecordsCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                scope: scope,
                createdAt: createdAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SkipRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SkipRecordsTable,
      SkipRecordData,
      $$SkipRecordsTableFilterComposer,
      $$SkipRecordsTableOrderingComposer,
      $$SkipRecordsTableAnnotationComposer,
      $$SkipRecordsTableCreateCompanionBuilder,
      $$SkipRecordsTableUpdateCompanionBuilder,
      (
        SkipRecordData,
        BaseReferences<_$AppDatabase, $SkipRecordsTable, SkipRecordData>,
      ),
      SkipRecordData,
      PrefetchHooks Function()
    >;
typedef $$ShiftOverridesTableCreateCompanionBuilder =
    ShiftOverridesCompanion Function({
      required String date,
      Value<int> isOutOfOffice,
      Value<int> rowid,
    });
typedef $$ShiftOverridesTableUpdateCompanionBuilder =
    ShiftOverridesCompanion Function({
      Value<String> date,
      Value<int> isOutOfOffice,
      Value<int> rowid,
    });

class $$ShiftOverridesTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftOverridesTable> {
  $$ShiftOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isOutOfOffice => $composableBuilder(
    column: $table.isOutOfOffice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShiftOverridesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftOverridesTable> {
  $$ShiftOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isOutOfOffice => $composableBuilder(
    column: $table.isOutOfOffice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftOverridesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftOverridesTable> {
  $$ShiftOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get isOutOfOffice => $composableBuilder(
    column: $table.isOutOfOffice,
    builder: (column) => column,
  );
}

class $$ShiftOverridesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftOverridesTable,
          ShiftOverrideData,
          $$ShiftOverridesTableFilterComposer,
          $$ShiftOverridesTableOrderingComposer,
          $$ShiftOverridesTableAnnotationComposer,
          $$ShiftOverridesTableCreateCompanionBuilder,
          $$ShiftOverridesTableUpdateCompanionBuilder,
          (
            ShiftOverrideData,
            BaseReferences<
              _$AppDatabase,
              $ShiftOverridesTable,
              ShiftOverrideData
            >,
          ),
          ShiftOverrideData,
          PrefetchHooks Function()
        > {
  $$ShiftOverridesTableTableManager(
    _$AppDatabase db,
    $ShiftOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int> isOutOfOffice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftOverridesCompanion(
                date: date,
                isOutOfOffice: isOutOfOffice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                Value<int> isOutOfOffice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftOverridesCompanion.insert(
                date: date,
                isOutOfOffice: isOutOfOffice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShiftOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftOverridesTable,
      ShiftOverrideData,
      $$ShiftOverridesTableFilterComposer,
      $$ShiftOverridesTableOrderingComposer,
      $$ShiftOverridesTableAnnotationComposer,
      $$ShiftOverridesTableCreateCompanionBuilder,
      $$ShiftOverridesTableUpdateCompanionBuilder,
      (
        ShiftOverrideData,
        BaseReferences<_$AppDatabase, $ShiftOverridesTable, ShiftOverrideData>,
      ),
      ShiftOverrideData,
      PrefetchHooks Function()
    >;
typedef $$TreadmillSessionsTableCreateCompanionBuilder =
    TreadmillSessionsCompanion Function({
      required String id,
      required DateTime startTime,
      Value<DateTime?> endTime,
      Value<int> steps,
      Value<int> calories,
      Value<String?> deviceModel,
      Value<int> rowid,
    });
typedef $$TreadmillSessionsTableUpdateCompanionBuilder =
    TreadmillSessionsCompanion Function({
      Value<String> id,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<int> steps,
      Value<int> calories,
      Value<String?> deviceModel,
      Value<int> rowid,
    });

class $$TreadmillSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TreadmillSessionsTable> {
  $$TreadmillSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TreadmillSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TreadmillSessionsTable> {
  $$TreadmillSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TreadmillSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TreadmillSessionsTable> {
  $$TreadmillSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => column,
  );
}

class $$TreadmillSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TreadmillSessionsTable,
          TreadmillSessionData,
          $$TreadmillSessionsTableFilterComposer,
          $$TreadmillSessionsTableOrderingComposer,
          $$TreadmillSessionsTableAnnotationComposer,
          $$TreadmillSessionsTableCreateCompanionBuilder,
          $$TreadmillSessionsTableUpdateCompanionBuilder,
          (
            TreadmillSessionData,
            BaseReferences<
              _$AppDatabase,
              $TreadmillSessionsTable,
              TreadmillSessionData
            >,
          ),
          TreadmillSessionData,
          PrefetchHooks Function()
        > {
  $$TreadmillSessionsTableTableManager(
    _$AppDatabase db,
    $TreadmillSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreadmillSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreadmillSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreadmillSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> steps = const Value.absent(),
                Value<int> calories = const Value.absent(),
                Value<String?> deviceModel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreadmillSessionsCompanion(
                id: id,
                startTime: startTime,
                endTime: endTime,
                steps: steps,
                calories: calories,
                deviceModel: deviceModel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> steps = const Value.absent(),
                Value<int> calories = const Value.absent(),
                Value<String?> deviceModel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreadmillSessionsCompanion.insert(
                id: id,
                startTime: startTime,
                endTime: endTime,
                steps: steps,
                calories: calories,
                deviceModel: deviceModel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TreadmillSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TreadmillSessionsTable,
      TreadmillSessionData,
      $$TreadmillSessionsTableFilterComposer,
      $$TreadmillSessionsTableOrderingComposer,
      $$TreadmillSessionsTableAnnotationComposer,
      $$TreadmillSessionsTableCreateCompanionBuilder,
      $$TreadmillSessionsTableUpdateCompanionBuilder,
      (
        TreadmillSessionData,
        BaseReferences<
          _$AppDatabase,
          $TreadmillSessionsTable,
          TreadmillSessionData
        >,
      ),
      TreadmillSessionData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReminderEventsTableTableManager get reminderEvents =>
      $$ReminderEventsTableTableManager(_db, _db.reminderEvents);
  $$SkipRecordsTableTableManager get skipRecords =>
      $$SkipRecordsTableTableManager(_db, _db.skipRecords);
  $$ShiftOverridesTableTableManager get shiftOverrides =>
      $$ShiftOverridesTableTableManager(_db, _db.shiftOverrides);
  $$TreadmillSessionsTableTableManager get treadmillSessions =>
      $$TreadmillSessionsTableTableManager(_db, _db.treadmillSessions);
}
