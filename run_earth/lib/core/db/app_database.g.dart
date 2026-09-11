// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RunsTable extends Runs with TableInfo<$RunsTable, RunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kmMeta = const VerificationMeta('km');
  @override
  late final GeneratedColumn<double> km = GeneratedColumn<double>(
    'km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paceMeta = const VerificationMeta('pace');
  @override
  late final GeneratedColumn<String> pace = GeneratedColumn<String>(
    'pace',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durMeta = const VerificationMeta('dur');
  @override
  late final GeneratedColumn<String> dur = GeneratedColumn<String>(
    'dur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<int> kcal = GeneratedColumn<int>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RecordType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<RecordType>($RunsTable.$convertertype);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CoverImageType, int>
  coverImageType = GeneratedColumn<int>(
    'cover_image_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<CoverImageType>($RunsTable.$convertercoverImageType);
  static const VerificationMeta _coverImageUrlMeta = const VerificationMeta(
    'coverImageUrl',
  );
  @override
  late final GeneratedColumn<String> coverImageUrl = GeneratedColumn<String>(
    'cover_image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _marathonChallengeIdMeta =
      const VerificationMeta('marathonChallengeId');
  @override
  late final GeneratedColumn<String> marathonChallengeId =
      GeneratedColumn<String>(
        'marathon_challenge_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _marathonCourseIdMeta = const VerificationMeta(
    'marathonCourseId',
  );
  @override
  late final GeneratedColumn<String> marathonCourseId = GeneratedColumn<String>(
    'marathon_course_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsVerifiedMeta = const VerificationMeta(
    'gpsVerified',
  );
  @override
  late final GeneratedColumn<bool> gpsVerified = GeneratedColumn<bool>(
    'gps_verified',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("gps_verified" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RunSource, int> source =
      GeneratedColumn<int>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<RunSource>($RunsTable.$convertersource);
  static const VerificationMeta _routeMeta = const VerificationMeta('route');
  @override
  late final GeneratedColumn<String> route = GeneratedColumn<String>(
    'route',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    day,
    km,
    pace,
    dur,
    kcal,
    type,
    year,
    month,
    coverImageType,
    coverImageUrl,
    marathonChallengeId,
    marathonCourseId,
    gpsVerified,
    source,
    route,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('km')) {
      context.handle(_kmMeta, km.isAcceptableOrUnknown(data['km']!, _kmMeta));
    } else if (isInserting) {
      context.missing(_kmMeta);
    }
    if (data.containsKey('pace')) {
      context.handle(
        _paceMeta,
        pace.isAcceptableOrUnknown(data['pace']!, _paceMeta),
      );
    } else if (isInserting) {
      context.missing(_paceMeta);
    }
    if (data.containsKey('dur')) {
      context.handle(
        _durMeta,
        dur.isAcceptableOrUnknown(data['dur']!, _durMeta),
      );
    } else if (isInserting) {
      context.missing(_durMeta);
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('cover_image_url')) {
      context.handle(
        _coverImageUrlMeta,
        coverImageUrl.isAcceptableOrUnknown(
          data['cover_image_url']!,
          _coverImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('marathon_challenge_id')) {
      context.handle(
        _marathonChallengeIdMeta,
        marathonChallengeId.isAcceptableOrUnknown(
          data['marathon_challenge_id']!,
          _marathonChallengeIdMeta,
        ),
      );
    }
    if (data.containsKey('marathon_course_id')) {
      context.handle(
        _marathonCourseIdMeta,
        marathonCourseId.isAcceptableOrUnknown(
          data['marathon_course_id']!,
          _marathonCourseIdMeta,
        ),
      );
    }
    if (data.containsKey('gps_verified')) {
      context.handle(
        _gpsVerifiedMeta,
        gpsVerified.isAcceptableOrUnknown(
          data['gps_verified']!,
          _gpsVerifiedMeta,
        ),
      );
    }
    if (data.containsKey('route')) {
      context.handle(
        _routeMeta,
        route.isAcceptableOrUnknown(data['route']!, _routeMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      km: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}km'],
      )!,
      pace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pace'],
      )!,
      dur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dur'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kcal'],
      )!,
      type: $RunsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      coverImageType: $RunsTable.$convertercoverImageType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}cover_image_type'],
        )!,
      ),
      coverImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image_url'],
      ),
      marathonChallengeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marathon_challenge_id'],
      ),
      marathonCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marathon_course_id'],
      ),
      gpsVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}gps_verified'],
      ),
      source: $RunsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}source'],
        )!,
      ),
      route: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $RunsTable createAlias(String alias) {
    return $RunsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RecordType, int, int> $convertertype =
      const EnumIndexConverter<RecordType>(RecordType.values);
  static JsonTypeConverter2<CoverImageType, int, int> $convertercoverImageType =
      const EnumIndexConverter<CoverImageType>(CoverImageType.values);
  static JsonTypeConverter2<RunSource, int, int> $convertersource =
      const EnumIndexConverter<RunSource>(RunSource.values);
}

