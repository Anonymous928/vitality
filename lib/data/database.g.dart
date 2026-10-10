// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EpisodesTable extends Episodes with TableInfo<$EpisodesTable, Episode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EpisodeType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<EpisodeType>($EpisodesTable.$convertertype);
  static const VerificationMeta _sleepQualityMeta = const VerificationMeta(
    'sleepQuality',
  );
  @override
  late final GeneratedColumn<int> sleepQuality = GeneratedColumn<int>(
    'sleep_quality',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alcoholMeta = const VerificationMeta(
    'alcohol',
  );
  @override
  late final GeneratedColumn<bool> alcohol = GeneratedColumn<bool>(
    'alcohol',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("alcohol" IN (0, 1))',
    ),
  );
  static const VerificationMeta _stressMeta = const VerificationMeta('stress');
  @override
  late final GeneratedColumn<int> stress = GeneratedColumn<int>(
    'stress',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  preInterventions = GeneratedColumn<String>(
    'pre_interventions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($EpisodesTable.$converterpreInterventions);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recoveredAtMeta = const VerificationMeta(
    'recoveredAt',
  );
  @override
  late final GeneratedColumn<DateTime> recoveredAt = GeneratedColumn<DateTime>(
    'recovered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recoveryPctMeta = const VerificationMeta(
    'recoveryPct',
  );
  @override
  late final GeneratedColumn<int> recoveryPct = GeneratedColumn<int>(
    'recovery_pct',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Severity?, int> peakSeverity =
      GeneratedColumn<int>(
        'peak_severity',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<Severity?>($EpisodesTable.$converterpeakSeverityn);
  static const VerificationMeta _checkInCountMeta = const VerificationMeta(
    'checkInCount',
  );
  @override
  late final GeneratedColumn<int> checkInCount = GeneratedColumn<int>(
    'check_in_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    occurredAt,
    type,
    sleepQuality,
    alcohol,
    stress,
    preInterventions,
    note,
    recoveredAt,
    recoveryPct,
    peakSeverity,
    checkInCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Episode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('sleep_quality')) {
      context.handle(
        _sleepQualityMeta,
        sleepQuality.isAcceptableOrUnknown(
          data['sleep_quality']!,
          _sleepQualityMeta,
        ),
      );
    }
    if (data.containsKey('alcohol')) {
      context.handle(
        _alcoholMeta,
        alcohol.isAcceptableOrUnknown(data['alcohol']!, _alcoholMeta),
      );
    }
    if (data.containsKey('stress')) {
      context.handle(
        _stressMeta,
        stress.isAcceptableOrUnknown(data['stress']!, _stressMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('recovered_at')) {
      context.handle(
        _recoveredAtMeta,
        recoveredAt.isAcceptableOrUnknown(
          data['recovered_at']!,
          _recoveredAtMeta,
        ),
      );
    }
    if (data.containsKey('recovery_pct')) {
      context.handle(
        _recoveryPctMeta,
        recoveryPct.isAcceptableOrUnknown(
          data['recovery_pct']!,
          _recoveryPctMeta,
        ),
      );
    }
    if (data.containsKey('check_in_count')) {
      context.handle(
        _checkInCountMeta,
        checkInCount.isAcceptableOrUnknown(
          data['check_in_count']!,
          _checkInCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Episode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Episode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      type: $EpisodesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      sleepQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_quality'],
      ),
      alcohol: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}alcohol'],
      ),
      stress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stress'],
      ),
      preInterventions: $EpisodesTable.$converterpreInterventions.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}pre_interventions'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      recoveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recovered_at'],
      ),
      recoveryPct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recovery_pct'],
      ),
      peakSeverity: $EpisodesTable.$converterpeakSeverityn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}peak_severity'],
        ),
      ),
      checkInCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}check_in_count'],
      )!,
    );
  }

  @override
  $EpisodesTable createAlias(String alias) {
    return $EpisodesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EpisodeType, int, int> $convertertype =
      const EnumIndexConverter<EpisodeType>(EpisodeType.values);
  static TypeConverter<List<String>, String> $converterpreInterventions =
      const StringListConverter();
  static JsonTypeConverter2<Severity, int, int> $converterpeakSeverity =
      const EnumIndexConverter<Severity>(Severity.values);
  static JsonTypeConverter2<Severity?, int?, int?> $converterpeakSeverityn =
      JsonTypeConverter2.asNullable($converterpeakSeverity);
}

