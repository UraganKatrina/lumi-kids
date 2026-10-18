import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/features/progress/data/progress_database.dart';
import 'package:lumi_kids/features/settings/data/drift_app_settings_repository.dart';

void main() {
  test('язык сохраняется и меняется', () async {
    final db = ProgressDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final settings = DriftAppSettingsRepository(db);
    expect(await settings.language(), isNull);
    await settings.setLanguage('uz');
    await settings.setLanguage('en');
    expect(await settings.language(), 'en');
  });
}
