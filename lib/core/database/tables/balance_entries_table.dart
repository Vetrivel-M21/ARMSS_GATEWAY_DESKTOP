import 'package:drift/drift.dart';

import 'departments_table.dart';
import 'sub_titles_table.dart';
import 'users_table.dart';

/// One row per (sub_title, entry_date) — mutable, upserted, admin-editable/
/// deletable directly (no append-only/reversal pattern; this was an explicit
/// decision to match the old app's behavior). `UNIQUE(subTitleId, entryDate)`
/// is enforced for real here — the old production DB relied on upsert
/// semantics without actually having this constraint.
@TableIndex(name: 'idx_balance_entries_dept_date', columns: {#departmentId, #entryDate})
@DataClassName('BalanceEntry')
class BalanceEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get subTitleId =>
      integer().references(SubTitles, #id, onDelete: KeyAction.cascade)();
  IntColumn get departmentId => integer().references(Departments, #id)();
  DateTimeColumn get entryDate => dateTime()();
  RealColumn get debitAmount => real().withDefault(const Constant(0))();
  RealColumn get creditAmount => real().withDefault(const Constant(0))();
  TextColumn get details => text().nullable()();
  IntColumn get createdBy => integer().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {subTitleId, entryDate},
      ];
}
