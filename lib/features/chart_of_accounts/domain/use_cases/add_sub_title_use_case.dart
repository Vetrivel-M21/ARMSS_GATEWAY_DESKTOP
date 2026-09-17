import '../../../../core/constants/permission_keys.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/chart_of_accounts_repository.dart';

class AddSubTitleUseCase {
  final ChartOfAccountsRepository _repository;
  AddSubTitleUseCase(this._repository);

  Future<Result<int>> call({
    required AppUser actor,
    required int titleId,
    required String subTitleName,
    required double openingBalance,
    bool applyAllDepartments = false,
  }) async {
    if (!actor.has(PermissionCode.titlesAdd)) {
      return const Failure(PermissionDeniedException('You do not have permission to add sub-titles.'));
    }
    if (applyAllDepartments && !actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can apply a sub-title to all departments.'));
    }
    if (subTitleName.trim().isEmpty) {
      return const Failure(ValidationException('Sub-title name is required.'));
    }
    return _repository.addSubTitle(
      titleId: titleId,
      subTitleName: subTitleName.trim(),
      openingBalance: openingBalance,
      createdBy: actor.id,
      applyAllDepartments: applyAllDepartments,
    );
  }
}
