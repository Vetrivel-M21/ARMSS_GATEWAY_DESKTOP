// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rbac_dao.dart';

// ignore_for_file: type=lint
mixin _$RbacDaoMixin on DatabaseAccessor<AppDatabase> {
  $RolesTable get roles => attachedDatabase.roles;
  $PermissionsTable get permissions => attachedDatabase.permissions;
  $RolePermissionsTable get rolePermissions => attachedDatabase.rolePermissions;
  $UserPermissionOverridesTable get userPermissionOverrides =>
      attachedDatabase.userPermissionOverrides;
  RbacDaoManager get managers => RbacDaoManager(this);
}

class RbacDaoManager {
  final _$RbacDaoMixin _db;
  RbacDaoManager(this._db);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db.attachedDatabase, _db.roles);
  $$PermissionsTableTableManager get permissions =>
      $$PermissionsTableTableManager(_db.attachedDatabase, _db.permissions);
  $$RolePermissionsTableTableManager get rolePermissions =>
      $$RolePermissionsTableTableManager(
        _db.attachedDatabase,
        _db.rolePermissions,
      );
  $$UserPermissionOverridesTableTableManager get userPermissionOverrides =>
      $$UserPermissionOverridesTableTableManager(
        _db.attachedDatabase,
        _db.userPermissionOverrides,
      );
}
