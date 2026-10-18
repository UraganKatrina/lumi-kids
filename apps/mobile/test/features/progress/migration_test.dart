import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/features/profiles/data/drift_profile_repository.dart';
import 'package:lumi_kids/features/profiles/domain/child_profile.dart';
import 'package:lumi_kids/features/progress/data/drift_progress_repository.dart';
import 'package:lumi_kids/features/progress/data/progress_database.dart';

const _attemptsV1 = '''
  CREATE TABLE attempts (
    id TEXT NOT NULL PRIMARY KEY,
    task_id TEXT NOT NULL,
    task_version INTEGER NOT NULL,
    started_at INTEGER NOT NULL,
    finished_at INTEGER NOT NULL,
    mistakes INTEGER NOT NULL,
    stars INTEGER NOT NULL
  );
''';

const _kid = ChildProfile(
  id: 'kid',
  name: 'Маша',
  birthYear: 2022,
  birthMonth: 5,
  avatar: ChildAvatar.bee,
);

ProgressDatabase oldDatabase({required int version}) => ProgressDatabase(
  NativeDatabase.memory(
    setup: (raw) {
      raw.execute(_attemptsV1);
      raw.execute(
        "INSERT INTO attempts VALUES ('a1', 'math.count.apples.001', 1, 0, 60, 0, 3);",
      );
      if (version >= 2) {
        raw.execute(
          'CREATE TABLE settings (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL);',
        );
        raw.execute(
          "INSERT INTO settings VALUES ('age_program', 'preschool');",
        );
      }
      raw.userVersion = version;
    },
  ),
);

void main() {
  for (final version in [1, 2]) {
    test(
      'обновление с версии $version: прогресс достаётся первому профилю',
      () async {
        final db = oldDatabase(version: version);
        addTearDown(db.close);

        final legacy = await db.select(db.attempts).getSingle();
        expect(legacy.childId, isNull);

        await DriftProfileRepository(db).save(_kid);

        expect(await DriftProgressRepository(db).bestStarsByTask('kid'), {
          'math.count.apples.001': 3,
        });
        final settings = await db.select(db.settings).get();
        expect(settings.length, version >= 2 ? 1 : 0);
      },
    );
  }

  test('новая база создаётся сразу в версии 3', () async {
    final db = ProgressDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 3);
    final version = await db
        .customSelect('PRAGMA user_version')
        .map((r) => r.read<int>('user_version'))
        .getSingle();
    expect(version, 3);
  });
}
