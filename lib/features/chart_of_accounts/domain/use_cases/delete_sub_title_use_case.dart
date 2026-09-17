import '../../../../core/constants/permission_keys.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/chart_of_accounts_repository.dart';

class DeleteSubTitleUseCase {
  final ChartOfAccountsRepository _repository;
  DeleteSubTitleUseCase(this._repository);

  Future<Result<void>> call({required AppUser actor, required int id}) async {
    if (!actor.has(PermissionCode.titlesDelete)) {
      return const Failure(PermissionDeniedException('You do not have permission to delete sub-titles.'));
    }
    return _repository.deleteSubTitle(id);
  }
}
