import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/balance_entries_table.dart';
import '../tables/sub_titles_table.dart';
import '../tables/titles_table.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [BalanceEntries, SubTitles, Titles])
class TransactionDao extends DatabaseAccessor<AppDatabase> with _$TransactionDaoMixin {
  TransactionDao(super.db);

  /// Reactive equivalent of the old app's missing `get_entries_for_date.php`:
  /// existing rows for a department+date, watched so the entry screen
  /// auto-refreshes on date/department change or after a delete elsewhere.
  Stream<List<BalanceEntry>> watchEntriesForDate({required int departmentId, required DateTime date}) {
    return (select(balanceEntries)
          ..where((e) => e.departmentId.equals(departmentId) & e.entryDate.equals(date)))
        .watch();
  }

  /// Upsert one row per (sub_title, date) — explicit conflict target on the
  /// secondary unique key, since the table's primary key is the autoincrement
  /// `id` and would not match on re-save of the same sub_title+date.
  Future<void> upsertEntry({
    required int subTitleId,
    required int departmentId,
    required DateTime entryDate,
    required double debitAmount,
    required double creditAmount,
    String? details,
    required int createdBy,
  }) async {
    await into(balanceEntries).insert(
      BalanceEntriesCompanion.insert(
        subTitleId: subTitleId,
        departmentId: departmentId,
        entryDate: entryDate,
        debitAmount: Value(debitAmount),
        creditAmount: Value(creditAmount),
        details: Value(details),
        createdBy: createdBy,
      ),
      onConflict: DoUpdate(
        (old) => BalanceEntriesCompanion.custom(
          debitAmount: Constant(debitAmount),
          creditAmount: Constant(creditAmount),
          details: Constant(details),
          updatedAt: Constant(DateTime.now()),
        ),
        target: [balanceEntries.subTitleId, balanceEntries.entryDate],
      ),
    );
  }

  /// Mirrors the old app's `save_all` order of operations exactly: the
  /// opening-balance write happens for every row (when the caller supplied
  /// one — omitted when the actor lacks edit permission), independent of
  /// whether that row's debit/credit/details are non-empty; the ledger entry
  /// itself is skipped for a row with nothing entered, same as the old
  /// app's `if ($debit == 0 && $credit == 0 && $details === '') continue;`.
  Future<void> saveAll(List<
      ({
        int subTitleId,
        int departmentId,
        DateTime entryDate,
        double debitAmount,
        double creditAmount,
        String? details,
        double? openingBalance,
      })> rows, {required int createdBy}) async {
    await transaction(() async {
      for (final r in rows) {
        if (r.openingBalance != null) {
          await updateOpeningBalance(subTitleId: r.subTitleId, openingBalance: r.openingBalance!);
        }
        if (r.debitAmount == 0 && r.creditAmount == 0 && (r.details == null || r.details!.isEmpty)) {
          continue;
        }
        await upsertEntry(
          subTitleId: r.subTitleId,
          departmentId: r.departmentId,
          entryDate: r.entryDate,
          debitAmount: r.debitAmount,
          creditAmount: r.creditAmount,
          details: r.details,
          createdBy: createdBy,
        );
      }
    });
  }

  /// Hard-restricted to admins by the calling use case, not here — this DAO
  /// method has no role awareness by design (RBAC is a domain-layer concern).
  Future<void> deleteEntry({required int subTitleId, required DateTime entryDate}) =>
      (delete(balanceEntries)..where((e) => e.subTitleId.equals(subTitleId) & e.entryDate.equals(entryDate))).go();