class Episode extends DataClass implements Insertable<Episode> {
  final int id;
  final DateTime occurredAt;
  final EpisodeType type;
  final int? sleepQuality;
  final bool? alcohol;
  final int? stress;
  final List<String> preInterventions;
  final String? note;
  final DateTime? recoveredAt;
  final int? recoveryPct;
  final Severity? peakSeverity;
  final int checkInCount;
  const Episode({
    required this.id,
    required this.occurredAt,
    required this.type,
    this.sleepQuality,
    this.alcohol,
    this.stress,
    required this.preInterventions,
    this.note,
    this.recoveredAt,
    this.recoveryPct,
    this.peakSeverity,
    required this.checkInCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    {
      map['type'] = Variable<int>($EpisodesTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || sleepQuality != null) {
      map['sleep_quality'] = Variable<int>(sleepQuality);
    }
    if (!nullToAbsent || alcohol != null) {
      map['alcohol'] = Variable<bool>(alcohol);
    }
    if (!nullToAbsent || stress != null) {
      map['stress'] = Variable<int>(stress);
    }
    {
      map['pre_interventions'] = Variable<String>(
        $EpisodesTable.$converterpreInterventions.toSql(preInterventions),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || recoveredAt != null) {
      map['recovered_at'] = Variable<DateTime>(recoveredAt);
    }
    if (!nullToAbsent || recoveryPct != null) {
      map['recovery_pct'] = Variable<int>(recoveryPct);
    }
    if (!nullToAbsent || peakSeverity != null) {
      map['peak_severity'] = Variable<int>(
        $EpisodesTable.$converterpeakSeverityn.toSql(peakSeverity),
      );
    }
    map['check_in_count'] = Variable<int>(checkInCount);
    return map;
  }

  EpisodesCompanion toCompanion(bool nullToAbsent) {
    return EpisodesCompanion(
      id: Value(id),
      occurredAt: Value(occurredAt),
      type: Value(type),
      sleepQuality: sleepQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepQuality),
      alcohol: alcohol == null && nullToAbsent
          ? const Value.absent()
          : Value(alcohol),
      stress: stress == null && nullToAbsent
          ? const Value.absent()
          : Value(stress),
      preInterventions: Value(preInterventions),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      recoveredAt: recoveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(recoveredAt),
      recoveryPct: recoveryPct == null && nullToAbsent
          ? const Value.absent()
          : Value(recoveryPct),
      peakSeverity: peakSeverity == null && nullToAbsent
          ? const Value.absent()
          : Value(peakSeverity),
      checkInCount: Value(checkInCount),
    );
  }

  factory Episode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Episode(
      id: serializer.fromJson<int>(json['id']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      type: $EpisodesTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      sleepQuality: serializer.fromJson<int?>(json['sleepQuality']),
      alcohol: serializer.fromJson<bool?>(json['alcohol']),
      stress: serializer.fromJson<int?>(json['stress']),
      preInterventions: serializer.fromJson<List<String>>(
        json['preInterventions'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      recoveredAt: serializer.fromJson<DateTime?>(json['recoveredAt']),
      recoveryPct: serializer.fromJson<int?>(json['recoveryPct']),
      peakSeverity: $EpisodesTable.$converterpeakSeverityn.fromJson(
        serializer.fromJson<int?>(json['peakSeverity']),
      ),
      checkInCount: serializer.fromJson<int>(json['checkInCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'type': serializer.toJson<int>(
        $EpisodesTable.$convertertype.toJson(type),
      ),
      'sleepQuality': serializer.toJson<int?>(sleepQuality),
      'alcohol': serializer.toJson<bool?>(alcohol),
      'stress': serializer.toJson<int?>(stress),
      'preInterventions': serializer.toJson<List<String>>(preInterventions),
      'note': serializer.toJson<String?>(note),
      'recoveredAt': serializer.toJson<DateTime?>(recoveredAt),
      'recoveryPct': serializer.toJson<int?>(recoveryPct),
      'peakSeverity': serializer.toJson<int?>(
        $EpisodesTable.$converterpeakSeverityn.toJson(peakSeverity),
      ),
      'checkInCount': serializer.toJson<int>(checkInCount),
    };
  }

  Episode copyWith({
    int? id,
    DateTime? occurredAt,
    EpisodeType? type,
    Value<int?> sleepQuality = const Value.absent(),
    Value<bool?> alcohol = const Value.absent(),
    Value<int?> stress = const Value.absent(),
    List<String>? preInterventions,
    Value<String?> note = const Value.absent(),
    Value<DateTime?> recoveredAt = const Value.absent(),
    Value<int?> recoveryPct = const Value.absent(),
    Value<Severity?> peakSeverity = const Value.absent(),
    int? checkInCount,
  }) => Episode(
    id: id ?? this.id,
    occurredAt: occurredAt ?? this.occurredAt,
    type: type ?? this.type,
    sleepQuality: sleepQuality.present ? sleepQuality.value : this.sleepQuality,
    alcohol: alcohol.present ? alcohol.value : this.alcohol,
    stress: stress.present ? stress.value : this.stress,
    preInterventions: preInterventions ?? this.preInterventions,
    note: note.present ? note.value : this.note,
    recoveredAt: recoveredAt.present ? recoveredAt.value : this.recoveredAt,
    recoveryPct: recoveryPct.present ? recoveryPct.value : this.recoveryPct,
    peakSeverity: peakSeverity.present ? peakSeverity.value : this.peakSeverity,
    checkInCount: checkInCount ?? this.checkInCount,
  );
  Episode copyWithCompanion(EpisodesCompanion data) {
    return Episode(
      id: data.id.present ? data.id.value : this.id,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      type: data.type.present ? data.type.value : this.type,
      sleepQuality: data.sleepQuality.present
          ? data.sleepQuality.value
          : this.sleepQuality,
      alcohol: data.alcohol.present ? data.alcohol.value : this.alcohol,
      stress: data.stress.present ? data.stress.value : this.stress,
      preInterventions: data.preInterventions.present
          ? data.preInterventions.value
          : this.preInterventions,
      note: data.note.present ? data.note.value : this.note,
      recoveredAt: data.recoveredAt.present
          ? data.recoveredAt.value
          : this.recoveredAt,
      recoveryPct: data.recoveryPct.present
          ? data.recoveryPct.value
          : this.recoveryPct,
      peakSeverity: data.peakSeverity.present
          ? data.peakSeverity.value
          : this.peakSeverity,
      checkInCount: data.checkInCount.present
          ? data.checkInCount.value
          : this.checkInCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Episode(')
          ..write('id: $id, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('type: $type, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('alcohol: $alcohol, ')
          ..write('stress: $stress, ')
          ..write('preInterventions: $preInterventions, ')
          ..write('note: $note, ')
          ..write('recoveredAt: $recoveredAt, ')
          ..write('recoveryPct: $recoveryPct, ')
          ..write('peakSeverity: $peakSeverity, ')
          ..write('checkInCount: $checkInCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    occurredAt,
    type,
    sleepQuality,
    alcohol,
    stress,
    preInterventions,
    note,
    recoveredAt,
    recoveryPct,
    peakSeverity,
    checkInCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Episode &&
          other.id == this.id &&
          other.occurredAt == this.occurredAt &&
          other.type == this.type &&
          other.sleepQuality == this.sleepQuality &&
          other.alcohol == this.alcohol &&
          other.stress == this.stress &&
          other.preInterventions == this.preInterventions &&
          other.note == this.note &&
          other.recoveredAt == this.recoveredAt &&
          other.recoveryPct == this.recoveryPct &&
          other.peakSeverity == this.peakSeverity &&
          other.checkInCount == this.checkInCount);
}

class EpisodesCompanion extends UpdateCompanion<Episode> {
  final Value<int> id;
  final Value<DateTime> occurredAt;
  final Value<EpisodeType> type;
  final Value<int?> sleepQuality;
  final Value<bool?> alcohol;
  final Value<int?> stress;
  final Value<List<String>> preInterventions;
  final Value<String?> note;
  final Value<DateTime?> recoveredAt;
  final Value<int?> recoveryPct;
  final Value<Severity?> peakSeverity;
  final Value<int> checkInCount;
  const EpisodesCompanion({
    this.id = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.type = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.alcohol = const Value.absent(),
    this.stress = const Value.absent(),
    this.preInterventions = const Value.absent(),
    this.note = const Value.absent(),
    this.recoveredAt = const Value.absent(),
    this.recoveryPct = const Value.absent(),
    this.peakSeverity = const Value.absent(),
    this.checkInCount = const Value.absent(),
  });
  EpisodesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime occurredAt,
    required EpisodeType type,
    this.sleepQuality = const Value.absent(),
    this.alcohol = const Value.absent(),
    this.stress = const Value.absent(),
    this.preInterventions = const Value.absent(),
    this.note = const Value.absent(),
    this.recoveredAt = const Value.absent(),
    this.recoveryPct = const Value.absent(),
    this.peakSeverity = const Value.absent(),
    this.checkInCount = const Value.absent(),
  }) : occurredAt = Value(occurredAt),
       type = Value(type);
  static Insertable<Episode> custom({
    Expression<int>? id,
    Expression<DateTime>? occurredAt,
    Expression<int>? type,
    Expression<int>? sleepQuality,
    Expression<bool>? alcohol,
    Expression<int>? stress,
    Expression<String>? preInterventions,
    Expression<String>? note,
    Expression<DateTime>? recoveredAt,
    Expression<int>? recoveryPct,
    Expression<int>? peakSeverity,
    Expression<int>? checkInCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (type != null) 'type': type,
      if (sleepQuality != null) 'sleep_quality': sleepQuality,
      if (alcohol != null) 'alcohol': alcohol,
      if (stress != null) 'stress': stress,
      if (preInterventions != null) 'pre_interventions': preInterventions,
      if (note != null) 'note': note,
      if (recoveredAt != null) 'recovered_at': recoveredAt,
      if (recoveryPct != null) 'recovery_pct': recoveryPct,
      if (peakSeverity != null) 'peak_severity': peakSeverity,
      if (checkInCount != null) 'check_in_count': checkInCount,
    });
  }

  EpisodesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? occurredAt,
    Value<EpisodeType>? type,
    Value<int?>? sleepQuality,
    Value<bool?>? alcohol,
    Value<int?>? stress,
    Value<List<String>>? preInterventions,
    Value<String?>? note,
    Value<DateTime?>? recoveredAt,
    Value<int?>? recoveryPct,
    Value<Severity?>? peakSeverity,
    Value<int>? checkInCount,
  }) {
    return EpisodesCompanion(
      id: id ?? this.id,
      occurredAt: occurredAt ?? this.occurredAt,
      type: type ?? this.type,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      alcohol: alcohol ?? this.alcohol,
      stress: stress ?? this.stress,
      preInterventions: preInterventions ?? this.preInterventions,
      note: note ?? this.note,
      recoveredAt: recoveredAt ?? this.recoveredAt,
      recoveryPct: recoveryPct ?? this.recoveryPct,
      peakSeverity: peakSeverity ?? this.peakSeverity,
      checkInCount: checkInCount ?? this.checkInCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $EpisodesTable.$convertertype.toSql(type.value),
      );
    }
    if (sleepQuality.present) {
      map['sleep_quality'] = Variable<int>(sleepQuality.value);
    }
    if (alcohol.present) {
      map['alcohol'] = Variable<bool>(alcohol.value);
    }
    if (stress.present) {
      map['stress'] = Variable<int>(stress.value);
    }
    if (preInterventions.present) {
      map['pre_interventions'] = Variable<String>(
        $EpisodesTable.$converterpreInterventions.toSql(preInterventions.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (recoveredAt.present) {
      map['recovered_at'] = Variable<DateTime>(recoveredAt.value);
    }
    if (recoveryPct.present) {
      map['recovery_pct'] = Variable<int>(recoveryPct.value);
    }
    if (peakSeverity.present) {
      map['peak_severity'] = Variable<int>(
        $EpisodesTable.$converterpeakSeverityn.toSql(peakSeverity.value),
      );
    }
    if (checkInCount.present) {
      map['check_in_count'] = Variable<int>(checkInCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodesCompanion(')
          ..write('id: $id, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('type: $type, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('alcohol: $alcohol, ')
          ..write('stress: $stress, ')
          ..write('preInterventions: $preInterventions, ')
          ..write('note: $note, ')
          ..write('recoveredAt: $recoveredAt, ')
          ..write('recoveryPct: $recoveryPct, ')
          ..write('peakSeverity: $peakSeverity, ')
          ..write('checkInCount: $checkInCount')
          ..write(')'))
        .toString();
  }
}

class $CheckInsTable extends CheckIns with TableInfo<$CheckInsTable, CheckIn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckInsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES episodes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overallMeta = const VerificationMeta(
    'overall',
  );
  @override
  late final GeneratedColumn<int> overall = GeneratedColumn<int>(
    'overall',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<
    Map<SymptomCluster, Severity>,
    String
  >
  symptomScores =
      GeneratedColumn<String>(
        'symptom_scores',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      ).withConverter<Map<SymptomCluster, Severity>>(
        $CheckInsTable.$convertersymptomScores,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Severity, int> severity =
      GeneratedColumn<int>(
        'severity',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Severity>($CheckInsTable.$converterseverity);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    episodeId,
    at,
    overall,
    symptomScores,
    severity,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'check_ins';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckIn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('overall')) {
      context.handle(
        _overallMeta,
        overall.isAcceptableOrUnknown(data['overall']!, _overallMeta),
      );
    } else if (isInserting) {
      context.missing(_overallMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CheckIn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckIn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      overall: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}overall'],
      )!,
      symptomScores: $CheckInsTable.$convertersymptomScores.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}symptom_scores'],
        )!,
      ),
      severity: $CheckInsTable.$converterseverity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}severity'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $CheckInsTable createAlias(String alias) {
    return $CheckInsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<SymptomCluster, Severity>, String>
  $convertersymptomScores = const SymptomScoresConverter();
  static JsonTypeConverter2<Severity, int, int> $converterseverity =
      const EnumIndexConverter<Severity>(Severity.values);
}

class CheckIn extends DataClass implements Insertable<CheckIn> {
  final int id;
  final int episodeId;
  final DateTime at;
  final int overall;
  final Map<SymptomCluster, Severity> symptomScores;
  final Severity severity;
  final String? note;
  const CheckIn({
    required this.id,
    required this.episodeId,
    required this.at,
    required this.overall,
    required this.symptomScores,
    required this.severity,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['episode_id'] = Variable<int>(episodeId);
    map['at'] = Variable<DateTime>(at);
    map['overall'] = Variable<int>(overall);
    {
      map['symptom_scores'] = Variable<String>(
        $CheckInsTable.$convertersymptomScores.toSql(symptomScores),
      );
    }
    {
      map['severity'] = Variable<int>(
        $CheckInsTable.$converterseverity.toSql(severity),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  CheckInsCompanion toCompanion(bool nullToAbsent) {
    return CheckInsCompanion(
      id: Value(id),
      episodeId: Value(episodeId),
      at: Value(at),
      overall: Value(overall),
      symptomScores: Value(symptomScores),
      severity: Value(severity),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory CheckIn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckIn(
      id: serializer.fromJson<int>(json['id']),
      episodeId: serializer.fromJson<int>(json['episodeId']),
      at: serializer.fromJson<DateTime>(json['at']),
      overall: serializer.fromJson<int>(json['overall']),
      symptomScores: serializer.fromJson<Map<SymptomCluster, Severity>>(
        json['symptomScores'],
      ),
      severity: $CheckInsTable.$converterseverity.fromJson(
        serializer.fromJson<int>(json['severity']),
      ),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'episodeId': serializer.toJson<int>(episodeId),
      'at': serializer.toJson<DateTime>(at),
      'overall': serializer.toJson<int>(overall),
      'symptomScores': serializer.toJson<Map<SymptomCluster, Severity>>(
        symptomScores,
      ),
      'severity': serializer.toJson<int>(
        $CheckInsTable.$converterseverity.toJson(severity),
      ),
      'note': serializer.toJson<String?>(note),
    };
  }

  CheckIn copyWith({
    int? id,
    int? episodeId,
    DateTime? at,
    int? overall,
    Map<SymptomCluster, Severity>? symptomScores,
    Severity? severity,
    Value<String?> note = const Value.absent(),
  }) => CheckIn(
    id: id ?? this.id,
    episodeId: episodeId ?? this.episodeId,
    at: at ?? this.at,
    overall: overall ?? this.overall,
    symptomScores: symptomScores ?? this.symptomScores,
    severity: severity ?? this.severity,
    note: note.present ? note.value : this.note,
  );
  CheckIn copyWithCompanion(CheckInsCompanion data) {
    return CheckIn(
      id: data.id.present ? data.id.value : this.id,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      at: data.at.present ? data.at.value : this.at,
      overall: data.overall.present ? data.overall.value : this.overall,
      symptomScores: data.symptomScores.present
          ? data.symptomScores.value
          : this.symptomScores,
      severity: data.severity.present ? data.severity.value : this.severity,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckIn(')
          ..write('id: $id, ')
          ..write('episodeId: $episodeId, ')
          ..write('at: $at, ')
          ..write('overall: $overall, ')
          ..write('symptomScores: $symptomScores, ')
          ..write('severity: $severity, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, episodeId, at, overall, symptomScores, severity, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckIn &&
          other.id == this.id &&
          other.episodeId == this.episodeId &&
          other.at == this.at &&
          other.overall == this.overall &&
          other.symptomScores == this.symptomScores &&
          other.severity == this.severity &&
          other.note == this.note);
}

class CheckInsCompanion extends UpdateCompanion<CheckIn> {
  final Value<int> id;
  final Value<int> episodeId;
  final Value<DateTime> at;
  final Value<int> overall;
  final Value<Map<SymptomCluster, Severity>> symptomScores;
  final Value<Severity> severity;
  final Value<String?> note;
  const CheckInsCompanion({
    this.id = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.at = const Value.absent(),
    this.overall = const Value.absent(),
    this.symptomScores = const Value.absent(),
    this.severity = const Value.absent(),
    this.note = const Value.absent(),
  });
  CheckInsCompanion.insert({
    this.id = const Value.absent(),
    required int episodeId,
    required DateTime at,
    required int overall,
    this.symptomScores = const Value.absent(),
    required Severity severity,
    this.note = const Value.absent(),
  }) : episodeId = Value(episodeId),
       at = Value(at),
       overall = Value(overall),
       severity = Value(severity);
  static Insertable<CheckIn> custom({
    Expression<int>? id,
    Expression<int>? episodeId,
    Expression<DateTime>? at,
    Expression<int>? overall,
    Expression<String>? symptomScores,
    Expression<int>? severity,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (episodeId != null) 'episode_id': episodeId,
      if (at != null) 'at': at,
      if (overall != null) 'overall': overall,
      if (symptomScores != null) 'symptom_scores': symptomScores,
      if (severity != null) 'severity': severity,
      if (note != null) 'note': note,
    });
  }

  CheckInsCompanion copyWith({
    Value<int>? id,
    Value<int>? episodeId,
    Value<DateTime>? at,
    Value<int>? overall,
    Value<Map<SymptomCluster, Severity>>? symptomScores,
    Value<Severity>? severity,
    Value<String?>? note,
  }) {
    return CheckInsCompanion(
      id: id ?? this.id,
      episodeId: episodeId ?? this.episodeId,
      at: at ?? this.at,
      overall: overall ?? this.overall,
      symptomScores: symptomScores ?? this.symptomScores,
      severity: severity ?? this.severity,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (overall.present) {
      map['overall'] = Variable<int>(overall.value);
    }
    if (symptomScores.present) {
      map['symptom_scores'] = Variable<String>(
        $CheckInsTable.$convertersymptomScores.toSql(symptomScores.value),
      );
    }
    if (severity.present) {
      map['severity'] = Variable<int>(
        $CheckInsTable.$converterseverity.toSql(severity.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckInsCompanion(')
          ..write('id: $id, ')
          ..write('episodeId: $episodeId, ')
          ..write('at: $at, ')
          ..write('overall: $overall, ')
          ..write('symptomScores: $symptomScores, ')
          ..write('severity: $severity, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $DailySummariesTable extends DailySummaries
    with TableInfo<$DailySummariesTable, DailySummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailySummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Severity?, int> maxSeverity =
      GeneratedColumn<int>(
        'max_severity',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<Severity?>($DailySummariesTable.$convertermaxSeverityn);
  static const VerificationMeta _activeEpisodeIdMeta = const VerificationMeta(
    'activeEpisodeId',
  );
  @override
  late final GeneratedColumn<int> activeEpisodeId = GeneratedColumn<int>(
    'active_episode_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkInCountMeta = const VerificationMeta(
    'checkInCount',
  );
  @override
  late final GeneratedColumn<int> checkInCount = GeneratedColumn<int>(
    'check_in_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    day,
    maxSeverity,
    activeEpisodeId,
    checkInCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailySummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    }
    if (data.containsKey('active_episode_id')) {
      context.handle(
        _activeEpisodeIdMeta,
        activeEpisodeId.isAcceptableOrUnknown(
          data['active_episode_id']!,
          _activeEpisodeIdMeta,
        ),
      );
    }
    if (data.containsKey('check_in_count')) {
      context.handle(
        _checkInCountMeta,
        checkInCount.isAcceptableOrUnknown(
          data['check_in_count']!,
          _checkInCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  DailySummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailySummary(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day'],
      )!,
      maxSeverity: $DailySummariesTable.$convertermaxSeverityn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}max_severity'],
        ),
      ),
      activeEpisodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_episode_id'],
      ),
      checkInCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}check_in_count'],
      )!,
    );
  }

  @override
  $DailySummariesTable createAlias(String alias) {
    return $DailySummariesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Severity, int, int> $convertermaxSeverity =
      const EnumIndexConverter<Severity>(Severity.values);
  static JsonTypeConverter2<Severity?, int?, int?> $convertermaxSeverityn =
      JsonTypeConverter2.asNullable($convertermaxSeverity);
}

class DailySummary extends DataClass implements Insertable<DailySummary> {
  final int day;
  final Severity? maxSeverity;
  final int? activeEpisodeId;
  final int checkInCount;
  const DailySummary({
    required this.day,
    this.maxSeverity,
    this.activeEpisodeId,
    required this.checkInCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<int>(day);
    if (!nullToAbsent || maxSeverity != null) {
      map['max_severity'] = Variable<int>(
        $DailySummariesTable.$convertermaxSeverityn.toSql(maxSeverity),
      );
    }
    if (!nullToAbsent || activeEpisodeId != null) {
      map['active_episode_id'] = Variable<int>(activeEpisodeId);
    }
    map['check_in_count'] = Variable<int>(checkInCount);
    return map;
  }

  DailySummariesCompanion toCompanion(bool nullToAbsent) {
    return DailySummariesCompanion(
      day: Value(day),
      maxSeverity: maxSeverity == null && nullToAbsent
          ? const Value.absent()
          : Value(maxSeverity),
      activeEpisodeId: activeEpisodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeEpisodeId),
      checkInCount: Value(checkInCount),
    );
  }

  factory DailySummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySummary(
      day: serializer.fromJson<int>(json['day']),
      maxSeverity: $DailySummariesTable.$convertermaxSeverityn.fromJson(
        serializer.fromJson<int?>(json['maxSeverity']),
      ),
      activeEpisodeId: serializer.fromJson<int?>(json['activeEpisodeId']),
      checkInCount: serializer.fromJson<int>(json['checkInCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<int>(day),
      'maxSeverity': serializer.toJson<int?>(
        $DailySummariesTable.$convertermaxSeverityn.toJson(maxSeverity),
      ),
      'activeEpisodeId': serializer.toJson<int?>(activeEpisodeId),
      'checkInCount': serializer.toJson<int>(checkInCount),
    };
  }

  DailySummary copyWith({
    int? day,
    Value<Severity?> maxSeverity = const Value.absent(),
    Value<int?> activeEpisodeId = const Value.absent(),
    int? checkInCount,
  }) => DailySummary(
    day: day ?? this.day,
    maxSeverity: maxSeverity.present ? maxSeverity.value : this.maxSeverity,
    activeEpisodeId: activeEpisodeId.present
        ? activeEpisodeId.value
        : this.activeEpisodeId,
    checkInCount: checkInCount ?? this.checkInCount,
  );
  DailySummary copyWithCompanion(DailySummariesCompanion data) {
    return DailySummary(
      day: data.day.present ? data.day.value : this.day,
      maxSeverity: data.maxSeverity.present
          ? data.maxSeverity.value
          : this.maxSeverity,
      activeEpisodeId: data.activeEpisodeId.present
          ? data.activeEpisodeId.value
          : this.activeEpisodeId,
      checkInCount: data.checkInCount.present
          ? data.checkInCount.value
          : this.checkInCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySummary(')
          ..write('day: $day, ')
          ..write('maxSeverity: $maxSeverity, ')
          ..write('activeEpisodeId: $activeEpisodeId, ')
          ..write('checkInCount: $checkInCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(day, maxSeverity, activeEpisodeId, checkInCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySummary &&
          other.day == this.day &&
          other.maxSeverity == this.maxSeverity &&
          other.activeEpisodeId == this.activeEpisodeId &&
          other.checkInCount == this.checkInCount);
}

class DailySummariesCompanion extends UpdateCompanion<DailySummary> {
  final Value<int> day;
  final Value<Severity?> maxSeverity;
  final Value<int?> activeEpisodeId;
  final Value<int> checkInCount;
  const DailySummariesCompanion({
    this.day = const Value.absent(),
    this.maxSeverity = const Value.absent(),
    this.activeEpisodeId = const Value.absent(),
    this.checkInCount = const Value.absent(),
  });
  DailySummariesCompanion.insert({
    this.day = const Value.absent(),
    this.maxSeverity = const Value.absent(),
    this.activeEpisodeId = const Value.absent(),
    this.checkInCount = const Value.absent(),
  });
  static Insertable<DailySummary> custom({
    Expression<int>? day,
    Expression<int>? maxSeverity,
    Expression<int>? activeEpisodeId,
    Expression<int>? checkInCount,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (maxSeverity != null) 'max_severity': maxSeverity,
      if (activeEpisodeId != null) 'active_episode_id': activeEpisodeId,
      if (checkInCount != null) 'check_in_count': checkInCount,
    });
  }

  DailySummariesCompanion copyWith({
    Value<int>? day,
    Value<Severity?>? maxSeverity,
    Value<int?>? activeEpisodeId,
    Value<int>? checkInCount,
  }) {
    return DailySummariesCompanion(
      day: day ?? this.day,
      maxSeverity: maxSeverity ?? this.maxSeverity,
      activeEpisodeId: activeEpisodeId ?? this.activeEpisodeId,
      checkInCount: checkInCount ?? this.checkInCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (maxSeverity.present) {
      map['max_severity'] = Variable<int>(
        $DailySummariesTable.$convertermaxSeverityn.toSql(maxSeverity.value),
      );
    }
    if (activeEpisodeId.present) {
      map['active_episode_id'] = Variable<int>(activeEpisodeId.value);
    }
    if (checkInCount.present) {
      map['check_in_count'] = Variable<int>(checkInCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySummariesCompanion(')
          ..write('day: $day, ')
          ..write('maxSeverity: $maxSeverity, ')
          ..write('activeEpisodeId: $activeEpisodeId, ')
          ..write('checkInCount: $checkInCount')
          ..write(')'))
        .toString();
  }
}

class $TreatmentsTable extends Treatments
    with TableInfo<$TreatmentsTable, Treatment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreatmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _treatmentClassMeta = const VerificationMeta(
    'treatmentClass',
  );
  @override
  late final GeneratedColumn<String> treatmentClass = GeneratedColumn<String>(
    'treatment_class',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doseMeta = const VerificationMeta('dose');
  @override
  late final GeneratedColumn<String> dose = GeneratedColumn<String>(
    'dose',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prescriberMeta = const VerificationMeta(
    'prescriber',
  );
  @override
  late final GeneratedColumn<String> prescriber = GeneratedColumn<String>(
    'prescriber',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    treatmentClass,
    dose,
    prescriber,
    startedAt,
    endedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'treatments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Treatment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('treatment_class')) {
      context.handle(
        _treatmentClassMeta,
        treatmentClass.isAcceptableOrUnknown(
          data['treatment_class']!,
          _treatmentClassMeta,
        ),
      );
    }
    if (data.containsKey('dose')) {
      context.handle(
        _doseMeta,
        dose.isAcceptableOrUnknown(data['dose']!, _doseMeta),
      );
    }
    if (data.containsKey('prescriber')) {
      context.handle(
        _prescriberMeta,
        prescriber.isAcceptableOrUnknown(data['prescriber']!, _prescriberMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Treatment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Treatment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      treatmentClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treatment_class'],
      ),
      dose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose'],
      ),
      prescriber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prescriber'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $TreatmentsTable createAlias(String alias) {
    return $TreatmentsTable(attachedDatabase, alias);
  }
}

class Treatment extends DataClass implements Insertable<Treatment> {
  final int id;
  final String name;
  final String? treatmentClass;
  final String? dose;
  final String? prescriber;
  final DateTime? startedAt;
  final DateTime? endedAt;
  const Treatment({
    required this.id,
    required this.name,
    this.treatmentClass,
    this.dose,
    this.prescriber,
    this.startedAt,
    this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || treatmentClass != null) {
      map['treatment_class'] = Variable<String>(treatmentClass);
    }
    if (!nullToAbsent || dose != null) {
      map['dose'] = Variable<String>(dose);
    }
    if (!nullToAbsent || prescriber != null) {
      map['prescriber'] = Variable<String>(prescriber);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    return map;
  }

  TreatmentsCompanion toCompanion(bool nullToAbsent) {
    return TreatmentsCompanion(
      id: Value(id),
      name: Value(name),
      treatmentClass: treatmentClass == null && nullToAbsent
          ? const Value.absent()
          : Value(treatmentClass),
      dose: dose == null && nullToAbsent ? const Value.absent() : Value(dose),
      prescriber: prescriber == null && nullToAbsent
          ? const Value.absent()
          : Value(prescriber),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory Treatment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Treatment(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      treatmentClass: serializer.fromJson<String?>(json['treatmentClass']),
      dose: serializer.fromJson<String?>(json['dose']),
      prescriber: serializer.fromJson<String?>(json['prescriber']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'treatmentClass': serializer.toJson<String?>(treatmentClass),
      'dose': serializer.toJson<String?>(dose),
      'prescriber': serializer.toJson<String?>(prescriber),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
    };
  }

  Treatment copyWith({
    int? id,
    String? name,
    Value<String?> treatmentClass = const Value.absent(),
    Value<String?> dose = const Value.absent(),
    Value<String?> prescriber = const Value.absent(),
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> endedAt = const Value.absent(),
  }) => Treatment(
    id: id ?? this.id,
    name: name ?? this.name,
    treatmentClass: treatmentClass.present
        ? treatmentClass.value
        : this.treatmentClass,
    dose: dose.present ? dose.value : this.dose,
    prescriber: prescriber.present ? prescriber.value : this.prescriber,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
  );
  Treatment copyWithCompanion(TreatmentsCompanion data) {
    return Treatment(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      treatmentClass: data.treatmentClass.present
          ? data.treatmentClass.value
          : this.treatmentClass,
      dose: data.dose.present ? data.dose.value : this.dose,
      prescriber: data.prescriber.present
          ? data.prescriber.value
          : this.prescriber,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Treatment(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('treatmentClass: $treatmentClass, ')
          ..write('dose: $dose, ')
          ..write('prescriber: $prescriber, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    treatmentClass,
    dose,
    prescriber,
    startedAt,
    endedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Treatment &&
          other.id == this.id &&
          other.name == this.name &&
          other.treatmentClass == this.treatmentClass &&
          other.dose == this.dose &&
          other.prescriber == this.prescriber &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt);
}

class TreatmentsCompanion extends UpdateCompanion<Treatment> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> treatmentClass;
  final Value<String?> dose;
  final Value<String?> prescriber;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> endedAt;
  const TreatmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.treatmentClass = const Value.absent(),
    this.dose = const Value.absent(),
    this.prescriber = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
  });
  TreatmentsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.treatmentClass = const Value.absent(),
    this.dose = const Value.absent(),
    this.prescriber = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Treatment> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? treatmentClass,
    Expression<String>? dose,
    Expression<String>? prescriber,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (treatmentClass != null) 'treatment_class': treatmentClass,
      if (dose != null) 'dose': dose,
      if (prescriber != null) 'prescriber': prescriber,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
    });
  }

  TreatmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? treatmentClass,
    Value<String?>? dose,
    Value<String?>? prescriber,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? endedAt,
  }) {
    return TreatmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      treatmentClass: treatmentClass ?? this.treatmentClass,
      dose: dose ?? this.dose,
      prescriber: prescriber ?? this.prescriber,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (treatmentClass.present) {
      map['treatment_class'] = Variable<String>(treatmentClass.value);
    }
    if (dose.present) {
      map['dose'] = Variable<String>(dose.value);
    }
    if (prescriber.present) {
      map['prescriber'] = Variable<String>(prescriber.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreatmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('treatmentClass: $treatmentClass, ')
          ..write('dose: $dose, ')
          ..write('prescriber: $prescriber, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }
}

class $AssessmentsTable extends Assessments
    with TableInfo<$AssessmentsTable, Assessment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssessmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _waldingerAnswersMeta = const VerificationMeta(
    'waldingerAnswers',
  );
  @override
  late final GeneratedColumn<String> waldingerAnswers = GeneratedColumn<String>(
    'waldinger_answers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _onsetTypeMeta = const VerificationMeta(
    'onsetType',
  );
  @override
  late final GeneratedColumn<String> onsetType = GeneratedColumn<String>(
    'onset_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, waldingerAnswers, onsetType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Assessment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('waldinger_answers')) {
      context.handle(
        _waldingerAnswersMeta,
        waldingerAnswers.isAcceptableOrUnknown(
          data['waldinger_answers']!,
          _waldingerAnswersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_waldingerAnswersMeta);
    }
    if (data.containsKey('onset_type')) {
      context.handle(
        _onsetTypeMeta,
        onsetType.isAcceptableOrUnknown(data['onset_type']!, _onsetTypeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Assessment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Assessment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      waldingerAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}waldinger_answers'],
      )!,
      onsetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}onset_type'],
      ),
    );
  }

  @override
  $AssessmentsTable createAlias(String alias) {
    return $AssessmentsTable(attachedDatabase, alias);
  }
}

class Assessment extends DataClass implements Insertable<Assessment> {
  final int id;
  final DateTime date;
  final String waldingerAnswers;
  final String? onsetType;
  const Assessment({
    required this.id,
    required this.date,
    required this.waldingerAnswers,
    this.onsetType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['waldinger_answers'] = Variable<String>(waldingerAnswers);
    if (!nullToAbsent || onsetType != null) {
      map['onset_type'] = Variable<String>(onsetType);
    }
    return map;
  }

  AssessmentsCompanion toCompanion(bool nullToAbsent) {
    return AssessmentsCompanion(
      id: Value(id),
      date: Value(date),
      waldingerAnswers: Value(waldingerAnswers),
      onsetType: onsetType == null && nullToAbsent
          ? const Value.absent()
          : Value(onsetType),
    );
  }

  factory Assessment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Assessment(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      waldingerAnswers: serializer.fromJson<String>(json['waldingerAnswers']),
      onsetType: serializer.fromJson<String?>(json['onsetType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'waldingerAnswers': serializer.toJson<String>(waldingerAnswers),
      'onsetType': serializer.toJson<String?>(onsetType),
    };
  }

  Assessment copyWith({
    int? id,
    DateTime? date,
    String? waldingerAnswers,
    Value<String?> onsetType = const Value.absent(),
  }) => Assessment(
    id: id ?? this.id,
    date: date ?? this.date,
    waldingerAnswers: waldingerAnswers ?? this.waldingerAnswers,
    onsetType: onsetType.present ? onsetType.value : this.onsetType,
  );
  Assessment copyWithCompanion(AssessmentsCompanion data) {
    return Assessment(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      waldingerAnswers: data.waldingerAnswers.present
          ? data.waldingerAnswers.value
          : this.waldingerAnswers,
      onsetType: data.onsetType.present ? data.onsetType.value : this.onsetType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Assessment(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('waldingerAnswers: $waldingerAnswers, ')
          ..write('onsetType: $onsetType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, waldingerAnswers, onsetType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Assessment &&
          other.id == this.id &&
          other.date == this.date &&
          other.waldingerAnswers == this.waldingerAnswers &&
          other.onsetType == this.onsetType);
}

class AssessmentsCompanion extends UpdateCompanion<Assessment> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> waldingerAnswers;
  final Value<String?> onsetType;
  const AssessmentsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.waldingerAnswers = const Value.absent(),
    this.onsetType = const Value.absent(),
  });
  AssessmentsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String waldingerAnswers,
    this.onsetType = const Value.absent(),
  }) : date = Value(date),
       waldingerAnswers = Value(waldingerAnswers);
  static Insertable<Assessment> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? waldingerAnswers,
    Expression<String>? onsetType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (waldingerAnswers != null) 'waldinger_answers': waldingerAnswers,
      if (onsetType != null) 'onset_type': onsetType,
    });
  }

  AssessmentsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? waldingerAnswers,
    Value<String?>? onsetType,
  }) {
    return AssessmentsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      waldingerAnswers: waldingerAnswers ?? this.waldingerAnswers,
      onsetType: onsetType ?? this.onsetType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (waldingerAnswers.present) {
      map['waldinger_answers'] = Variable<String>(waldingerAnswers.value);
    }
    if (onsetType.present) {
      map['onset_type'] = Variable<String>(onsetType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('waldingerAnswers: $waldingerAnswers, ')
          ..write('onsetType: $onsetType')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EpisodesTable episodes = $EpisodesTable(this);
  late final $CheckInsTable checkIns = $CheckInsTable(this);
  late final $DailySummariesTable dailySummaries = $DailySummariesTable(this);
  late final $TreatmentsTable treatments = $TreatmentsTable(this);
  late final $AssessmentsTable assessments = $AssessmentsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    episodes,
    checkIns,
    dailySummaries,
    treatments,
    assessments,
    settings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'episodes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('check_ins', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$EpisodesTableCreateCompanionBuilder = EpisodesCompanion Function({
  Value<int> id,
  required DateTime occurredAt,
  required EpisodeType type,
  Value<int?> sleepQuality,
  Value<bool?> alcohol,
  Value<int?> stress,
  Value<List<String>> preInterventions,
  Value<String?> note,
  Value<DateTime?> recoveredAt,
  Value<int?> recoveryPct,
  Value<Severity?> peakSeverity,
  Value<int> checkInCount,
});
typedef $$EpisodesTableUpdateCompanionBuilder = EpisodesCompanion Function({
  Value<int> id,
  Value<DateTime> occurredAt,
  Value<EpisodeType> type,
  Value<int?> sleepQuality,
  Value<bool?> alcohol,
  Value<int?> stress,
  Value<List<String>> preInterventions,
  Value<String?> note,
  Value<DateTime?> recoveredAt,
  Value<int?> recoveryPct,
  Value<Severity?> peakSeverity,
  Value<int> checkInCount,
});

final class $$EpisodesTableReferences
    extends BaseReferences<_$AppDatabase, $EpisodesTable, Episode> {
  $$EpisodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CheckInsTable, List<CheckIn>> _checkInsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.checkIns,
    aliasName: 'episodes__id__check_ins__episode_id',
  );

  $$CheckInsTableProcessedTableManager get checkInsRefs {
    final manager = $$CheckInsTableTableManager(
      $_db,
      $_db.checkIns,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_checkInsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EpisodesTableFilterComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableFilterComposer({
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

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EpisodeType, EpisodeType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get alcohol => $composableBuilder(
    column: $table.alcohol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stress => $composableBuilder(
    column: $table.stress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get preInterventions => $composableBuilder(
    column: $table.preInterventions,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recoveredAt => $composableBuilder(
    column: $table.recoveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recoveryPct => $composableBuilder(
    column: $table.recoveryPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Severity?, Severity, int> get peakSeverity =>
      $composableBuilder(
        column: $table.peakSeverity,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get checkInCount => $composableBuilder(
    column: $table.checkInCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> checkInsRefs(
    Expression<bool> Function($$CheckInsTableFilterComposer f) f,
  ) {
    final $$CheckInsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkIns,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckInsTableFilterComposer(
            $db: $db,
            $table: $db.checkIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EpisodesTableOrderingComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get alcohol => $composableBuilder(
    column: $table.alcohol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stress => $composableBuilder(
    column: $table.stress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preInterventions => $composableBuilder(
    column: $table.preInterventions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recoveredAt => $composableBuilder(
    column: $table.recoveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recoveryPct => $composableBuilder(
    column: $table.recoveryPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get peakSeverity => $composableBuilder(
    column: $table.peakSeverity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get checkInCount => $composableBuilder(
    column: $table.checkInCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EpisodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<EpisodeType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get alcohol =>
      $composableBuilder(column: $table.alcohol, builder: (column) => column);

  GeneratedColumn<int> get stress =>
      $composableBuilder(column: $table.stress, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get preInterventions =>
      $composableBuilder(
        column: $table.preInterventions,
        builder: (column) => column,
      );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get recoveredAt => $composableBuilder(
    column: $table.recoveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recoveryPct => $composableBuilder(
    column: $table.recoveryPct,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Severity?, int> get peakSeverity =>
      $composableBuilder(
        column: $table.peakSeverity,
        builder: (column) => column,
      );

  GeneratedColumn<int> get checkInCount => $composableBuilder(
    column: $table.checkInCount,
    builder: (column) => column,
  );

  Expression<T> checkInsRefs<T extends Object>(
    Expression<T> Function($$CheckInsTableAnnotationComposer a) f,
  ) {
    final $$CheckInsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkIns,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckInsTableAnnotationComposer(
            $db: $db,
            $table: $db.checkIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EpisodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EpisodesTable,
          Episode,
          $$EpisodesTableFilterComposer,
          $$EpisodesTableOrderingComposer,
          $$EpisodesTableAnnotationComposer,
          $$EpisodesTableCreateCompanionBuilder,
          $$EpisodesTableUpdateCompanionBuilder,
          (Episode, $$EpisodesTableReferences),
          Episode,
          PrefetchHooks Function({bool checkInsRefs})
        > {
  $$EpisodesTableTableManager(_$AppDatabase db, $EpisodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpisodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<EpisodeType> type = const Value.absent(),
                Value<int?> sleepQuality = const Value.absent(),
                Value<bool?> alcohol = const Value.absent(),
                Value<int?> stress = const Value.absent(),
                Value<List<String>> preInterventions = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> recoveredAt = const Value.absent(),
                Value<int?> recoveryPct = const Value.absent(),
                Value<Severity?> peakSeverity = const Value.absent(),
                Value<int> checkInCount = const Value.absent(),
              }) => EpisodesCompanion(
                id: id,
                occurredAt: occurredAt,
                type: type,
                sleepQuality: sleepQuality,
                alcohol: alcohol,
                stress: stress,
                preInterventions: preInterventions,
                note: note,
                recoveredAt: recoveredAt,
                recoveryPct: recoveryPct,
                peakSeverity: peakSeverity,
                checkInCount: checkInCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime occurredAt,
                required EpisodeType type,
                Value<int?> sleepQuality = const Value.absent(),
                Value<bool?> alcohol = const Value.absent(),
                Value<int?> stress = const Value.absent(),
                Value<List<String>> preInterventions = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> recoveredAt = const Value.absent(),
                Value<int?> recoveryPct = const Value.absent(),
                Value<Severity?> peakSeverity = const Value.absent(),
                Value<int> checkInCount = const Value.absent(),
              }) => EpisodesCompanion.insert(
                id: id,
                occurredAt: occurredAt,
                type: type,
                sleepQuality: sleepQuality,
                alcohol: alcohol,
                stress: stress,
                preInterventions: preInterventions,
                note: note,
                recoveredAt: recoveredAt,
                recoveryPct: recoveryPct,
                peakSeverity: peakSeverity,
                checkInCount: checkInCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EpisodesTable, Episode>(table),
                  $$EpisodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({checkInsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (checkInsRefs) db.checkIns],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (checkInsRefs)
                    await $_getPrefetchedData<Episode, $EpisodesTable, CheckIn>(
                      currentTable: table,
                      referencedTable: $$EpisodesTableReferences
                          ._checkInsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EpisodesTableReferences(db, table, p0).checkInsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.episodeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EpisodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EpisodesTable,
      Episode,
      $$EpisodesTableFilterComposer,
      $$EpisodesTableOrderingComposer,
      $$EpisodesTableAnnotationComposer,
      $$EpisodesTableCreateCompanionBuilder,
      $$EpisodesTableUpdateCompanionBuilder,
      (Episode, $$EpisodesTableReferences),
      Episode,
      PrefetchHooks Function({bool checkInsRefs})
    >;
typedef $$CheckInsTableCreateCompanionBuilder = CheckInsCompanion Function({
  Value<int> id,
  required int episodeId,
  required DateTime at,
  required int overall,
  Value<Map<SymptomCluster, Severity>> symptomScores,
  required Severity severity,
  Value<String?> note,
});
typedef $$CheckInsTableUpdateCompanionBuilder = CheckInsCompanion Function({
  Value<int> id,
  Value<int> episodeId,
  Value<DateTime> at,
  Value<int> overall,
  Value<Map<SymptomCluster, Severity>> symptomScores,
  Value<Severity> severity,
  Value<String?> note,
});

final class $$CheckInsTableReferences
    extends BaseReferences<_$AppDatabase, $CheckInsTable, CheckIn> {
  $$CheckInsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EpisodesTable _episodeIdTable(_$AppDatabase db) =>
      db.episodes.createAlias('check_ins__episode_id__episodes__id');

  $$EpisodesTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<int>('episode_id')!;

    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CheckInsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckInsTable> {
  $$CheckInsTableFilterComposer({
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

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get overall => $composableBuilder(
    column: $table.overall,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<SymptomCluster, Severity>,
    Map<SymptomCluster, Severity>,
    String
  >
  get symptomScores => $composableBuilder(
    column: $table.symptomScores,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Severity, Severity, int> get severity =>
      $composableBuilder(
        column: $table.severity,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$EpisodesTableFilterComposer get episodeId {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckInsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckInsTable> {
  $$CheckInsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get overall => $composableBuilder(
    column: $table.overall,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptomScores => $composableBuilder(
    column: $table.symptomScores,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$EpisodesTableOrderingComposer get episodeId {
    final $$EpisodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableOrderingComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckInsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckInsTable> {
  $$CheckInsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<int> get overall =>
      $composableBuilder(column: $table.overall, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<SymptomCluster, Severity>, String>
  get symptomScores => $composableBuilder(
    column: $table.symptomScores,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Severity, int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$EpisodesTableAnnotationComposer get episodeId {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckInsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckInsTable,
          CheckIn,
          $$CheckInsTableFilterComposer,
          $$CheckInsTableOrderingComposer,
          $$CheckInsTableAnnotationComposer,
          $$CheckInsTableCreateCompanionBuilder,
          $$CheckInsTableUpdateCompanionBuilder,
          (CheckIn, $$CheckInsTableReferences),
          CheckIn,
          PrefetchHooks Function({bool episodeId})
        > {
  $$CheckInsTableTableManager(_$AppDatabase db, $CheckInsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckInsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckInsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckInsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> episodeId = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> overall = const Value.absent(),
                Value<Map<SymptomCluster, Severity>> symptomScores =
                    const Value.absent(),
                Value<Severity> severity = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => CheckInsCompanion(
                id: id,
                episodeId: episodeId,
                at: at,
                overall: overall,
                symptomScores: symptomScores,
                severity: severity,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int episodeId,
                required DateTime at,
                required int overall,
                Value<Map<SymptomCluster, Severity>> symptomScores =
                    const Value.absent(),
                required Severity severity,
                Value<String?> note = const Value.absent(),
              }) => CheckInsCompanion.insert(
                id: id,
                episodeId: episodeId,
                at: at,
                overall: overall,
                symptomScores: symptomScores,
                severity: severity,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CheckInsTable, CheckIn>(table),
                  $$CheckInsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (episodeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.episodeId,
                        referencedTable: $$CheckInsTableReferences
                            ._episodeIdTable(db),
                        referencedColumn: $$CheckInsTableReferences
                            ._episodeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CheckInsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckInsTable,
      CheckIn,
      $$CheckInsTableFilterComposer,
      $$CheckInsTableOrderingComposer,
      $$CheckInsTableAnnotationComposer,
      $$CheckInsTableCreateCompanionBuilder,
      $$CheckInsTableUpdateCompanionBuilder,
      (CheckIn, $$CheckInsTableReferences),
      CheckIn,
      PrefetchHooks Function({bool episodeId})
    >;
typedef $$DailySummariesTableCreateCompanionBuilder =
    DailySummariesCompanion Function({
      Value<int> day,
      Value<Severity?> maxSeverity,
      Value<int?> activeEpisodeId,
      Value<int> checkInCount,
    });
typedef $$DailySummariesTableUpdateCompanionBuilder =
    DailySummariesCompanion Function({
      Value<int> day,
      Value<Severity?> maxSeverity,
      Value<int?> activeEpisodeId,
      Value<int> checkInCount,
    });

class $$DailySummariesTableFilterComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Severity?, Severity, int> get maxSeverity =>
      $composableBuilder(
        column: $table.maxSeverity,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get activeEpisodeId => $composableBuilder(
    column: $table.activeEpisodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get checkInCount => $composableBuilder(
    column: $table.checkInCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailySummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxSeverity => $composableBuilder(
    column: $table.maxSeverity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeEpisodeId => $composableBuilder(
    column: $table.activeEpisodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get checkInCount => $composableBuilder(
    column: $table.checkInCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailySummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Severity?, int> get maxSeverity =>
      $composableBuilder(
        column: $table.maxSeverity,
        builder: (column) => column,
      );

  GeneratedColumn<int> get activeEpisodeId => $composableBuilder(
    column: $table.activeEpisodeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get checkInCount => $composableBuilder(
    column: $table.checkInCount,
    builder: (column) => column,
  );
}

class $$DailySummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailySummariesTable,
          DailySummary,
          $$DailySummariesTableFilterComposer,
          $$DailySummariesTableOrderingComposer,
          $$DailySummariesTableAnnotationComposer,
          $$DailySummariesTableCreateCompanionBuilder,
          $$DailySummariesTableUpdateCompanionBuilder,
          (
            DailySummary,
            BaseReferences<_$AppDatabase, $DailySummariesTable, DailySummary>,
          ),
          DailySummary,
          PrefetchHooks Function()
        > {
  $$DailySummariesTableTableManager(
    _$AppDatabase db,
    $DailySummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailySummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailySummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailySummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> day = const Value.absent(),
                Value<Severity?> maxSeverity = const Value.absent(),
                Value<int?> activeEpisodeId = const Value.absent(),
                Value<int> checkInCount = const Value.absent(),
              }) => DailySummariesCompanion(
                day: day,
                maxSeverity: maxSeverity,
                activeEpisodeId: activeEpisodeId,
                checkInCount: checkInCount,
              ),
          createCompanionCallback:
              ({
                Value<int> day = const Value.absent(),
                Value<Severity?> maxSeverity = const Value.absent(),
                Value<int?> activeEpisodeId = const Value.absent(),
                Value<int> checkInCount = const Value.absent(),
              }) => DailySummariesCompanion.insert(
                day: day,
                maxSeverity: maxSeverity,
                activeEpisodeId: activeEpisodeId,
                checkInCount: checkInCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailySummariesTable, DailySummary>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DailySummariesTable,
                    DailySummary
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailySummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailySummariesTable,
      DailySummary,
      $$DailySummariesTableFilterComposer,
      $$DailySummariesTableOrderingComposer,
      $$DailySummariesTableAnnotationComposer,
      $$DailySummariesTableCreateCompanionBuilder,
      $$DailySummariesTableUpdateCompanionBuilder,
      (
        DailySummary,
        BaseReferences<_$AppDatabase, $DailySummariesTable, DailySummary>,
      ),
      DailySummary,
      PrefetchHooks Function()
    >;
typedef $$TreatmentsTableCreateCompanionBuilder = TreatmentsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> treatmentClass,
  Value<String?> dose,
  Value<String?> prescriber,
  Value<DateTime?> startedAt,
  Value<DateTime?> endedAt,
});
typedef $$TreatmentsTableUpdateCompanionBuilder = TreatmentsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> treatmentClass,
  Value<String?> dose,
  Value<String?> prescriber,
  Value<DateTime?> startedAt,
  Value<DateTime?> endedAt,
});

class $$TreatmentsTableFilterComposer
    extends Composer<_$AppDatabase, $TreatmentsTable> {
  $$TreatmentsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get treatmentClass => $composableBuilder(
    column: $table.treatmentClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dose => $composableBuilder(
    column: $table.dose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prescriber => $composableBuilder(
    column: $table.prescriber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TreatmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TreatmentsTable> {
  $$TreatmentsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get treatmentClass => $composableBuilder(
    column: $table.treatmentClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dose => $composableBuilder(
    column: $table.dose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prescriber => $composableBuilder(
    column: $table.prescriber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TreatmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TreatmentsTable> {
  $$TreatmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get treatmentClass => $composableBuilder(
    column: $table.treatmentClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dose =>
      $composableBuilder(column: $table.dose, builder: (column) => column);

  GeneratedColumn<String> get prescriber => $composableBuilder(
    column: $table.prescriber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);
}

class $$TreatmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TreatmentsTable,
          Treatment,
          $$TreatmentsTableFilterComposer,
          $$TreatmentsTableOrderingComposer,
          $$TreatmentsTableAnnotationComposer,
          $$TreatmentsTableCreateCompanionBuilder,
          $$TreatmentsTableUpdateCompanionBuilder,
          (
            Treatment,
            BaseReferences<_$AppDatabase, $TreatmentsTable, Treatment>,
          ),
          Treatment,
          PrefetchHooks Function()
        > {
  $$TreatmentsTableTableManager(_$AppDatabase db, $TreatmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreatmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreatmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreatmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> treatmentClass = const Value.absent(),
                Value<String?> dose = const Value.absent(),
                Value<String?> prescriber = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
              }) => TreatmentsCompanion(
                id: id,
                name: name,
                treatmentClass: treatmentClass,
                dose: dose,
                prescriber: prescriber,
                startedAt: startedAt,
                endedAt: endedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> treatmentClass = const Value.absent(),
                Value<String?> dose = const Value.absent(),
                Value<String?> prescriber = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
              }) => TreatmentsCompanion.insert(
                id: id,
                name: name,
                treatmentClass: treatmentClass,
                dose: dose,
                prescriber: prescriber,
                startedAt: startedAt,
                endedAt: endedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TreatmentsTable, Treatment>(table),
                  BaseReferences<_$AppDatabase, $TreatmentsTable, Treatment>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TreatmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TreatmentsTable,
      Treatment,
      $$TreatmentsTableFilterComposer,
      $$TreatmentsTableOrderingComposer,
      $$TreatmentsTableAnnotationComposer,
      $$TreatmentsTableCreateCompanionBuilder,
      $$TreatmentsTableUpdateCompanionBuilder,
      (Treatment, BaseReferences<_$AppDatabase, $TreatmentsTable, Treatment>),
      Treatment,
      PrefetchHooks Function()
    >;
typedef $$AssessmentsTableCreateCompanionBuilder =
    AssessmentsCompanion Function({
      Value<int> id,
      required DateTime date,
      required String waldingerAnswers,
      Value<String?> onsetType,
    });
typedef $$AssessmentsTableUpdateCompanionBuilder =
    AssessmentsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String> waldingerAnswers,
      Value<String?> onsetType,
    });

class $$AssessmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get waldingerAnswers => $composableBuilder(
    column: $table.waldingerAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get onsetType => $composableBuilder(
    column: $table.onsetType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssessmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get waldingerAnswers => $composableBuilder(
    column: $table.waldingerAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get onsetType => $composableBuilder(
    column: $table.onsetType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssessmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get waldingerAnswers => $composableBuilder(
    column: $table.waldingerAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<String> get onsetType =>
      $composableBuilder(column: $table.onsetType, builder: (column) => column);
}

class $$AssessmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssessmentsTable,
          Assessment,
          $$AssessmentsTableFilterComposer,
          $$AssessmentsTableOrderingComposer,
          $$AssessmentsTableAnnotationComposer,
          $$AssessmentsTableCreateCompanionBuilder,
          $$AssessmentsTableUpdateCompanionBuilder,
          (
            Assessment,
            BaseReferences<_$AppDatabase, $AssessmentsTable, Assessment>,
          ),
          Assessment,
          PrefetchHooks Function()
        > {
  $$AssessmentsTableTableManager(_$AppDatabase db, $AssessmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssessmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssessmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssessmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> waldingerAnswers = const Value.absent(),
                Value<String?> onsetType = const Value.absent(),
              }) => AssessmentsCompanion(
                id: id,
                date: date,
                waldingerAnswers: waldingerAnswers,
                onsetType: onsetType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String waldingerAnswers,
                Value<String?> onsetType = const Value.absent(),
              }) => AssessmentsCompanion.insert(
                id: id,
                date: date,
                waldingerAnswers: waldingerAnswers,
                onsetType: onsetType,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssessmentsTable, Assessment>(table),
                  BaseReferences<_$AppDatabase, $AssessmentsTable, Assessment>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssessmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssessmentsTable,
      Assessment,
      $$AssessmentsTableFilterComposer,
      $$AssessmentsTableOrderingComposer,
      $$AssessmentsTableAnnotationComposer,
      $$AssessmentsTableCreateCompanionBuilder,
      $$AssessmentsTableUpdateCompanionBuilder,
      (
        Assessment,
        BaseReferences<_$AppDatabase, $AssessmentsTable, Assessment>,
      ),
      Assessment,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EpisodesTableTableManager get episodes =>
      $$EpisodesTableTableManager(_db, _db.episodes);
  $$CheckInsTableTableManager get checkIns =>
      $$CheckInsTableTableManager(_db, _db.checkIns);
  $$DailySummariesTableTableManager get dailySummaries =>
      $$DailySummariesTableTableManager(_db, _db.dailySummaries);
  $$TreatmentsTableTableManager get treatments =>
      $$TreatmentsTableTableManager(_db, _db.treatments);
  $$AssessmentsTableTableManager get assessments =>
      $$AssessmentsTableTableManager(_db, _db.assessments);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
