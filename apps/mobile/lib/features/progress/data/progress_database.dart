import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'progress_database.g.dart';

/// Одна завершённая попытка выполнить задание.
class Attempts extends Table {
  /// UUID, созданный на устройстве: защищает от дублей при будущей синхронизации.
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  IntColumn get taskVersion => integer()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime()();
  IntColumn get mistakes => integer()();
  IntColumn get stars => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Настройки на устройстве: ключ — значение. Профили детей появятся на этапе 5.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Attempts, Settings])
class ProgressDatabase extends _$ProgressDatabase {
  ProgressDatabase(super.executor);

  /// SQLite-файл в каталоге приложения.
  ProgressDatabase.onDevice() : super(driftDatabase(name: 'lumi_progress'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v1 → v2: добавлены настройки (выбранная возрастная программа).
      if (from < 2) await m.createTable(settings);
    },
  );
}
