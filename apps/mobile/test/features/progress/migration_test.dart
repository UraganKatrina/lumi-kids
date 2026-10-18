import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/features/progress/data/drift_progress_repository.dart';
import 'package:lumi_kids/features/progress/data/progress_database.dart';
import 'package:lumi_kids/features/progress/data/settings_repository.dart';

void main() {
  test(
    'обновление базы с версии 1 сохраняет прогресс и добавляет настройки',
    () async {
      // База в том виде, в каком её создавала версия приложения 0.1.0.
      final db = ProgressDatabase(
        NativeDatabase.memory(
          setup: (raw) {
            raw.execute('''
            CREATE TABLE attempts (
              id TEXT NOT NULL PRIMARY KEY,
              task_id TEXT NOT NULL,
              task_version INTEGER NOT NULL,
              started_at INTEGER NOT NULL,
              finished_at INTEGER NOT NULL,
              mistakes INTEGER NOT NULL,
              stars INTEGER NOT NULL
            );
          ''');
            raw.execute(
              "INSERT INTO attempts VALUES ('a1', 'math.count.apples.001', 1, 0, 60, 0, 3);",
            );
            raw.userVersion = 1;
          },
        ),
      );
      addTearDown(db.close);

      expect(await DriftProgressRepository(db).bestStarsByTask(), {
        'math.count.apples.001': 3,
      });

      final settings = SettingsRepository(db);
      await settings.write(SettingsRepository.ageProgramKey, 'preschool');
      await settings.write(SettingsRepository.ageProgramKey, 'school_prep');
      expect(
        await settings.read(SettingsRepository.ageProgramKey),
        'school_prep',
      );
    },
  );
}