  Future<void> editEntry({
    required int id,
    required double debitAmount,
    required double creditAmount,
    String? details,
  }) =>
      (update(balanceEntries)..where((e) => e.id.equals(id))).write(
        BalanceEntriesCompanion(
          debitAmount: Value(debitAmount),
          creditAmount: Value(creditAmount),
          details: Value(details),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Sum of all entries strictly before [fromDate] for a sub_title — the
  /// period carry-forward opening balance calculation from the old report.
  Future<double> netBefore({required int subTitleId, required DateTime fromDate}) async {
    final query = selectOnly(balanceEntries)
      ..addColumns([balanceEntries.creditAmount.sum(), balanceEntries.debitAmount.sum()])
      ..where(balanceEntries.subTitleId.equals(subTitleId) & balanceEntries.entryDate.isSmallerThanValue(fromDate));
    final row = await query.getSingleOrNull();
    final credit = row?.read(balanceEntries.creditAmount.sum()) ?? 0;
    final debit = row?.read(balanceEntries.debitAmount.sum()) ?? 0;
    return credit - debit;
  }

  /// The individual dated rows behind one sub-title's report-period rollup —
  /// backs the report screen's drill-down.
  Future<List<BalanceEntry>> entriesForSubTitleInRange({
    required int subTitleId,
    required DateTime from,
    required DateTime to,
  }) {
    return (select(balanceEntries)
          ..where((e) =>
              e.subTitleId.equals(subTitleId) &
              e.entryDate.isBiggerOrEqualValue(from) &
              e.entryDate.isSmallerOrEqualValue(to))
          ..orderBy([(e) => OrderingTerm(expression: e.entryDate)]))
        .get();
  }

  /// Sum of debit/credit for a sub_title within [from, to] inclusive — the
  /// report period's own movement, on top of the carried-forward opening
  /// balance from [netBefore].
  Future<({double debit, double credit})> periodTotals({
    required int subTitleId,
    required DateTime from,
    required DateTime to,
  }) async {
    final query = selectOnly(balanceEntries)
      ..addColumns([balanceEntries.creditAmount.sum(), balanceEntries.debitAmount.sum()])
      ..where(balanceEntries.subTitleId.equals(subTitleId) &
          balanceEntries.entryDate.isBiggerOrEqualValue(from) &
          balanceEntries.entryDate.isSmallerOrEqualValue(to));
    final row = await query.getSingleOrNull();
    return (
      debit: row?.read(balanceEntries.debitAmount.sum()) ?? 0,
      credit: row?.read(balanceEntries.creditAmount.sum()) ?? 0,
    );
  }

  /// Sum of `sub_titles.opening_balance` across every sub-title in a
  /// department — the old app's "Save & Close" server check sums opening
  /// balance across every row on the entry form (not just rows with
  /// amounts), so the day's computed closing must include it too, not just
  /// that date's credit/debit movement.
  Future<double> _sumOpeningBalances(int departmentId) async {
    final query = selectOnly(subTitles).join([innerJoin(titles, titles.id.equalsExp(subTitles.titleId))])
      ..addColumns([subTitles.openingBalance.sum()])
      ..where(titles.departmentId.equals(departmentId));
    final row = await query.getSingleOrNull();
    return row?.read(subTitles.openingBalance.sum()) ?? 0;
  }

  /// Computed closing for a department+date: sum(opening balances) +
  /// sum(credit) - sum(debit), matching the old app's `save_all` formula
  /// exactly (`$calc_total += ($op + $cr - $de)` per row) — never a
  /// cached/trusted running total.
  Future<double> computeDayTotal({required int departmentId, required DateTime date}) async {
    final openingSum = await _sumOpeningBalances(departmentId);
    final query = selectOnly(balanceEntries)
      ..addColumns([balanceEntries.creditAmount.sum(), balanceEntries.debitAmount.sum()])
      ..where(balanceEntries.departmentId.equals(departmentId) & balanceEntries.entryDate.equals(date));
    final row = await query.getSingleOrNull();
    final credit = row?.read(balanceEntries.creditAmount.sum()) ?? 0;
    final debit = row?.read(balanceEntries.debitAmount.sum()) ?? 0;
    return openingSum + credit - debit;
  }

  Future<void> updateOpeningBalance({required int subTitleId, required double openingBalance}) {
    return (update(subTitles)..where((s) => s.id.equals(subTitleId)))
        .write(SubTitlesCompanion(openingBalance: Value(openingBalance), updatedAt: Value(DateTime.now())));
  }
}
