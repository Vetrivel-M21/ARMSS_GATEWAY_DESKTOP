import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../../features/auth/domain/entities/app_user.dart';
import '../repositories/department_repository.dart';

/// Blocked if any title references the department — enforced in
/// [DepartmentRepository.delete] (and, additionally, by the DB's FK).
class DeleteDepartmentUseCase {
  final DepartmentRepository _repository;
  DeleteDepartmentUseCase(this._repository);

  Future<Result<void>> call({required AppUser actor, required int id}) async {
    if (!actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can manage departments.'));
    }
    return _repository.delete(id);
  }
}
