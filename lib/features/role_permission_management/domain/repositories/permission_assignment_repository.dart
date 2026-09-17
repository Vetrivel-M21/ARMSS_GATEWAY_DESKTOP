import '../../../../core/database/app_database.dart';
import '../../../../core/errors/result.dart';

abstract class PermissionAssignmentRepository {
  /// User selector limited to `role='user'` accounts — matches the old
  /// app's userpermission.php (admin/super_admin bypass everything, so
  /// there's nothing to configure for them).
  Future<List<User>> selectableUsers();

  Future<List<({Permission permission, bool? overrideValue})>> gridForUser(int userId);

  Future<Result<void>> setOverride({required int userId, required int permissionId, required bool? allow});
}
