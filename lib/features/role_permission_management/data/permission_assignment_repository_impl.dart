import '../../../core/constants/permission_keys.dart';
import '../../../core/database/app_database.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/result.dart';
import '../domain/repositories/permission_assignment_repository.dart';

class PermissionAssignmentRepositoryImpl implements PermissionAssignmentRepository {
  final AppDatabase db;
  PermissionAssignmentRepositoryImpl(this.db);

  @override
  Future<List<User>> selectableUsers() => db.userDao.usersWithRoleName(RoleName.user);

  @override
  Future<List<({Permission permission, bool? overrideValue})>> gridForUser(int userId) =>
      db.rbacDao.gridForUser(userId);

  @override
  Future<Result<void>> setOverride({required int userId, required int permissionId, required bool? allow}) async {
    try {
      await db.rbacDao.setUserOverride(userId: userId, permissionId: permissionId, allow: allow);
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }
}
