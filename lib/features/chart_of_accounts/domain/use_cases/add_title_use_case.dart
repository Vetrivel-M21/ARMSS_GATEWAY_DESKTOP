import '../../../../core/constants/permission_keys.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/chart_of_accounts_repository.dart';

class AddTitleUseCase {
  final ChartOfAccountsRepository _repository;
  AddTitleUseCase(this._repository);

  Future<Result<int>> call({
    required AppUser actor,
    required int mainTitleId,
    required int departmentId,
    required String titleName,
    String? vfNo,
    bool applyAllDepartments = false,
  }) async {
    if (!actor.has(PermissionCode.titlesAdd)) {
      return const Failure(PermissionDeniedException('You do not have permission to add titles.'));
    }
    // "apply to all departments" is only meaningful for admins in the old
    // app (it bypasses department scoping by design); non-admins are always
    // re-validated against their own department list.
    if (!applyAllDepartments && !actor.canAccessDepartment(departmentId)) {
      return const Failure(PermissionDeniedException('You do not have access to this department.'));
    }
    if (applyAllDepartments && !actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can apply a title to all departments.'));
    }
    if (titleName.trim().isEmpty) {
      return const Failure(ValidationException('Title name is required.'));
    }
    return _repository.addTitle(
      mainTitleId: mainTitleId,
      departmentId: departmentId,
      titleName: titleName.trim(),
      vfNo: vfNo,
      createdBy: actor.id,
      applyAllDepartments: applyAllDepartments,
    );
  }
}
