import '../../../core/database/app_database.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/result.dart';
import '../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase db;
  TransactionRepositoryImpl(this.db);

  @override
  Stream<List<BalanceEntry>> watchEntriesForDate({required int departmentId, required DateTime date}) =>
      db.transactionDao.watchEntriesForDate(departmentId: departmentId, date: date);

  @override
  Future<Result<void>> saveAll({
    required int departmentId,
    required DateTime entryDate,
    required List<EntryRow> rows,
    required int actingUserId,
  }) async {
    try {
      await db.transaction(() async {
        await db.transactionDao.saveAll(
          [
            for (final r in rows)
              (
                subTitleId: r.subTitleId,
                departmentId: departmentId,
                entryDate: entryDate,
                debitAmount: r.debitAmount,
                creditAmount: r.creditAmount,
                details: r.details,
                openingBalance: r.openingBalance,
              ),
          ],
          createdBy: actingUserId,
        );
        await db.auditDao.log(
          userId: actingUserId,
          action: 'SAVE_ENTRIES',
          entityTable: 'balance_entries',
          newValue: 'department=$departmentId date=${entryDate.toIso8601String()} rows=${rows.length}',
        );
      });
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<Result<void>> saveClosingCheck({
    int? departmentId,
    required DateTime checkDate,
    required double actualClosing,
    required int enteredBy,
  }) async {
    try {
      await db.dayBookDao.saveClosingCheck(
        departmentId: departmentId,
        checkDate: checkDate,
        actualClosing: actualClosing,
        enteredBy: enteredBy,
      );
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<ClosingBalanceCheck?> getClosingCheck({int? departmentId, required DateTime checkDate}) =>
      db.dayBookDao.getClosingCheck(departmentId: departmentId, checkDate: checkDate);

  @override
  Future<ClosingBalanceCheck?> getEffectiveClosingCheck({required int departmentId, required DateTime checkDate}) =>
      db.dayBookDao.getEffectiveClosingCheck(departmentId: departmentId, checkDate: checkDate);

  @override
  Future<bool> isClosed({required int departmentId, required DateTime date}) =>
      db.dayBookDao.isClosed(departmentId: departmentId, date: date);

  @override
  Future<double> computeDayTotal({required int departmentId, required DateTime date}) =>
      db.transactionDao.computeDayTotal(departmentId: departmentId, date: date);

  @override
  Future<Result<void>> closeDay({required int departmentId, required DateTime date, required int closedBy}) async {
    try {
      await db.transaction(() async {
        final computed = await db.transactionDao.computeDayTotal(departmentId: departmentId, date: date);
        await db.dayBookDao.closeDay(departmentId: departmentId, date: date, computedClosing: computed, closedBy: closedBy);
        await db.auditDao.log(
          userId: closedBy,
          action: 'DAY_CLOSE',
          entityTable: 'day_books',
          newValue: 'department=$departmentId date=${date.toIso8601String()} computedClosing=$computed',
        );
      });
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<Result<void>> deleteEntry({
    required int subTitleId,
    required DateTime entryDate,
    required int actingUserId,
  }) async {
    try {
      await db.transaction(() async {
        await db.transactionDao.deleteEntry(subTitleId: subTitleId, entryDate: entryDate);
        await db.auditDao.log(
          userId: actingUserId,
          action: 'DELETE',
          entityTable: 'balance_entries',
          oldValue: 'subTitleId=$subTitleId date=${entryDate.toIso8601String()}',
        );
      });
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<Result<void>> editEntry({
    required int id,
    required double debitAmount,
    required double creditAmount,
    String? details,
    required int actingUserId,
  }) async {
    try {
      await db.transaction(() async {
        await db.transactionDao.editEntry(id: id, debitAmount: debitAmount, creditAmount: creditAmount, details: details);
        await db.auditDao.log(
          userId: actingUserId,
          action: 'EDIT',
          entityTable: 'balance_entries',
          recordId: id,
          newValue: 'debit=$debitAmount credit=$creditAmount details=$details',
        );
      });
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<double> netBefore({required int subTitleId, required DateTime fromDate}) =>
      db.transactionDao.netBefore(subTitleId: subTitleId, fromDate: fromDate);

  @override
  Future<List<BalanceEntry>> entriesForSubTitleInRange({
    required int subTitleId,
    required DateTime from,
    required DateTime to,
  }) =>
      db.transactionDao.entriesForSubTitleInRange(subTitleId: subTitleId, from: from, to: to);
}
