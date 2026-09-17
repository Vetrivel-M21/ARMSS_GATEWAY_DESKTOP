import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/transaction_repository.dart';

/// Hard-restricted to admins, same as delete — and deliberately does not
/// touch day_book status, matching the old app's edit_entry.php not
/// resetting `is_closed` when editing a closed day's entry.
class EditBalanceEntryUseCase {
  final TransactionRepository _repository;
  EditBalanceEntryUseCase(this._repository);

  Future<Result<void>> call({
    required AppUser actor,
    required int id,
    required double debitAmount,
    required double creditAmount,
    String? details,
  }) async {
    if (!actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can edit transaction entries.'));
    }
    return _repository.editEntry(
      id: id,
      debitAmount: debitAmount,
      creditAmount: creditAmount,
      details: details,
      actingUserId: actor.id,
    );
  }
}
