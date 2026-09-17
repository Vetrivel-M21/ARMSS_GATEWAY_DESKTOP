import '../../../../core/constants/permission_keys.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/chart_of_accounts_repository.dart';

class EditSubTitleUseCase {
  final ChartOfAccountsRepository _repository;
  EditSubTitleUseCase(this._repository);

  Future<Result<void>> call({
    required AppUser actor,
    required int id,
    required String subTitleName,
    bool applyAllDepartments = false,
  }) async {
    if (!actor.has(PermissionCode.titlesEdit)) {
      return const Failure(PermissionDeniedException('You do not have permission to edit sub-titles.'));
    }
    if (applyAllDepartments && !actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can propagate a sub-title.'));
    }
    if (subTitleName.trim().isEmpty) {
      return const Failure(ValidationException('Sub-title name is required.'));
    }
    return _repository.editSubTitle(
      id: id,
      subTitleName: subTitleName.trim(),
      applyAllDepartments: applyAllDepartments,
      actingUserId: actor.id,
    );
  }
}
