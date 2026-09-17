import 'package:drift/drift.dart';

/// Fixed 4-category chart of accounts root: ASSETS, LIABILITY, INCOME,
/// EXPENSE. Not user-editable, seeded once at DB creation.
class MainTitles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}
