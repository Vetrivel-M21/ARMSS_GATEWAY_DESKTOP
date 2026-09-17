import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/user_management_repository.dart';

/// The old app hard-protected a specific hardcoded user id from deactivation;
/// this is generalized to "cannot deactivate the last active super_admin"
/// (enforced in UserDao.toggleActive, surfaced here as a BusinessRuleException).
class ToggleActiveUseCase {
  final UserManagementRepository _repository;
  ToggleActiveUseCase(this._repository);

  Future<Result<void>> call({required AppUser actor, required int id}) async {
    if (!actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can manage users.'));
    }
    return _repository.toggleActive(id);
  }
}
