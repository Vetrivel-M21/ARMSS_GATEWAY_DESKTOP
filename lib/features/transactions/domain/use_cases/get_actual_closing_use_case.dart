import '../../../../core/constants/permission_keys.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/transaction_repository.dart';

class GetActualClosingUseCase {
  final TransactionRepository _repository;
  GetActualClosingUseCase(this._repository);

  Future<Result<ClosingBalanceCheck?>> call({
    required AppUser actor,
    int? departmentId,
    required DateTime checkDate,
  }) async {
    if (!actor.has(PermissionCode.balanceEntryView)) {
      return const Failure(PermissionDeniedException('You do not have permission to view this.'));
    }
    return Success(await _repository.getClosingCheck(departmentId: departmentId, checkDate: checkDate));
  }
}
