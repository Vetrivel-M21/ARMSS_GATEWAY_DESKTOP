import '../../../../core/constants/permission_keys.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/user_management_repository.dart';

class UpdateUserUseCase {
  final UserManagementRepository _repository;
  UpdateUserUseCase(this._repository);

  Future<Result<void>> call({
    required AppUser actor,
    required int id,
    required String username,
    required String fullName,
    required int roleId,
    required String roleName,
    required List<int> departmentIds,
  }) async {
    if (!actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can manage users.'));
    }
    if (username.trim().isEmpty || fullName.trim().isEmpty) {
      return const Failure(ValidationException('Username and full name are required.'));
    }
    if (roleName == RoleName.user && departmentIds.isEmpty) {
      return const Failure(ValidationException('At least one department is required for a user-role account.'));
    }
    return _repository.updateUser(
      id: id,
      username: username.trim(),
      fullName: fullName.trim(),
      roleId: roleId,
      departmentIds: departmentIds,
    );
  }
}
