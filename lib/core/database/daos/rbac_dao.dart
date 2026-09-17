import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/permissions_table.dart';
import '../tables/role_permissions_table.dart';
import '../tables/roles_table.dart';
import '../tables/user_permission_overrides_table.dart';

part 'rbac_dao.g.dart';

@DriftAccessor(tables: [Roles, Permissions, RolePermissions, UserPermissionOverrides])
class RbacDao extends DatabaseAccessor<AppDatabase> with _$RbacDaoMixin {
  RbacDao(super.db);

  Future<Role?> roleById(int id) => (select(roles)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<Role?> roleByName(String name) =>
      (select(roles)..where((r) => r.name.equals(name))).getSingleOrNull();

  Future<List<Role>> allRoles() => select(roles).get();

  Future<Permission?> permissionByCode(String code) =>
      (select(permissions)..where((p) => p.code.equals(code))).getSingleOrNull();

  Future<List<Permission>> allPermissions() => select(permissions).get();

  /// `user_permission_overrides` is checked first; if no row exists for the
  /// given user+permission, falls back to the role's default grid. No row in
  /// either place means denied (deny-by-default, matching the old app).
  Future<bool> hasPermission({required int userId, required int roleId, required String permissionCode}) async {
    final permission = await permissionByCode(permissionCode);
    if (permission == null) return false;

    final override = await (select(userPermissionOverrides)
          ..where((o) => o.userId.equals(userId) & o.permissionId.equals(permission.id)))
        .getSingleOrNull();
    if (override != null) return override.allow;

    final roleGrant = await (select(rolePermissions)
          ..where((rp) => rp.roleId.equals(roleId) & rp.permissionId.equals(permission.id)))
        .getSingleOrNull();
    return roleGrant != null;
  }

  /// The full effective permission-code set for a user (used to build the
  /// nav/dashboard). Role defaults, then user overrides applied on top.
  Future<Set<String>> effectivePermissionCodes({required int userId, required int roleId}) async {
    final roleGrants = await (select(rolePermissions).join([
      innerJoin(permissions, permissions.id.equalsExp(rolePermissions.permissionId)),
    ])
          ..where(rolePermissions.roleId.equals(roleId)))
        .map((row) => row.readTable(permissions).code)
        .get();

    final effective = roleGrants.toSet();

    final overrides = await (select(userPermissionOverrides).join([
      innerJoin(permissions, permissions.id.equalsExp(userPermissionOverrides.permissionId)),
    ])
          ..where(userPermissionOverrides.userId.equals(userId)))
        .map((row) => (code: row.readTable(permissions).code, allow: row.readTable(userPermissionOverrides).allow))
        .get();

    for (final o in overrides) {
      if (o.allow) {
        effective.add(o.code);
      } else {
        effective.remove(o.code);
      }
    }
    return effective;
  }

  /// Full per-user grid for the permission-assignment screen: every
  /// permission paired with whether an override exists and its value, so the
  /// UI can render "inherits from role" vs an explicit on/off toggle.
  Future<List<({Permission permission, bool? overrideValue})>> gridForUser(int userId) async {
    final perms = await allPermissions();
    final overrides = await (select(userPermissionOverrides)..where((o) => o.userId.equals(userId))).get();
    final overrideByPermissionId = {for (final o in overrides) o.permissionId: o.allow};
    return [
      for (final p in perms) (permission: p, overrideValue: overrideByPermissionId[p.id]),
    ];
  }

  /// Reactive equivalent of [effectivePermissionCodes] — a single query
  /// joining `permissions` against both `role_permissions` (for [roleId])
  /// and `user_permission_overrides` (for [userId]) with LEFT JOINs, so
  /// Drift's dependency tracking re-emits whenever either table changes for
  /// this user/role. This is what makes a permission grant visible to an
  /// already-logged-in session without requiring a fresh login.
  Stream<Set<String>> watchEffectivePermissionCodes({required int userId, required int roleId}) {
    final query = select(permissions).join([
      leftOuterJoin(
        rolePermissions,
        rolePermissions.permissionId.equalsExp(permissions.id) & rolePermissions.roleId.equals(roleId),
      ),
      leftOuterJoin(
        userPermissionOverrides,
        userPermissionOverrides.permissionId.equalsExp(permissions.id) & userPermissionOverrides.userId.equals(userId),
      ),
    ]);
    return query.watch().map((rows) {
      final result = <String>{};
      for (final row in rows) {
        final code = row.readTable(permissions).code;
        final roleGranted = row.readTableOrNull(rolePermissions) != null;
        final override = row.readTableOrNull(userPermissionOverrides)?.allow;
        if (override ?? roleGranted) result.add(code);
      }
      return result;
    });
  }

  /// Sets (or clears, if [allow] is null) one user's override for a
  /// permission — the write path behind the per-user grid editor screen.
  ///
  /// Uses an explicit conflict target on (userId, permissionId) since that's
  /// a secondary unique key, not the table's primary key — `insertOnConflictUpdate`
  /// alone would target `id` instead and fail to update the existing row.
  Future<void> setUserOverride({required int userId, required int permissionId, required bool? allow}) async {
    if (allow == null) {
      await (delete(userPermissionOverrides)
            ..where((o) => o.userId.equals(userId) & o.permissionId.equals(permissionId)))
          .go();
      return;
    }
    await into(userPermissionOverrides).insert(
      UserPermissionOverridesCompanion.insert(userId: userId, permissionId: permissionId, allow: allow),
      onConflict: DoUpdate(
        (old) => UserPermissionOverridesCompanion.custom(allow: Constant(allow)),
        target: [userPermissionOverrides.userId, userPermissionOverrides.permissionId],
      ),
    );
  }
}
