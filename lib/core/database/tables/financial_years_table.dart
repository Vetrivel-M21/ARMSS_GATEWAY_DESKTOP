import 'package:drift/drift.dart';

/// Advisory reference data only — populates the report's FY filter dropdown
/// and date defaults. No OPEN/CLOSED status, no enforcement, no blocking
/// rules: the old app has no financial-year lock at all.
class FinancialYears extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get yearLabel => text().unique()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
}
