import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/closing_balance_checks_table.dart';
import '../tables/day_books_table.dart';

part 'day_book_dao.g.dart';

@DriftAccessor(tables: [DayBooks, ClosingBalanceChecks])
class DayBookDao extends DatabaseAccessor<AppDatabase> with _$DayBookDaoMixin {
  DayBookDao(super.db);

  Future<DayBook?> find({required int departmentId, required DateTime date}) =>
      (select(dayBooks)..where((d) => d.departmentId.equals(departmentId) & d.businessDate.equals(date)))
          .getSingleOrNull();

  /// Creates the header row the first time a department+date is touched.
  /// There is no explicit "open day" user action and no single-open-day
  /// rule — any department may have entries on any date at any time.
  Future<DayBook> findOrCreate({required int departmentId, required DateTime date}) async {
    final existing = await find(departmentId: departmentId, date: date);
    if (existing != null) return existing;
    await into(dayBooks).insert(DayBooksCompanion.insert(departmentId: departmentId, businessDate: date));
    return (await find(departmentId: departmentId, date: date))!;
  }

  /// `department_id = null` represents the old app's "all departments"
  /// bucket. NULL is not equal to NULL for SQLite's UNIQUE-constraint
  /// purposes, so this upserts by explicit SELECT-then-insert-or-update
  /// rather than relying on ON CONFLICT for the null-department case.
  Future<void> saveClosingCheck({
    int? departmentId,
    required DateTime checkDate,
    required double actualClosing,
    required int enteredBy,
  }) async {
    final existing = await (select(closingBalanceChecks)
          ..where((c) =>
              (departmentId == null ? c.departmentId.isNull() : c.departmentId.equals(departmentId)) &
              c.checkDate.equals(checkDate)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(closingBalanceChecks)..where((c) => c.id.equals(existing.id))).write(
        ClosingBalanceChecksCompanion(actualClosing: Value(actualClosing), enteredBy: Value(enteredBy)),
      );
    } else {
      await into(closingBalanceChecks).insert(ClosingBalanceChecksCompanion.insert(
        departmentId: Value(departmentId),
        checkDate: checkDate,
        actualClosing: actualClosing,
        enteredBy: enteredBy,
      ));
    }
  }

  Future<ClosingBalanceCheck?> getClosingCheck({int? departmentId, required DateTime checkDate}) =>
      (select(closingBalanceChecks)
            ..where((c) =>
                (departmentId == null ? c.departmentId.isNull() : c.departmentId.equals(departmentId)) &
                c.checkDate.equals(checkDate)))
          .getSingleOrNull();

  /// The figure `closeDay` will actually check against: a department-
  /// specific entry if one exists, else the "all departments" bucket. Used
  /// by the UI's live calculated-vs-actual comparison so what's displayed
  /// always matches what closing will actually validate against.
  Future<ClosingBalanceCheck?> getEffectiveClosingCheck({required int departmentId, required DateTime checkDate}) async {
    return await getClosingCheck(departmentId: departmentId, checkDate: checkDate) ??
        await getClosingCheck(departmentId: null, checkDate: checkDate);
  }

  /// Closes a day book only if [computedClosing] matches the admin-entered
  /// actual-closing figure within 0.01 tolerance. Throws if no closing check
  /// has been entered yet, or if the figures don't match.
  Future<void> closeDay({
    required int departmentId,
    required DateTime date,
    required double computedClosing,
    required int closedBy,
  }) async {
    final check = await getEffectiveClosingCheck(departmentId: departmentId, checkDate: date);
    if (check == null) {
      throw StateError('No actual-closing figure has been entered for this date yet.');
    }
    if ((check.actualClosing - computedClosing).abs() > 0.01) {
      throw StateError(
        'Computed closing ($computedClosing) does not match the entered actual closing (${check.actualClosing}).',
      );
    }
    final dayBook = await findOrCreate(departmentId: departmentId, date: date);
    await (update(dayBooks)..where((d) => d.id.equals(dayBook.id))).write(DayBooksCompanion(
      status: const Value('CLOSED'),
      computedClosing: Value(computedClosing),
      closingCheckId: Value(check.id),
      closedBy: Value(closedBy),
      closedAt: Value(DateTime.now()),
    ));
  }

  Future<bool> isClosed({required int departmentId, required DateTime date}) async {
    final dayBook = await find(departmentId: departmentId, date: date);
    return dayBook?.status == 'CLOSED';
  }
}
