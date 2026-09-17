import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/transaction_repository.dart';

/// Hard-restricted to admins regardless of any `balance_entry.delete`
/// permission a `user`-role account might hold — reproduces
/// `is_admin_or_super()` verbatim from the old app's delete_entry.php.
class DeleteBalanceEntryUseCase {
  final TransactionRepository _repository;
  DeleteBalanceEntryUseCase(this._repository);

  Future<Result<void>> call({required AppUser actor, required int subTitleId, required DateTime entryDate}) async {
    if (!actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can delete transaction entries.'));
    }
    return _repository.deleteEntry(subTitleId: subTitleId, entryDate: entryDate, actingUserId: actor.id);
  }
}
