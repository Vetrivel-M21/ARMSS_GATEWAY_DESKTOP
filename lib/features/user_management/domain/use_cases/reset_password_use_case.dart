import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/user_management_repository.dart';

/// No old-password check, no complexity rule — matches the old app's
/// `reset_pw` exactly (an admin can set any new plaintext password directly).
class ResetPasswordUseCase {
  final UserManagementRepository _repository;
  ResetPasswordUseCase(this._repository);

  Future<Result<void>> call({required AppUser actor, required int id, required String newPassword}) async {
    if (!actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can manage users.'));
    }
    if (newPassword.isEmpty) {
      return const Failure(ValidationException('New password is required.'));
    }
    return _repository.resetPassword(id: id, newPassword: newPassword);
  }
}
