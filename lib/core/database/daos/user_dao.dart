import 'package:drift/drift.dart';

import '../../constants/permission_keys.dart';
import '../app_database.dart';
import '../tables/roles_table.dart';
import '../tables/user_departments_table.dart';
import '../tables/users_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users, UserDepartments, Roles])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<User?> byId(int id) => (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();

  Future<User?> byUsername(String username) =>
      (select(users)..where((u) => u.username.equals(username))).getSingleOrNull();

  Stream<List<User>> watchAll() => select(users).watch();

  /// Used by the permission-assignment screen's user selector, which (like
  /// the old app's userpermission.php) only lists `role='user'` accounts —
  /// admin/super_admin bypass all permission checks, so there's nothing to
  /// configure for them.
  Future<List<User>> usersWithRoleName(String roleName) async {
    final query = select(users).join([innerJoin(roles, roles.id.equalsExp(users.roleId))])
      ..where(roles.name.equals(roleName));
    final rows = await query.get();
    return rows.map((r) => r.readTable(users)).toList();
  }

  Future<int> create(UsersCompanion companion) => into(users).insert(companion);

  /// Named `updateUser`, not `update` — the latter collides with the
  /// inherited `DatabaseConnectionUser.update`, which this method's body
  /// needs to call.
  Future<void> updateUser(int id, UsersCompanion companion) =>
      (update(users)..where((u) => u.id.equals(id))).write(companion);

  /// Plaintext reset, no old-password check — matches old app's `reset_pw`.
  Future<void> resetPassword(int id, String newPassword) =>
      (update(users)..where((u) => u.id.equals(id))).write(UsersCompanion(password: Value(newPassword)));

  /// Old app protected a hardcoded user id 1 from deactivation; generalized
  /// here to "cannot deactivate the last remaining active super_admin".
  Future<bool> isLastActiveSuperAdmin(int userId) async {
    final superAdminRole = await (select(roles)..where((r) => r.name.equals(RoleName.superAdmin))).getSingleOrNull();
    if (superAdminRole == null) return false;
    final activeSuperAdmins = await (select(users)
          ..where((u) => u.roleId.equals(superAdminRole.id) & u.isActive.equals(true)))
        .get();
    return activeSuperAdmins.length == 1 && activeSuperAdmins.first.id == userId;
  }

  Future<void> toggleActive(int id) async {
    final user = await byId(id);
    if (user == null) return;
    if (user.isActive && await isLastActiveSuperAdmin(id)) {
      throw StateError('Cannot deactivate the last remaining active super_admin.');
    }
    await (update(users)..where((u) => u.id.equals(id))).write(UsersCompanion(isActive: Value(!user.isActive)));
  }

  Future<List<int>> departmentIdsFor(int userId) async {
    final rows = await (select(userDepartments)..where((d) => d.userId.equals(userId))).get();
    return rows.map((r) => r.departmentId).toList();
  }

  /// Reactive equivalent of `byId` + a role-name lookup, joined into one
  /// watched query so the current-user session can rebuild live if the
  /// user's own row (name, role, active-status) changes mid-session.
  Stream<({User user, String roleName})?> watchByIdWithRole(int id) {
    final query = select(users).join([innerJoin(roles, roles.id.equalsExp(users.roleId))])
      ..where(users.id.equals(id));
    return query.watchSingleOrNull().map((row) {
      if (row == null) return null;
      return (user: row.readTable(users), roleName: row.readTable(roles).name);
    });
  }

  /// Reactive equivalent of `departmentIdsFor` — re-emits whenever an
  /// admin reassigns this user's departments.
  Stream<List<int>> watchDepartmentIds(int userId) {
    return (select(userDepartments)..where((d) => d.userId.equals(userId)))
        .watch()
        .map((rows) => rows.map((r) => r.departmentId).toList());
  }

  Future<void> replaceDepartments(int userId, List<int> departmentIds) async {
    await transaction(() async {
      await (delete(userDepartments)..where((d) => d.userId.equals(userId))).go();
      for (final deptId in departmentIds) {
        await into(userDepartments)
            .insert(UserDepartmentsCompanion.insert(userId: userId, departmentId: deptId));
      }
    });
  }
}
