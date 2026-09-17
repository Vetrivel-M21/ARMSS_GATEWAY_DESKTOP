import 'package:drift/drift.dart';

import 'departments_table.dart';
import 'users_table.dart';

/// Admin-entered "actual closing" figure per department+date, matched
/// (0.01 tolerance) against the computed total before a day_book may close.
/// `departmentId` is nullable to represent the old app's "all departments"
/// bucket (previously the ambiguous sentinel `department_id = 0`).
///
/// NOTE: SQLite treats NULL as distinct from NULL for UNIQUE-constraint
/// purposes, so `uniqueKeys` below does NOT prevent duplicate rows when
/// `departmentId` is null. The DAO must upsert by explicit
/// SELECT-then-insert-or-update for the null-department case rather than
/// relying on an ON CONFLICT clause.
class ClosingBalanceChecks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get departmentId =>
      integer().nullable().references(Departments, #id)();
  DateTimeColumn get checkDate => dateTime()();
  RealColumn get actualClosing => real()();
  IntColumn get enteredBy => integer().references(Users, #id)();
  DateTimeColumn get enteredAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {departmentId, checkDate},
      ];
}
