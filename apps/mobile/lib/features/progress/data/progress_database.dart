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

@DriftDatabase(tables: [Attempts])
class ProgressDatabase extends _$ProgressDatabase {
  ProgressDatabase(super.executor);

  /// База в памяти устройства (SQLite-файл в каталоге приложения).
  ProgressDatabase.onDevice() : super(driftDatabase(name: 'lumi_progress'));

  @override
  int get schemaVersion => 1;
}
