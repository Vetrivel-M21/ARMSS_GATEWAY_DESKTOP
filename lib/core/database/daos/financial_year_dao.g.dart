// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_year_dao.dart';

// ignore_for_file: type=lint
mixin _$FinancialYearDaoMixin on DatabaseAccessor<AppDatabase> {
  $FinancialYearsTable get financialYears => attachedDatabase.financialYears;
  FinancialYearDaoManager get managers => FinancialYearDaoManager(this);
}

class FinancialYearDaoManager {
  final _$FinancialYearDaoMixin _db;
  FinancialYearDaoManager(this._db);
  $$FinancialYearsTableTableManager get financialYears =>
      $$FinancialYearsTableTableManager(
        _db.attachedDatabase,
        _db.financialYears,
      );
}
