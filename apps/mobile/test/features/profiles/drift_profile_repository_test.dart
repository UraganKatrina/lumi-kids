import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/features/profiles/data/drift_profile_repository.dart';
import 'package:lumi_kids/features/profiles/domain/child_profile.dart';
import 'package:lumi_kids/features/progress/data/drift_progress_repository.dart';
import 'package:lumi_kids/features/progress/data/progress_database.dart';
import 'package:lumi_kids/features/progress/domain/progress.dart';

ChildProfile kid(String id, {String name = 'Маша'}) => ChildProfile(
  id: id,
  name: name,
  birthYear: 2022,
  birthMonth: 3,
  avatar: ChildAvatar.bird,
);

AttemptRecord attempt(String child) => AttemptRecord(
  childId: child,
  taskId: 't',
  taskVersion: 1,
  startedAt: DateTime(2026),
  finishedAt: DateTime(2026),
  mistakes: 0,
  stars: 3,
);

void main() {
  late ProgressDatabase db;
  late DriftProfileRepository profiles;
  late DriftProgressRepository progress;
  var tick = 0;

  setUp(() {
    db = ProgressDatabase(NativeDatabase.memory());
    profiles = DriftProfileRepository(
      db,
      clock: () => DateTime(2026, 10, 18).add(Duration(minutes: tick++)),
    );
    progress = DriftProgressRepository(db);
  });
  tearDown(() => db.close());

  test(
    'профили сохраняются в порядке создания, правка не меняет порядок',
    () async {
      await profiles.save(kid('a', name: 'Аня'));
      await profiles.save(kid('b', name: 'Боря'));
      await profiles.save(
        kid('a', name: 'Анюта').copyWith(avatar: ChildAvatar.star),
      );

      final all = await profiles.loadAll();
      expect(all.map((p) => p.name), ['Анюта', 'Боря']);
      expect(all.first.avatar, ChildAvatar.star);
      expect(all.first.birthMonth, 3);
    },
  );

  test('удаление профиля удаляет только его прогресс', () async {
    await profiles.save(kid('a'));
    await profiles.save(kid('b'));
    await profiles.setActiveChild('a');
    await progress.saveAttempt(attempt('a'));
    await progress.saveAttempt(attempt('b'));

    await profiles.delete('a');

    expect((await profiles.loadAll()).map((p) => p.id), ['b']);
    expect(await progress.history('a'), isEmpty);
    expect(await progress.history('b'), hasLength(1));
    expect(await profiles.activeChildId(), isNull);
  });

  test('«удалить всё» очищает профили, прогресс и настройки', () async {
    await profiles.save(kid('a'));
    await profiles.setActiveChild('a');
    await progress.saveAttempt(attempt('a'));

    await profiles.deleteEverything();

    expect(await profiles.loadAll(), isEmpty);
    expect(await db.select(db.attempts).get(), isEmpty);
    expect(await db.select(db.settings).get(), isEmpty);
  });

  test('второй профиль не забирает чужой прогресс', () async {
    await db
        .into(db.attempts)
        .insert(
          AttemptsCompanion.insert(
            id: 'legacy',
            taskId: 't',
            taskVersion: 1,
            startedAt: DateTime(2025),
            finishedAt: DateTime(2025),
            mistakes: 0,
            stars: 2,
          ),
        );
    await profiles.save(kid('first'));
    await profiles.save(kid('second'));

    expect(await progress.history('first'), hasLength(1));
    expect(await progress.history('second'), isEmpty);
  });
}
