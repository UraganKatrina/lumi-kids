// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_database.dart';

// ignore_for_file: type=lint
class $AttemptsTable extends Attempts with TableInfo<$AttemptsTable, Attempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskVersionMeta = const VerificationMeta(
    'taskVersion',
  );
  @override
  late final GeneratedColumn<int> taskVersion = GeneratedColumn<int>(
    'task_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mistakesMeta = const VerificationMeta(
    'mistakes',
  );
  @override
  late final GeneratedColumn<int> mistakes = GeneratedColumn<int>(
    'mistakes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starsMeta = const VerificationMeta('stars');
  @override
  late final GeneratedColumn<int> stars = GeneratedColumn<int>(
    'stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    taskId,
    taskVersion,
    startedAt,
    finishedAt,
    mistakes,
    stars,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('task_version')) {
      context.handle(
        _taskVersionMeta,
        taskVersion.isAcceptableOrUnknown(
          data['task_version']!,
          _taskVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_taskVersionMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_finishedAtMeta);
    }
    if (data.containsKey('mistakes')) {
      context.handle(
        _mistakesMeta,
        mistakes.isAcceptableOrUnknown(data['mistakes']!, _mistakesMeta),
      );
    } else if (isInserting) {
      context.missing(_mistakesMeta);
    }
    if (data.containsKey('stars')) {
      context.handle(
        _starsMeta,
        stars.isAcceptableOrUnknown(data['stars']!, _starsMeta),
      );
    } else if (isInserting) {
      context.missing(_starsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      ),
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      taskVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_version'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      )!,
      mistakes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mistakes'],
      )!,
      stars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stars'],
      )!,
    );
  }

  @override
  $AttemptsTable createAlias(String alias) {
    return $AttemptsTable(attachedDatabase, alias);
  }
}

class Attempt extends DataClass implements Insertable<Attempt> {
  /// UUID, созданный на устройстве: защищает от дублей при будущей синхронизации.
  final String id;

  /// Пусто только у попыток, сохранённых до появления профилей (версия 0.2):
  /// их забирает себе первый созданный профиль.
  final String? childId;
  final String taskId;
  final int taskVersion;
  final DateTime startedAt;
  final DateTime finishedAt;
  final int mistakes;
  final int stars;
  const Attempt({
    required this.id,
    this.childId,
    required this.taskId,
    required this.taskVersion,
    required this.startedAt,
    required this.finishedAt,
    required this.mistakes,
    required this.stars,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || childId != null) {
      map['child_id'] = Variable<String>(childId);
    }
    map['task_id'] = Variable<String>(taskId);
    map['task_version'] = Variable<int>(taskVersion);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['finished_at'] = Variable<DateTime>(finishedAt);
    map['mistakes'] = Variable<int>(mistakes);
    map['stars'] = Variable<int>(stars);
    return map;
  }

  AttemptsCompanion toCompanion(bool nullToAbsent) {
    return AttemptsCompanion(
      id: Value(id),
      childId: childId == null && nullToAbsent
          ? const Value.absent()
          : Value(childId),
      taskId: Value(taskId),
      taskVersion: Value(taskVersion),
      startedAt: Value(startedAt),
      finishedAt: Value(finishedAt),
      mistakes: Value(mistakes),
      stars: Value(stars),
    );
  }

