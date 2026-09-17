import 'package:drift/drift.dart';

import 'roles_table.dart';

/// Password is stored in plaintext, matching the old app's behavior exactly
/// (login compare, admin reset, and plaintext display in user management all
/// carry over unchanged — this was an explicit decision, not an oversight).
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().unique()();
  TextColumn get password => text()();
  TextColumn get fullName => text()();
  IntColumn get roleId => integer().references(Roles, #id)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
