import 'package:drift/drift.dart';

import '../../../core/constants/permission_keys.dart';
import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/result.dart';
import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AppDatabase db;
  AuthRepositoryImpl(this.db);

  /// Plaintext comparison and a generic error for both "no such user" and
  /// "wrong password" (no account enumeration) — matches the old app exactly.
  @override
  Future<Result<AppUser>> login(String username, String password) async {
    try {
      final user = await db.userDao.byUsername(username);
      if (user == null || user.password != password) {
        return const Failure(ValidationException('Invalid username or password.'));
      }
      if (!user.isActive) {
        return const Failure(PermissionDeniedException('This account has been deactivated.'));
      }

      final role = await db.rbacDao.roleById(user.roleId);
      if (role == null) {
        return const Failure(DatabaseException('User role could not be resolved.'));
      }

      final departmentIds = await db.userDao.departmentIdsFor(user.id);
      final permissionCodes = RoleName.isAdminOrSuper(role.name)
          ? const <String>{}
          : await db.rbacDao.effectivePermissionCodes(userId: user.id, roleId: role.id);

      await db.userDao.updateUser(user.id, UsersCompanion(lastLoginAt: Value(DateTime.now())));

      return Success(AppUser(
        id: user.id,
        username: user.username,
        fullName: user.fullName,
        roleId: role.id,
        roleName: role.name,
        departmentIds: departmentIds,
        permissionCodes: permissionCodes,
      ));
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }
}
