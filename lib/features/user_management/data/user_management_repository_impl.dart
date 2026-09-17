import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/result.dart';
import '../domain/repositories/user_management_repository.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final AppDatabase db;
  UserManagementRepositoryImpl(this.db);

  @override
  Stream<List<User>> watchAll() => db.userDao.watchAll();

  @override
  Future<List<Role>> allRoles() => db.rbacDao.allRoles();

  @override
  Future<List<int>> departmentIdsFor(int userId) => db.userDao.departmentIdsFor(userId);

  @override
  Future<Result<int>> createUser({
    required String username,
    required String password,
    required String fullName,
    required int roleId,
    required List<int> departmentIds,
  }) async {
    try {
      final id = await db.transaction(() async {
        final userId = await db.userDao.create(UsersCompanion.insert(
          username: username,
          password: password,
          fullName: fullName,
          roleId: roleId,
        ));
        await db.userDao.replaceDepartments(userId, departmentIds);
        return userId;
      });
      return Success(id);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<Result<void>> updateUser({
    required int id,
    required String username,
    required String fullName,
    required int roleId,
    required List<int> departmentIds,
  }) async {
    try {
      await db.transaction(() async {
        await db.userDao.updateUser(
          id,
          UsersCompanion(username: Value(username), fullName: Value(fullName), roleId: Value(roleId)),
        );
        await db.userDao.replaceDepartments(id, departmentIds);
      });
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<Result<void>> resetPassword({required int id, required String newPassword}) async {
    try {
      await db.userDao.resetPassword(id, newPassword);
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<Result<void>> toggleActive(int id) async {
    try {
      await db.userDao.toggleActive(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }
}
