import 'dart:convert';

import '../../progress/data/progress_database.dart';
import '../domain/entitlement.dart';

class DriftEntitlementRepository implements EntitlementRepository {
  DriftEntitlementRepository(this._db);

  static const key = 'entitlement';

  final ProgressDatabase _db;

  @override
  Future<Entitlement?> load() async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    if (row == null) return null;
    try {
      return Entitlement.fromJson(jsonDecode(row.value));
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> save(Entitlement entitlement) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(
          key: key,
          value: jsonEncode(entitlement.toJson()),
        ),
      );

  @override
  Future<void> clear() =>
      (_db.delete(_db.settings)..where((s) => s.key.equals(key))).go();
}