  factory Attempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attempt(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String?>(json['childId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      taskVersion: serializer.fromJson<int>(json['taskVersion']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime>(json['finishedAt']),
      mistakes: serializer.fromJson<int>(json['mistakes']),
      stars: serializer.fromJson<int>(json['stars']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String?>(childId),
      'taskId': serializer.toJson<String>(taskId),
      'taskVersion': serializer.toJson<int>(taskVersion),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime>(finishedAt),
      'mistakes': serializer.toJson<int>(mistakes),
      'stars': serializer.toJson<int>(stars),
    };
  }

  Attempt copyWith({
    String? id,
    Value<String?> childId = const Value.absent(),
    String? taskId,
    int? taskVersion,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? mistakes,
    int? stars,
  }) => Attempt(
    id: id ?? this.id,
    childId: childId.present ? childId.value : this.childId,
    taskId: taskId ?? this.taskId,
    taskVersion: taskVersion ?? this.taskVersion,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt ?? this.finishedAt,
    mistakes: mistakes ?? this.mistakes,
    stars: stars ?? this.stars,
  );
  Attempt copyWithCompanion(AttemptsCompanion data) {
    return Attempt(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      taskVersion: data.taskVersion.present
          ? data.taskVersion.value
          : this.taskVersion,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      mistakes: data.mistakes.present ? data.mistakes.value : this.mistakes,
      stars: data.stars.present ? data.stars.value : this.stars,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attempt(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('taskId: $taskId, ')
          ..write('taskVersion: $taskVersion, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('mistakes: $mistakes, ')
          ..write('stars: $stars')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    taskId,
    taskVersion,
    startedAt,
    finishedAt,
    mistakes,
    stars,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attempt &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.taskId == this.taskId &&
          other.taskVersion == this.taskVersion &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.mistakes == this.mistakes &&
          other.stars == this.stars);
}

class AttemptsCompanion extends UpdateCompanion<Attempt> {
  final Value<String> id;
  final Value<String?> childId;
  final Value<String> taskId;
  final Value<int> taskVersion;
  final Value<DateTime> startedAt;
  final Value<DateTime> finishedAt;
  final Value<int> mistakes;
  final Value<int> stars;
  final Value<int> rowid;
  const AttemptsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.taskVersion = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.mistakes = const Value.absent(),
    this.stars = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttemptsCompanion.insert({
    required String id,
    this.childId = const Value.absent(),
    required String taskId,
    required int taskVersion,
    required DateTime startedAt,
    required DateTime finishedAt,
    required int mistakes,
    required int stars,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       taskVersion = Value(taskVersion),
       startedAt = Value(startedAt),
       finishedAt = Value(finishedAt),
       mistakes = Value(mistakes),
       stars = Value(stars);
  static Insertable<Attempt> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<String>? taskId,
    Expression<int>? taskVersion,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? mistakes,
    Expression<int>? stars,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (taskId != null) 'task_id': taskId,
      if (taskVersion != null) 'task_version': taskVersion,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (mistakes != null) 'mistakes': mistakes,
      if (stars != null) 'stars': stars,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttemptsCompanion copyWith({
    Value<String>? id,
    Value<String?>? childId,
    Value<String>? taskId,
    Value<int>? taskVersion,
    Value<DateTime>? startedAt,
    Value<DateTime>? finishedAt,
    Value<int>? mistakes,
    Value<int>? stars,
    Value<int>? rowid,
  }) {
    return AttemptsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      taskId: taskId ?? this.taskId,
      taskVersion: taskVersion ?? this.taskVersion,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      mistakes: mistakes ?? this.mistakes,
      stars: stars ?? this.stars,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (taskVersion.present) {
      map['task_version'] = Variable<int>(taskVersion.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (mistakes.present) {
      map['mistakes'] = Variable<int>(mistakes.value);
    }
    if (stars.present) {
      map['stars'] = Variable<int>(stars.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('taskId: $taskId, ')
          ..write('taskVersion: $taskVersion, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('mistakes: $mistakes, ')
          ..write('stars: $stars, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChildrenTable extends Children with TableInfo<$ChildrenTable, ChildRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildrenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _birthYearMeta = const VerificationMeta(
    'birthYear',
  );
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthMonthMeta = const VerificationMeta(
    'birthMonth',
  );
  @override
  late final GeneratedColumn<int> birthMonth = GeneratedColumn<int>(
    'birth_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    birthYear,
    birthMonth,
    avatar,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'children';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChildRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    } else if (isInserting) {
      context.missing(_birthYearMeta);
    }
    if (data.containsKey('birth_month')) {
      context.handle(
        _birthMonthMeta,
        birthMonth.isAcceptableOrUnknown(data['birth_month']!, _birthMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_birthMonthMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    } else if (isInserting) {
      context.missing(_avatarMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChildRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChildRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      )!,
      birthMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_month'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChildrenTable createAlias(String alias) {
    return $ChildrenTable(attachedDatabase, alias);
  }
}

class ChildRow extends DataClass implements Insertable<ChildRow> {
  final String id;
  final String name;
  final int birthYear;
  final int birthMonth;
  final String avatar;
  final DateTime createdAt;
  const ChildRow({
    required this.id,
    required this.name,
    required this.birthYear,
    required this.birthMonth,
    required this.avatar,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['birth_year'] = Variable<int>(birthYear);
    map['birth_month'] = Variable<int>(birthMonth);
    map['avatar'] = Variable<String>(avatar);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChildrenCompanion toCompanion(bool nullToAbsent) {
    return ChildrenCompanion(
      id: Value(id),
      name: Value(name),
      birthYear: Value(birthYear),
      birthMonth: Value(birthMonth),
      avatar: Value(avatar),
      createdAt: Value(createdAt),
    );
  }

  factory ChildRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChildRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      birthYear: serializer.fromJson<int>(json['birthYear']),
      birthMonth: serializer.fromJson<int>(json['birthMonth']),
      avatar: serializer.fromJson<String>(json['avatar']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'birthYear': serializer.toJson<int>(birthYear),
      'birthMonth': serializer.toJson<int>(birthMonth),
      'avatar': serializer.toJson<String>(avatar),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChildRow copyWith({
    String? id,
    String? name,
    int? birthYear,
    int? birthMonth,
    String? avatar,
    DateTime? createdAt,
  }) => ChildRow(
    id: id ?? this.id,
    name: name ?? this.name,
    birthYear: birthYear ?? this.birthYear,
    birthMonth: birthMonth ?? this.birthMonth,
    avatar: avatar ?? this.avatar,
    createdAt: createdAt ?? this.createdAt,
  );
  ChildRow copyWithCompanion(ChildrenCompanion data) {
    return ChildRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      birthMonth: data.birthMonth.present
          ? data.birthMonth.value
          : this.birthMonth,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChildRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthYear: $birthYear, ')
          ..write('birthMonth: $birthMonth, ')
          ..write('avatar: $avatar, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, birthYear, birthMonth, avatar, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChildRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthYear == this.birthYear &&
          other.birthMonth == this.birthMonth &&
          other.avatar == this.avatar &&
          other.createdAt == this.createdAt);
}

class ChildrenCompanion extends UpdateCompanion<ChildRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> birthYear;
  final Value<int> birthMonth;
  final Value<String> avatar;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ChildrenCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.birthMonth = const Value.absent(),
    this.avatar = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChildrenCompanion.insert({
    required String id,
    required String name,
    required int birthYear,
    required int birthMonth,
    required String avatar,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       birthYear = Value(birthYear),
       birthMonth = Value(birthMonth),
       avatar = Value(avatar),
       createdAt = Value(createdAt);
  static Insertable<ChildRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? birthYear,
    Expression<int>? birthMonth,
    Expression<String>? avatar,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthYear != null) 'birth_year': birthYear,
      if (birthMonth != null) 'birth_month': birthMonth,
      if (avatar != null) 'avatar': avatar,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChildrenCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? birthYear,
    Value<int>? birthMonth,
    Value<String>? avatar,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ChildrenCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthYear: birthYear ?? this.birthYear,
      birthMonth: birthMonth ?? this.birthMonth,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (birthMonth.present) {
      map['birth_month'] = Variable<int>(birthMonth.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildrenCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthYear: $birthYear, ')
          ..write('birthMonth: $birthMonth, ')
          ..write('avatar: $avatar, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
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

abstract class _$ProgressDatabase extends GeneratedDatabase {
  _$ProgressDatabase(QueryExecutor e) : super(e);
  $ProgressDatabaseManager get managers => $ProgressDatabaseManager(this);
  late final $AttemptsTable attempts = $AttemptsTable(this);
  late final $ChildrenTable children = $ChildrenTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    attempts,
    children,
    settings,
  ];
}

typedef $$AttemptsTableCreateCompanionBuilder = AttemptsCompanion Function({
  required String id,
  Value<String?> childId,
  required String taskId,
  required int taskVersion,
  required DateTime startedAt,
  required DateTime finishedAt,
  required int mistakes,
  required int stars,
  Value<int> rowid,
});
typedef $$AttemptsTableUpdateCompanionBuilder = AttemptsCompanion Function({
  Value<String> id,
  Value<String?> childId,
  Value<String> taskId,
  Value<int> taskVersion,
  Value<DateTime> startedAt,
  Value<DateTime> finishedAt,
  Value<int> mistakes,
  Value<int> stars,
  Value<int> rowid,
});

class $$AttemptsTableFilterComposer
    extends Composer<_$ProgressDatabase, $AttemptsTable> {
  $$AttemptsTableFilterComposer({
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

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskVersion => $composableBuilder(
    column: $table.taskVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mistakes => $composableBuilder(
    column: $table.mistakes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttemptsTableOrderingComposer
    extends Composer<_$ProgressDatabase, $AttemptsTable> {
  $$AttemptsTableOrderingComposer({
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

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskVersion => $composableBuilder(
    column: $table.taskVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mistakes => $composableBuilder(
    column: $table.mistakes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttemptsTableAnnotationComposer
    extends Composer<_$ProgressDatabase, $AttemptsTable> {
  $$AttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<int> get taskVersion => $composableBuilder(
    column: $table.taskVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mistakes =>
      $composableBuilder(column: $table.mistakes, builder: (column) => column);

  GeneratedColumn<int> get stars =>
      $composableBuilder(column: $table.stars, builder: (column) => column);
}

class $$AttemptsTableTableManager
    extends
        RootTableManager<
          _$ProgressDatabase,
          $AttemptsTable,
          Attempt,
          $$AttemptsTableFilterComposer,
          $$AttemptsTableOrderingComposer,
          $$AttemptsTableAnnotationComposer,
          $$AttemptsTableCreateCompanionBuilder,
          $$AttemptsTableUpdateCompanionBuilder,
          (
            Attempt,
            BaseReferences<_$ProgressDatabase, $AttemptsTable, Attempt>,
          ),
          Attempt,
          PrefetchHooks Function()
        > {
  $$AttemptsTableTableManager(_$ProgressDatabase db, $AttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> childId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<int> taskVersion = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> finishedAt = const Value.absent(),
                Value<int> mistakes = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttemptsCompanion(
                id: id,
                childId: childId,
                taskId: taskId,
                taskVersion: taskVersion,
                startedAt: startedAt,
                finishedAt: finishedAt,
                mistakes: mistakes,
                stars: stars,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> childId = const Value.absent(),
                required String taskId,
                required int taskVersion,
                required DateTime startedAt,
                required DateTime finishedAt,
                required int mistakes,
                required int stars,
                Value<int> rowid = const Value.absent(),
              }) => AttemptsCompanion.insert(
                id: id,
                childId: childId,
                taskId: taskId,
                taskVersion: taskVersion,
                startedAt: startedAt,
                finishedAt: finishedAt,
                mistakes: mistakes,
                stars: stars,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttemptsTable, Attempt>(table),
                  BaseReferences<_$ProgressDatabase, $AttemptsTable, Attempt>(
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

typedef $$AttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$ProgressDatabase,
      $AttemptsTable,
      Attempt,
      $$AttemptsTableFilterComposer,
      $$AttemptsTableOrderingComposer,
      $$AttemptsTableAnnotationComposer,
      $$AttemptsTableCreateCompanionBuilder,
      $$AttemptsTableUpdateCompanionBuilder,
      (Attempt, BaseReferences<_$ProgressDatabase, $AttemptsTable, Attempt>),
      Attempt,
      PrefetchHooks Function()
    >;
typedef $$ChildrenTableCreateCompanionBuilder = ChildrenCompanion Function({
  required String id,
  required String name,
  required int birthYear,
  required int birthMonth,
  required String avatar,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ChildrenTableUpdateCompanionBuilder = ChildrenCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> birthYear,
  Value<int> birthMonth,
  Value<String> avatar,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ChildrenTableFilterComposer
    extends Composer<_$ProgressDatabase, $ChildrenTable> {
  $$ChildrenTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthMonth => $composableBuilder(
    column: $table.birthMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChildrenTableOrderingComposer
    extends Composer<_$ProgressDatabase, $ChildrenTable> {
  $$ChildrenTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthMonth => $composableBuilder(
    column: $table.birthMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChildrenTableAnnotationComposer
    extends Composer<_$ProgressDatabase, $ChildrenTable> {
  $$ChildrenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<int> get birthMonth => $composableBuilder(
    column: $table.birthMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChildrenTableTableManager
    extends
        RootTableManager<
          _$ProgressDatabase,
          $ChildrenTable,
          ChildRow,
          $$ChildrenTableFilterComposer,
          $$ChildrenTableOrderingComposer,
          $$ChildrenTableAnnotationComposer,
          $$ChildrenTableCreateCompanionBuilder,
          $$ChildrenTableUpdateCompanionBuilder,
          (
            ChildRow,
            BaseReferences<_$ProgressDatabase, $ChildrenTable, ChildRow>,
          ),
          ChildRow,
          PrefetchHooks Function()
        > {
  $$ChildrenTableTableManager(_$ProgressDatabase db, $ChildrenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChildrenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChildrenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChildrenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> birthYear = const Value.absent(),
                Value<int> birthMonth = const Value.absent(),
                Value<String> avatar = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChildrenCompanion(
                id: id,
                name: name,
                birthYear: birthYear,
                birthMonth: birthMonth,
                avatar: avatar,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int birthYear,
                required int birthMonth,
                required String avatar,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ChildrenCompanion.insert(
                id: id,
                name: name,
                birthYear: birthYear,
                birthMonth: birthMonth,
                avatar: avatar,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChildrenTable, ChildRow>(table),
                  BaseReferences<_$ProgressDatabase, $ChildrenTable, ChildRow>(
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

typedef $$ChildrenTableProcessedTableManager =
    ProcessedTableManager<
      _$ProgressDatabase,
      $ChildrenTable,
      ChildRow,
      $$ChildrenTableFilterComposer,
      $$ChildrenTableOrderingComposer,
      $$ChildrenTableAnnotationComposer,
      $$ChildrenTableCreateCompanionBuilder,
      $$ChildrenTableUpdateCompanionBuilder,
      (ChildRow, BaseReferences<_$ProgressDatabase, $ChildrenTable, ChildRow>),
      ChildRow,
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
    extends Composer<_$ProgressDatabase, $SettingsTable> {
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
    extends Composer<_$ProgressDatabase, $SettingsTable> {
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
    extends Composer<_$ProgressDatabase, $SettingsTable> {
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
          _$ProgressDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            Setting,
            BaseReferences<_$ProgressDatabase, $SettingsTable, Setting>,
          ),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$ProgressDatabase db, $SettingsTable table)
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
                  BaseReferences<_$ProgressDatabase, $SettingsTable, Setting>(
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
      _$ProgressDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$ProgressDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $ProgressDatabaseManager {
  final _$ProgressDatabase _db;
  $ProgressDatabaseManager(this._db);
  $$AttemptsTableTableManager get attempts =>
      $$AttemptsTableTableManager(_db, _db.attempts);
  $$ChildrenTableTableManager get children =>
      $$ChildrenTableTableManager(_db, _db.children);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
