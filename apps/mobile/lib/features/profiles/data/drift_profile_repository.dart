import 'package:drift/drift.dart';

import '../../progress/data/progress_database.dart';
import '../domain/child_profile.dart';

class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const activeChildKey = 'active_child';

  final ProgressDatabase _db;
  final DateTime Function() _clock;

  @override
  Future<List<ChildProfile>> loadAll() async {
    final rows = await (_db.select(
      _db.children,
    )..orderBy([(c) => OrderingTerm.asc(c.createdAt)])).get();
    return [
      for (final row in rows)
        ChildProfile(
          id: row.id,
          name: row.name,
          birthYear: row.birthYear,
          birthMonth: row.birthMonth,
          avatar: ChildAvatar.fromCode(row.avatar),
        ),
    ];
  }

  @override
  Future<void> save(ChildProfile profile) => _db.transaction(() async {
    final existing = await (_db.select(
      _db.children,
    )..where((c) => c.id.equals(profile.id))).getSingleOrNull();
    if (existing != null) {
      await (_db.update(
        _db.children,
      )..where((c) => c.id.equals(profile.id))).write(
        ChildrenCompanion(
          name: Value(profile.name),
          birthYear: Value(profile.birthYear),
          birthMonth: Value(profile.birthMonth),
          avatar: Value(profile.avatar.code),
        ),
      );
      return;
    }
    final isFirst = (await _db.select(_db.children).get()).isEmpty;
    await _db
        .into(_db.children)
        .insert(
          ChildrenCompanion.insert(
            id: profile.id,
            name: profile.name,
            birthYear: profile.birthYear,
            birthMonth: profile.birthMonth,
            avatar: profile.avatar.code,
            createdAt: _clock(),
          ),
        );
    if (isFirst) {
      // Прогресс из версии без профилей не теряется: он достаётся первому ребёнку.
      await (_db.update(_db.attempts)..where((a) => a.childId.isNull())).write(
        AttemptsCompanion(childId: Value(profile.id)),
      );
    }
  });

  @override
  Future<void> delete(String childId) => _db.transaction(() async {
    await (_db.delete(
      _db.attempts,
    )..where((a) => a.childId.equals(childId))).go();
    await (_db.delete(_db.children)..where((c) => c.id.equals(childId))).go();
    if (await activeChildId() == childId) {
      await (_db.delete(
        _db.settings,
      )..where((s) => s.key.equals(activeChildKey))).go();
    }
  });

  @override
  Future<void> deleteEverything() => _db.transaction(() async {
    await _db.delete(_db.attempts).go();
    await _db.delete(_db.children).go();
    await _db.delete(_db.settings).go();
  });

  @override
  Future<String?> activeChildId() async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(activeChildKey))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> setActiveChild(String childId) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(key: activeChildKey, value: childId),
      );
}
