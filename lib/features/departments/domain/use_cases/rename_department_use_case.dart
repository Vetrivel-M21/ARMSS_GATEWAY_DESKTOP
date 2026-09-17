import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../../features/auth/domain/entities/app_user.dart';
import '../repositories/department_repository.dart';

class RenameDepartmentUseCase {
  final DepartmentRepository _repository;
  RenameDepartmentUseCase(this._repository);

  Future<Result<void>> call({required AppUser actor, required int id, required String name}) async {
    if (!actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can manage departments.'));
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Failure(ValidationException('Department name is required.'));
    }
    return _repository.rename(id, trimmed);
  }
}
