import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../../features/auth/domain/entities/app_user.dart';
import '../repositories/department_repository.dart';

/// Role-gated only (admin/super_admin), matching the old app's
/// adddepartment.php — no granular permission row is consulted.
class AddDepartmentUseCase {
  final DepartmentRepository _repository;
  AddDepartmentUseCase(this._repository);

  Future<Result<int>> call({required AppUser actor, required String name}) async {
    if (!actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can manage departments.'));
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Failure(ValidationException('Department name is required.'));
    }
    return _repository.add(trimmed);
  }
}
