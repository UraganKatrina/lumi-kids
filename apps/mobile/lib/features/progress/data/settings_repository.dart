import 'progress_database.dart';

/// Простые настройки устройства, хранятся в той же базе, что и прогресс.
class SettingsRepository {
  SettingsRepository(this._db);

  static const ageProgramKey = 'age_program';

  final ProgressDatabase _db;

  Future<String?> read(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> write(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
}
