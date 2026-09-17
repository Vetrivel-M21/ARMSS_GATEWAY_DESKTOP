import '../../../../core/database/app_database.dart';
import '../../../../core/errors/result.dart';

class EntryRow {
  final int subTitleId;
  final double debitAmount;
  final double creditAmount;
  final String? details;

  /// Non-null only when the acting user has `balance_entry.edit` — matches
  /// the old app's `can_edit` gate on the Opening field specifically (a
  /// different permission than the `balance_entry.add` gate on debit/credit).
  final double? openingBalance;

  const EntryRow({
    required this.subTitleId,
    required this.debitAmount,
    required this.creditAmount,
    this.details,
    this.openingBalance,
  });
}

abstract class TransactionRepository {
  Stream<List<BalanceEntry>> watchEntriesForDate({required int departmentId, required DateTime date});

  Future<Result<void>> saveAll({
    required int departmentId,
    required DateTime entryDate,
    required List<EntryRow> rows,
    required int actingUserId,
  });

  Future<Result<void>> saveClosingCheck({
    int? departmentId,
    required DateTime checkDate,
    required double actualClosing,
    required int enteredBy,
  });

  Future<ClosingBalanceCheck?> getClosingCheck({int? departmentId, required DateTime checkDate});

  Future<ClosingBalanceCheck?> getEffectiveClosingCheck({required int departmentId, required DateTime checkDate});

  Future<bool> isClosed({required int departmentId, required DateTime date});

  Future<double> computeDayTotal({required int departmentId, required DateTime date});

  Future<Result<void>> closeDay({required int departmentId, required DateTime date, required int closedBy});

  Future<Result<void>> deleteEntry({required int subTitleId, required DateTime entryDate, required int actingUserId});

  Future<Result<void>> editEntry({
    required int id,
    required double debitAmount,
    required double creditAmount,
    String? details,
    required int actingUserId,
  });

  Future<double> netBefore({required int subTitleId, required DateTime fromDate});

  Future<List<BalanceEntry>> entriesForSubTitleInRange({
    required int subTitleId,
    required DateTime from,
    required DateTime to,
  });
}
