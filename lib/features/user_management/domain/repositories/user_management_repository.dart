import '../../../../core/database/app_database.dart';
import '../../../../core/errors/result.dart';

abstract class UserManagementRepository {
  Stream<List<User>> watchAll();
  Future<List<Role>> allRoles();
  Future<List<int>> departmentIdsFor(int userId);

  Future<Result<int>> createUser({
    required String username,
    required String password,
    required String fullName,
    required int roleId,
    required List<int> departmentIds,
  });

  Future<Result<void>> updateUser({
    required int id,
    required String username,
    required String fullName,
    required int roleId,
    required List<int> departmentIds,
  });

  Future<Result<void>> resetPassword({required int id, required String newPassword});

  Future<Result<void>> toggleActive(int id);
}
