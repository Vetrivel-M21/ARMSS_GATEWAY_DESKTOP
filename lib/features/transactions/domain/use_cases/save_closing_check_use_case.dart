import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/transaction_repository.dart';

/// Admin-only — the "actual closing" figure is meant to be an independently
/// entered control value, not something the person recording entries can set
/// for themselves.
class SaveClosingCheckUseCase {
  final TransactionRepository _repository;
  SaveClosingCheckUseCase(this._repository);

  Future<Result<void>> call({
    required AppUser actor,
    int? departmentId,
    required DateTime checkDate,
    required double actualClosing,
  }) async {
    if (!actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can enter the actual-closing figure.'));
    }
    return _repository.saveClosingCheck(
      departmentId: departmentId,
      checkDate: checkDate,
      actualClosing: actualClosing,
      enteredBy: actor.id,
    );
  }
}
