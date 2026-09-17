import '../../../../core/constants/permission_keys.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/user_management_repository.dart';

/// Role-gated only (admin/super_admin) — matches the old app's user.php.
class CreateUserUseCase {
  final UserManagementRepository _repository;
  CreateUserUseCase(this._repository);

  Future<Result<int>> call({
    required AppUser actor,
    required String username,
    required String password,
    required String fullName,
    required int roleId,
    required String roleName,
    required List<int> departmentIds,
  }) async {
    if (!actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can manage users.'));
    }
    if (username.trim().isEmpty || password.isEmpty || fullName.trim().isEmpty) {
      return const Failure(ValidationException('Username, password, and full name are required.'));
    }
    // Matches the old app: a plain 'user' account must have at least one
    // department assigned; admin/super_admin are unrestricted regardless.
    if (roleName == RoleName.user && departmentIds.isEmpty) {
      return const Failure(ValidationException('At least one department is required for a user-role account.'));
    }
    return _repository.createUser(
      username: username.trim(),
      password: password,
      fullName: fullName.trim(),
      roleId: roleId,
      departmentIds: departmentIds,
    );
  }
}
