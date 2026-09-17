import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/financial_years_table.dart';

part 'financial_year_dao.g.dart';

/// Advisory only — see financial_years_table.dart. No open/close enforcement.
@DriftAccessor(tables: [FinancialYears])
class FinancialYearDao extends DatabaseAccessor<AppDatabase> with _$FinancialYearDaoMixin {
  FinancialYearDao(super.db);

  Future<List<FinancialYear>> allYears() =>
      (select(financialYears)..orderBy([(y) => OrderingTerm.desc(y.startDate)])).get();

  Future<int> addYear({required String yearLabel, required DateTime startDate, required DateTime endDate}) {
    return into(financialYears)
        .insert(FinancialYearsCompanion.insert(yearLabel: yearLabel, startDate: startDate, endDate: endDate));
  }
}
