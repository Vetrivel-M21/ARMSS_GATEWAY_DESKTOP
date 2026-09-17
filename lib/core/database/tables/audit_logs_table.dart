import 'package:drift/drift.dart';

import 'users_table.dart';

/// Net-new business audit trail (the old app had none). Written in the same
/// Drift transaction as any financial-state-changing write, so a failed
/// audit insert rolls back the whole write.
class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get action => text()();
  // Named `entityTable`, not `tableName` — the latter collides with Table's
  // own `tableName` override point (the SQL table name), causing an
  // invalid_override compile error.
  TextColumn get entityTable => text()();
  IntColumn get recordId => integer().nullable()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
