import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'progress_database.g.dart';

/// Одна завершённая попытка выполнить задание.
class Attempts extends Table {
  /// UUID, созданный на устройстве: защищает от дублей при будущей синхронизации.
  TextColumn get id => text()();

  /// Пусто только у попыток, сохранённых до появления профилей (версия 0.2):
  /// их забирает себе первый созданный профиль.
  TextColumn get childId => text().nullable()();
  TextColumn get taskId => text()();
  IntColumn get taskVersion => integer()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime()();
  IntColumn get mistakes => integer()();
  IntColumn get stars => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Профиль ребёнка: только прозвище, год и месяц рождения, встроенный аватар.
@DataClassName('ChildRow')
class Children extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get birthYear => integer()();
  IntColumn get birthMonth => integer()();
  TextColumn get avatar => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Настройки на устройстве: ключ — значение.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Attempts, Children, Settings])
class ProgressDatabase extends _$ProgressDatabase {
  ProgressDatabase(super.executor);

  /// SQLite-файл в каталоге приложения. Имя файла не меняем: иначе пропадёт
  /// прогресс, сохранённый прежними версиями.
  ProgressDatabase.onDevice() : super(driftDatabase(name: 'lumi_progress'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v1 → v2: добавлены настройки.
      if (from < 2) await m.createTable(settings);
      // v2 → v3: профили детей, у попытки появился ребёнок.
      if (from < 3) {
        await m.createTable(children);
        await m.addColumn(attempts, attempts.childId);
      }
    },
  );
}
