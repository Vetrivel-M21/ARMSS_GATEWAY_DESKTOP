import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/rbac/current_user_provider.dart';
import '../../data/transaction_repository_impl.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/use_cases/delete_balance_entry_use_case.dart';
import '../../domain/use_cases/edit_balance_entry_use_case.dart';
import '../../domain/use_cases/save_all_entries_use_case.dart';
import '../../domain/use_cases/save_closing_check_use_case.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.watch(appDatabaseProvider));
});

final selectedEntryDepartmentIdProvider = StateProvider<int?>((ref) => null);
final selectedEntryDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final watchEntriesForDateProvider =
    StreamProvider.family<List<BalanceEntry>, ({int departmentId, DateTime date})>((ref, key) {
  return ref.watch(transactionRepositoryProvider).watchEntriesForDate(departmentId: key.departmentId, date: key.date);
});

final isDayClosedProvider = FutureProvider.family<bool, ({int departmentId, DateTime date})>((ref, key) {
  return ref.watch(transactionRepositoryProvider).isClosed(departmentId: key.departmentId, date: key.date);
});

final entriesInRangeProvider =
    FutureProvider.family<List<BalanceEntry>, ({int subTitleId, DateTime from, DateTime to})>((ref, key) {
  return ref.watch(transactionRepositoryProvider).entriesForSubTitleInRange(subTitleId: key.subTitleId, from: key.from, to: key.to);
});

final actualClosingProvider =
    FutureProvider.family<ClosingBalanceCheck?, ({int? departmentId, DateTime date})>((ref, key) {
  return ref.watch(transactionRepositoryProvider).getClosingCheck(departmentId: key.departmentId, checkDate: key.date);
});

/// The figure Save & Close will actually validate against (department-
/// specific, falling back to the "all departments" bucket) — what the live
/// calculated-vs-actual bar compares to.
final effectiveActualClosingProvider =
    FutureProvider.family<ClosingBalanceCheck?, ({int departmentId, DateTime date})>((ref, key) {
  return ref.watch(transactionRepositoryProvider).getEffectiveClosingCheck(departmentId: key.departmentId, checkDate: key.date);
});

class TransactionActionsController extends Notifier<AppException?> {
  @override
  AppException? build() => null;

  Future<bool> saveAll({
    required int departmentId,
    required DateTime entryDate,
    required List<EntryRow> rows,
    bool closeConfirm = false,
  }) async {
    final actor = ref.read(currentUserProvider)!;
    final useCase = SaveAllEntriesUseCase(ref.read(transactionRepositoryProvider));
    final result =
        await useCase.call(actor: actor, departmentId: departmentId, entryDate: entryDate, rows: rows, closeConfirm: closeConfirm);
    state = result.errorOrNull;
    return result.isSuccess;
  }

  Future<bool> saveClosingCheck({int? departmentId, required DateTime checkDate, required double actualClosing}) async {
    final actor = ref.read(currentUserProvider)!;
    final useCase = SaveClosingCheckUseCase(ref.read(transactionRepositoryProvider));
    final result = await useCase.call(actor: actor, departmentId: departmentId, checkDate: checkDate, actualClosing: actualClosing);
    state = result.errorOrNull;
    return result.isSuccess;
  }

  Future<bool> deleteEntry({required int subTitleId, required DateTime entryDate}) async {
    final actor = ref.read(currentUserProvider)!;
    final useCase = DeleteBalanceEntryUseCase(ref.read(transactionRepositoryProvider));
    final result = await useCase.call(actor: actor, subTitleId: subTitleId, entryDate: entryDate);
    state = result.errorOrNull;
    return result.isSuccess;
  }

  Future<bool> editEntry({required int id, required double debitAmount, required double creditAmount, String? details}) async {
    final actor = ref.read(currentUserProvider)!;
    final useCase = EditBalanceEntryUseCase(ref.read(transactionRepositoryProvider));
    final result = await useCase.call(actor: actor, id: id, debitAmount: debitAmount, creditAmount: creditAmount, details: details);
    state = result.errorOrNull;
    return result.isSuccess;
  }
}

final transactionActionsControllerProvider =
    NotifierProvider<TransactionActionsController, AppException?>(TransactionActionsController.new);
