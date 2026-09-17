import '../../../../core/constants/permission_keys.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/chart_of_accounts_repository.dart';

class EditTitleUseCase {
  final ChartOfAccountsRepository _repository;
  EditTitleUseCase(this._repository);

  Future<Result<void>> call({
    required AppUser actor,
    required int id,
    required String titleName,
    String? vfNo,
    int? newDepartmentId,
    bool applyAllDepartments = false,
  }) async {
    if (!actor.has(PermissionCode.titlesEdit)) {
      return const Failure(PermissionDeniedException('You do not have permission to edit titles.'));
    }
    // Moving a title to a different department, or propagating it, is
    // admin-only — matches the old app's edit_title.
    if ((newDepartmentId != null || applyAllDepartments) && !actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can move or propagate a title.'));
    }
    if (titleName.trim().isEmpty) {
      return const Failure(ValidationException('Title name is required.'));
    }
    return _repository.editTitle(
      id: id,
      titleName: titleName.trim(),
      vfNo: vfNo,
      newDepartmentId: newDepartmentId,
      applyAllDepartments: applyAllDepartments,
      actingUserId: actor.id,
    );
  }
}
