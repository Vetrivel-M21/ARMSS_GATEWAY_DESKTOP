import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/permission_assignment_repository.dart';

/// Role-gated only (admin/super_admin) — matches the old app's
/// userpermission.php.
class SetUserPermissionUseCase {
  final PermissionAssignmentRepository _repository;
  SetUserPermissionUseCase(this._repository);

  Future<Result<void>> call({
    required AppUser actor,
    required int userId,
    required int permissionId,
    required bool? allow,
  }) async {
    if (!actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can assign permissions.'));
    }
    return _repository.setOverride(userId: userId, permissionId: permissionId, allow: allow);
  }
}
