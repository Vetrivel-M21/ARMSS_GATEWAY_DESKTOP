import 'package:drift/drift.dart';

import 'departments_table.dart';
import 'users_table.dart';

/// Audit/recovery log of export passwords — deliberately plaintext, matching
/// the old app's `export_password_history` (this is intentional, not a bug:
/// the export password is meant to be recoverable by an admin).
@DataClassName('ExportPasswordHistoryData')
class ExportPasswordHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get exportType => text()();
  TextColumn get exportPassword => text()();
  DateTimeColumn get fromDate => dateTime()();
  DateTimeColumn get toDate => dateTime().nullable()();
  IntColumn get departmentId =>
      integer().nullable().references(Departments, #id)();
  DateTimeColumn get downloadedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