class RunRow extends DataClass implements Insertable<RunRow> {
  final String id;
  final String date;
  final String day;
  final double km;
  final String pace;
  final String dur;
  final int kcal;
  final RecordType type;
  final int year;
  final int month;
  final CoverImageType coverImageType;
  final String? coverImageUrl;
  final String? marathonChallengeId;
  final String? marathonCourseId;
  final bool? gpsVerified;
  final RunSource source;

  /// 추적된 GPS 경로. `[{"lat":..,"lng":..}, ...]` JSON 문자열로 저장.
  final String? route;

  /// 서버 업로드 완료 시각. null 이면 아직 안 올라간 것 = 동기화 대기.
  ///
  /// offline-handling.md 4 의 별도 `SyncQueueItem` 테이블 대신 이 플래그로
  /// 대기 목록을 표현한다(2026-09-12 결정) — 지금 올릴 종류가 러닝 하나뿐이라
  /// 큐 테이블은 같은 데이터를 두 곳에 두는 비용만 생긴다.
  final DateTime? syncedAt;
  const RunRow({
    required this.id,
    required this.date,
    required this.day,
    required this.km,
    required this.pace,
    required this.dur,
    required this.kcal,
    required this.type,
    required this.year,
    required this.month,
    required this.coverImageType,
    this.coverImageUrl,
    this.marathonChallengeId,
    this.marathonCourseId,
    this.gpsVerified,
    required this.source,
    this.route,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<String>(date);
    map['day'] = Variable<String>(day);
    map['km'] = Variable<double>(km);
    map['pace'] = Variable<String>(pace);
    map['dur'] = Variable<String>(dur);
    map['kcal'] = Variable<int>(kcal);
    {
      map['type'] = Variable<int>($RunsTable.$convertertype.toSql(type));
    }
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    {
      map['cover_image_type'] = Variable<int>(
        $RunsTable.$convertercoverImageType.toSql(coverImageType),
      );
    }
    if (!nullToAbsent || coverImageUrl != null) {
      map['cover_image_url'] = Variable<String>(coverImageUrl);
    }
    if (!nullToAbsent || marathonChallengeId != null) {
      map['marathon_challenge_id'] = Variable<String>(marathonChallengeId);
    }
    if (!nullToAbsent || marathonCourseId != null) {
      map['marathon_course_id'] = Variable<String>(marathonCourseId);
    }
    if (!nullToAbsent || gpsVerified != null) {
      map['gps_verified'] = Variable<bool>(gpsVerified);
    }
    {
      map['source'] = Variable<int>($RunsTable.$convertersource.toSql(source));
    }
    if (!nullToAbsent || route != null) {
      map['route'] = Variable<String>(route);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  RunsCompanion toCompanion(bool nullToAbsent) {
    return RunsCompanion(
      id: Value(id),
      date: Value(date),
      day: Value(day),
      km: Value(km),
      pace: Value(pace),
      dur: Value(dur),
      kcal: Value(kcal),
      type: Value(type),
      year: Value(year),
      month: Value(month),
      coverImageType: Value(coverImageType),
      coverImageUrl: coverImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImageUrl),
      marathonChallengeId: marathonChallengeId == null && nullToAbsent
          ? const Value.absent()
          : Value(marathonChallengeId),
      marathonCourseId: marathonCourseId == null && nullToAbsent
          ? const Value.absent()
          : Value(marathonCourseId),
      gpsVerified: gpsVerified == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsVerified),
      source: Value(source),
      route: route == null && nullToAbsent
          ? const Value.absent()
          : Value(route),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory RunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunRow(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      day: serializer.fromJson<String>(json['day']),
      km: serializer.fromJson<double>(json['km']),
      pace: serializer.fromJson<String>(json['pace']),
      dur: serializer.fromJson<String>(json['dur']),
      kcal: serializer.fromJson<int>(json['kcal']),
      type: $RunsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
      coverImageType: $RunsTable.$convertercoverImageType.fromJson(
        serializer.fromJson<int>(json['coverImageType']),
      ),
      coverImageUrl: serializer.fromJson<String?>(json['coverImageUrl']),
      marathonChallengeId: serializer.fromJson<String?>(
        json['marathonChallengeId'],
      ),
      marathonCourseId: serializer.fromJson<String?>(json['marathonCourseId']),
      gpsVerified: serializer.fromJson<bool?>(json['gpsVerified']),
      source: $RunsTable.$convertersource.fromJson(
        serializer.fromJson<int>(json['source']),
      ),
      route: serializer.fromJson<String?>(json['route']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<String>(date),
      'day': serializer.toJson<String>(day),
      'km': serializer.toJson<double>(km),
      'pace': serializer.toJson<String>(pace),
      'dur': serializer.toJson<String>(dur),
      'kcal': serializer.toJson<int>(kcal),
      'type': serializer.toJson<int>($RunsTable.$convertertype.toJson(type)),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
      'coverImageType': serializer.toJson<int>(
        $RunsTable.$convertercoverImageType.toJson(coverImageType),
      ),
      'coverImageUrl': serializer.toJson<String?>(coverImageUrl),
      'marathonChallengeId': serializer.toJson<String?>(marathonChallengeId),
      'marathonCourseId': serializer.toJson<String?>(marathonCourseId),
      'gpsVerified': serializer.toJson<bool?>(gpsVerified),
      'source': serializer.toJson<int>(
        $RunsTable.$convertersource.toJson(source),
      ),
      'route': serializer.toJson<String?>(route),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  RunRow copyWith({
    String? id,
    String? date,
    String? day,
    double? km,
    String? pace,
    String? dur,
    int? kcal,
    RecordType? type,
    int? year,
    int? month,
    CoverImageType? coverImageType,
    Value<String?> coverImageUrl = const Value.absent(),
    Value<String?> marathonChallengeId = const Value.absent(),
    Value<String?> marathonCourseId = const Value.absent(),
    Value<bool?> gpsVerified = const Value.absent(),
    RunSource? source,
    Value<String?> route = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => RunRow(
    id: id ?? this.id,
    date: date ?? this.date,
    day: day ?? this.day,
    km: km ?? this.km,
    pace: pace ?? this.pace,
    dur: dur ?? this.dur,
    kcal: kcal ?? this.kcal,
    type: type ?? this.type,
    year: year ?? this.year,
    month: month ?? this.month,
    coverImageType: coverImageType ?? this.coverImageType,
    coverImageUrl: coverImageUrl.present
        ? coverImageUrl.value
        : this.coverImageUrl,
    marathonChallengeId: marathonChallengeId.present
        ? marathonChallengeId.value
        : this.marathonChallengeId,
    marathonCourseId: marathonCourseId.present
        ? marathonCourseId.value
        : this.marathonCourseId,
    gpsVerified: gpsVerified.present ? gpsVerified.value : this.gpsVerified,
    source: source ?? this.source,
    route: route.present ? route.value : this.route,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  RunRow copyWithCompanion(RunsCompanion data) {
    return RunRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      day: data.day.present ? data.day.value : this.day,
      km: data.km.present ? data.km.value : this.km,
      pace: data.pace.present ? data.pace.value : this.pace,
      dur: data.dur.present ? data.dur.value : this.dur,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      type: data.type.present ? data.type.value : this.type,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      coverImageType: data.coverImageType.present
          ? data.coverImageType.value
          : this.coverImageType,
      coverImageUrl: data.coverImageUrl.present
          ? data.coverImageUrl.value
          : this.coverImageUrl,
      marathonChallengeId: data.marathonChallengeId.present
          ? data.marathonChallengeId.value
          : this.marathonChallengeId,
      marathonCourseId: data.marathonCourseId.present
          ? data.marathonCourseId.value
          : this.marathonCourseId,
      gpsVerified: data.gpsVerified.present
          ? data.gpsVerified.value
          : this.gpsVerified,
      source: data.source.present ? data.source.value : this.source,
      route: data.route.present ? data.route.value : this.route,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('day: $day, ')
          ..write('km: $km, ')
          ..write('pace: $pace, ')
          ..write('dur: $dur, ')
          ..write('kcal: $kcal, ')
          ..write('type: $type, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('coverImageType: $coverImageType, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('marathonChallengeId: $marathonChallengeId, ')
          ..write('marathonCourseId: $marathonCourseId, ')
          ..write('gpsVerified: $gpsVerified, ')
          ..write('source: $source, ')
          ..write('route: $route, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    day,
    km,
    pace,
    dur,
    kcal,
    type,
    year,
    month,
    coverImageType,
    coverImageUrl,
    marathonChallengeId,
    marathonCourseId,
    gpsVerified,
    source,
    route,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.day == this.day &&
          other.km == this.km &&
          other.pace == this.pace &&
          other.dur == this.dur &&
          other.kcal == this.kcal &&
          other.type == this.type &&
          other.year == this.year &&
          other.month == this.month &&
          other.coverImageType == this.coverImageType &&
          other.coverImageUrl == this.coverImageUrl &&
          other.marathonChallengeId == this.marathonChallengeId &&
          other.marathonCourseId == this.marathonCourseId &&
          other.gpsVerified == this.gpsVerified &&
          other.source == this.source &&
          other.route == this.route &&
          other.syncedAt == this.syncedAt);
}

class RunsCompanion extends UpdateCompanion<RunRow> {
  final Value<String> id;
  final Value<String> date;
  final Value<String> day;
  final Value<double> km;
  final Value<String> pace;
  final Value<String> dur;
  final Value<int> kcal;
  final Value<RecordType> type;
  final Value<int> year;
  final Value<int> month;
  final Value<CoverImageType> coverImageType;
  final Value<String?> coverImageUrl;
  final Value<String?> marathonChallengeId;
  final Value<String?> marathonCourseId;
  final Value<bool?> gpsVerified;
  final Value<RunSource> source;
  final Value<String?> route;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const RunsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.day = const Value.absent(),
    this.km = const Value.absent(),
    this.pace = const Value.absent(),
    this.dur = const Value.absent(),
    this.kcal = const Value.absent(),
    this.type = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.coverImageType = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.marathonChallengeId = const Value.absent(),
    this.marathonCourseId = const Value.absent(),
    this.gpsVerified = const Value.absent(),
    this.source = const Value.absent(),
    this.route = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunsCompanion.insert({
    required String id,
    required String date,
    required String day,
    required double km,
    required String pace,
    required String dur,
    required int kcal,
    required RecordType type,
    required int year,
    required int month,
    required CoverImageType coverImageType,
    this.coverImageUrl = const Value.absent(),
    this.marathonChallengeId = const Value.absent(),
    this.marathonCourseId = const Value.absent(),
    this.gpsVerified = const Value.absent(),
    required RunSource source,
    this.route = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       day = Value(day),
       km = Value(km),
       pace = Value(pace),
       dur = Value(dur),
       kcal = Value(kcal),
       type = Value(type),
       year = Value(year),
       month = Value(month),
       coverImageType = Value(coverImageType),
       source = Value(source);
  static Insertable<RunRow> custom({
    Expression<String>? id,
    Expression<String>? date,
    Expression<String>? day,
    Expression<double>? km,
    Expression<String>? pace,
    Expression<String>? dur,
    Expression<int>? kcal,
    Expression<int>? type,
    Expression<int>? year,
    Expression<int>? month,
    Expression<int>? coverImageType,
    Expression<String>? coverImageUrl,
    Expression<String>? marathonChallengeId,
    Expression<String>? marathonCourseId,
    Expression<bool>? gpsVerified,
    Expression<int>? source,
    Expression<String>? route,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (day != null) 'day': day,
      if (km != null) 'km': km,
      if (pace != null) 'pace': pace,
      if (dur != null) 'dur': dur,
      if (kcal != null) 'kcal': kcal,
      if (type != null) 'type': type,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (coverImageType != null) 'cover_image_type': coverImageType,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (marathonChallengeId != null)
        'marathon_challenge_id': marathonChallengeId,
      if (marathonCourseId != null) 'marathon_course_id': marathonCourseId,
      if (gpsVerified != null) 'gps_verified': gpsVerified,
      if (source != null) 'source': source,
      if (route != null) 'route': route,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunsCompanion copyWith({
    Value<String>? id,
    Value<String>? date,
    Value<String>? day,
    Value<double>? km,
    Value<String>? pace,
    Value<String>? dur,
    Value<int>? kcal,
    Value<RecordType>? type,
    Value<int>? year,
    Value<int>? month,
    Value<CoverImageType>? coverImageType,
    Value<String?>? coverImageUrl,
    Value<String?>? marathonChallengeId,
    Value<String?>? marathonCourseId,
    Value<bool?>? gpsVerified,
    Value<RunSource>? source,
    Value<String?>? route,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return RunsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      day: day ?? this.day,
      km: km ?? this.km,
      pace: pace ?? this.pace,
      dur: dur ?? this.dur,
      kcal: kcal ?? this.kcal,
      type: type ?? this.type,
      year: year ?? this.year,
      month: month ?? this.month,
      coverImageType: coverImageType ?? this.coverImageType,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      marathonChallengeId: marathonChallengeId ?? this.marathonChallengeId,
      marathonCourseId: marathonCourseId ?? this.marathonCourseId,
      gpsVerified: gpsVerified ?? this.gpsVerified,
      source: source ?? this.source,
      route: route ?? this.route,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (km.present) {
      map['km'] = Variable<double>(km.value);
    }
    if (pace.present) {
      map['pace'] = Variable<String>(pace.value);
    }
    if (dur.present) {
      map['dur'] = Variable<String>(dur.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<int>(kcal.value);
    }
    if (type.present) {
      map['type'] = Variable<int>($RunsTable.$convertertype.toSql(type.value));
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (coverImageType.present) {
      map['cover_image_type'] = Variable<int>(
        $RunsTable.$convertercoverImageType.toSql(coverImageType.value),
      );
    }
    if (coverImageUrl.present) {
      map['cover_image_url'] = Variable<String>(coverImageUrl.value);
    }
    if (marathonChallengeId.present) {
      map['marathon_challenge_id'] = Variable<String>(
        marathonChallengeId.value,
      );
    }
    if (marathonCourseId.present) {
      map['marathon_course_id'] = Variable<String>(marathonCourseId.value);
    }
    if (gpsVerified.present) {
      map['gps_verified'] = Variable<bool>(gpsVerified.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(
        $RunsTable.$convertersource.toSql(source.value),
      );
    }
    if (route.present) {
      map['route'] = Variable<String>(route.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('day: $day, ')
          ..write('km: $km, ')
          ..write('pace: $pace, ')
          ..write('dur: $dur, ')
          ..write('kcal: $kcal, ')
          ..write('type: $type, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('coverImageType: $coverImageType, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('marathonChallengeId: $marathonChallengeId, ')
          ..write('marathonCourseId: $marathonCourseId, ')
          ..write('gpsVerified: $gpsVerified, ')
          ..write('source: $source, ')
          ..write('route: $route, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RunsTable runs = $RunsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [runs];
}

typedef $$RunsTableCreateCompanionBuilder =
    RunsCompanion Function({
      required String id,
      required String date,
      required String day,
      required double km,
      required String pace,
      required String dur,
      required int kcal,
      required RecordType type,
      required int year,
      required int month,
      required CoverImageType coverImageType,
      Value<String?> coverImageUrl,
      Value<String?> marathonChallengeId,
      Value<String?> marathonCourseId,
      Value<bool?> gpsVerified,
      required RunSource source,
      Value<String?> route,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$RunsTableUpdateCompanionBuilder =
    RunsCompanion Function({
      Value<String> id,
      Value<String> date,
      Value<String> day,
      Value<double> km,
      Value<String> pace,
      Value<String> dur,
      Value<int> kcal,
      Value<RecordType> type,
      Value<int> year,
      Value<int> month,
      Value<CoverImageType> coverImageType,
      Value<String?> coverImageUrl,
      Value<String?> marathonChallengeId,
      Value<String?> marathonCourseId,
      Value<bool?> gpsVerified,
      Value<RunSource> source,
      Value<String?> route,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$RunsTableFilterComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get km => $composableBuilder(
    column: $table.km,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pace => $composableBuilder(
    column: $table.pace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dur => $composableBuilder(
    column: $table.dur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RecordType, RecordType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CoverImageType, CoverImageType, int>
  get coverImageType => $composableBuilder(
    column: $table.coverImageType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marathonChallengeId => $composableBuilder(
    column: $table.marathonChallengeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marathonCourseId => $composableBuilder(
    column: $table.marathonCourseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get gpsVerified => $composableBuilder(
    column: $table.gpsVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RunSource, RunSource, int> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RunsTableOrderingComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get km => $composableBuilder(
    column: $table.km,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pace => $composableBuilder(
    column: $table.pace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dur => $composableBuilder(
    column: $table.dur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coverImageType => $composableBuilder(
    column: $table.coverImageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marathonChallengeId => $composableBuilder(
    column: $table.marathonChallengeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marathonCourseId => $composableBuilder(
    column: $table.marathonCourseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get gpsVerified => $composableBuilder(
    column: $table.gpsVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<double> get km =>
      $composableBuilder(column: $table.km, builder: (column) => column);

  GeneratedColumn<String> get pace =>
      $composableBuilder(column: $table.pace, builder: (column) => column);

  GeneratedColumn<String> get dur =>
      $composableBuilder(column: $table.dur, builder: (column) => column);

  GeneratedColumn<int> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecordType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CoverImageType, int> get coverImageType =>
      $composableBuilder(
        column: $table.coverImageType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get marathonChallengeId => $composableBuilder(
    column: $table.marathonChallengeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get marathonCourseId => $composableBuilder(
    column: $table.marathonCourseId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get gpsVerified => $composableBuilder(
    column: $table.gpsVerified,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RunSource, int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get route =>
      $composableBuilder(column: $table.route, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$RunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunsTable,
          RunRow,
          $$RunsTableFilterComposer,
          $$RunsTableOrderingComposer,
          $$RunsTableAnnotationComposer,
          $$RunsTableCreateCompanionBuilder,
          $$RunsTableUpdateCompanionBuilder,
          (RunRow, BaseReferences<_$AppDatabase, $RunsTable, RunRow>),
          RunRow,
          PrefetchHooks Function()
        > {
  $$RunsTableTableManager(_$AppDatabase db, $RunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<double> km = const Value.absent(),
                Value<String> pace = const Value.absent(),
                Value<String> dur = const Value.absent(),
                Value<int> kcal = const Value.absent(),
                Value<RecordType> type = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<CoverImageType> coverImageType = const Value.absent(),
                Value<String?> coverImageUrl = const Value.absent(),
                Value<String?> marathonChallengeId = const Value.absent(),
                Value<String?> marathonCourseId = const Value.absent(),
                Value<bool?> gpsVerified = const Value.absent(),
                Value<RunSource> source = const Value.absent(),
                Value<String?> route = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion(
                id: id,
                date: date,
                day: day,
                km: km,
                pace: pace,
                dur: dur,
                kcal: kcal,
                type: type,
                year: year,
                month: month,
                coverImageType: coverImageType,
                coverImageUrl: coverImageUrl,
                marathonChallengeId: marathonChallengeId,
                marathonCourseId: marathonCourseId,
                gpsVerified: gpsVerified,
                source: source,
                route: route,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String date,
                required String day,
                required double km,
                required String pace,
                required String dur,
                required int kcal,
                required RecordType type,
                required int year,
                required int month,
                required CoverImageType coverImageType,
                Value<String?> coverImageUrl = const Value.absent(),
                Value<String?> marathonChallengeId = const Value.absent(),
                Value<String?> marathonCourseId = const Value.absent(),
                Value<bool?> gpsVerified = const Value.absent(),
                required RunSource source,
                Value<String?> route = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion.insert(
                id: id,
                date: date,
                day: day,
                km: km,
                pace: pace,
                dur: dur,
                kcal: kcal,
                type: type,
                year: year,
                month: month,
                coverImageType: coverImageType,
                coverImageUrl: coverImageUrl,
                marathonChallengeId: marathonChallengeId,
                marathonCourseId: marathonCourseId,
                gpsVerified: gpsVerified,
                source: source,
                route: route,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunsTable,
      RunRow,
      $$RunsTableFilterComposer,
      $$RunsTableOrderingComposer,
      $$RunsTableAnnotationComposer,
      $$RunsTableCreateCompanionBuilder,
      $$RunsTableUpdateCompanionBuilder,
      (RunRow, BaseReferences<_$AppDatabase, $RunsTable, RunRow>),
      RunRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RunsTableTableManager get runs => $$RunsTableTableManager(_db, _db.runs);
}
