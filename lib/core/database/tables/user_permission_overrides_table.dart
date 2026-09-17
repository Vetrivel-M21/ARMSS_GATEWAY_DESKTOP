import 'package:drift/drift.dart';

import 'permissions_table.dart';
import 'users_table.dart';

/// Reproduces the old app's `user_permissions` table: permissions are
/// assigned per individual user, not just per role, so two accounts sharing
/// the `user` role can end up with different effective grids. Checked before
/// falling back to [RolePermissions] (see role_permissions_table.dart).
class UserPermissionOverrides extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  IntColumn get permissionId => integer().references(Permissions, #id)();
  BoolColumn get allow => boolean()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, permissionId},
      ];
}
