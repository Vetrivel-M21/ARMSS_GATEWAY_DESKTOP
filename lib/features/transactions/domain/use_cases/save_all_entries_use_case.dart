import '../../../../core/constants/permission_keys.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/transaction_repository.dart';

/// Bulk save (upsert) for a department+date, with an optional "Save & Close"
/// via [closeConfirm] — matches the old app's `save_all` action, including
/// close_confirm re-validating against the admin-entered actual-closing
/// figure. Closing itself is NOT admin-only: any account with
/// `balance_entry.add` can trigger it, same as a normal save — only entering
/// the actual-closing figure (see SaveClosingCheckUseCase) is admin-gated.
class SaveAllEntriesUseCase {
  final TransactionRepository _repository;
  SaveAllEntriesUseCase(this._repository);

  Future<Result<void>> call({
    required AppUser actor,
    required int departmentId,
    required DateTime entryDate,
    required List<EntryRow> rows,
    bool closeConfirm = false,
  }) async {
    if (!actor.has(PermissionCode.balanceEntryAdd)) {
      return const Failure(PermissionDeniedException('You do not have permission to enter transactions.'));
    }
    if (!actor.canAccessDepartment(departmentId)) {
      return const Failure(PermissionDeniedException('You do not have access to this department.'));
    }
    if (!actor.isAdminOrSuper && await _repository.isClosed(departmentId: departmentId, date: entryDate)) {
      return const Failure(BusinessRuleException('This date has already been closed for this department.'));
    }

    final saveResult =
        await _repository.saveAll(departmentId: departmentId, entryDate: entryDate, rows: rows, actingUserId: actor.id);
    if (saveResult.isFailure) return saveResult;

    if (closeConfirm) {
      return _repository.closeDay(departmentId: departmentId, date: entryDate, closedBy: actor.id);
    }
    return const Success(null);
  }
}
