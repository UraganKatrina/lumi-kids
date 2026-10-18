import '../../progress/data/progress_database.dart';
import '../domain/app_settings.dart';

class DriftAppSettingsRepository implements AppSettingsRepository {
  DriftAppSettingsRepository(this._db);

  static const languageKey = 'language';

  final ProgressDatabase _db;

  @override
  Future<String?> language() async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(languageKey))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> setLanguage(String language) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(key: languageKey, value: language),
      );
}
