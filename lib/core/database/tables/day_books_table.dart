import 'package:drift/drift.dart';

import 'closing_balance_checks_table.dart';
import 'departments_table.dart';
import 'users_table.dart';

/// Day-book header row per (department, business_date). Created lazily on
/// first entry — there is no explicit "open day" action, no single-open-day
/// rule, and no sequential close-before-open rule (all deliberately dropped;
/// the old app has none of this). `close_day()` recomputes from
/// balance_entries and blocks unless it matches the linked
/// [ClosingBalanceChecks.actualClosing] within 0.01. Admins can still edit/
/// delete entries under a CLOSED day with no unlock step, exactly as today.
class DayBooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get departmentId => integer().references(Departments, #id)();
  DateTimeColumn get businessDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('OPEN'))();
  RealColumn get computedClosing => real().nullable()();
  IntColumn get closingCheckId =>
      integer().nullable().references(ClosingBalanceChecks, #id)();
  IntColumn get closedBy => integer().nullable().references(Users, #id)();
  DateTimeColumn get closedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {departmentId, businessDate},
      ];
}
