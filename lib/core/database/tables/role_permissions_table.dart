import 'package:drift/drift.dart';

import 'permissions_table.dart';
import 'roles_table.dart';

/// Base/default permission grid per role. Per-user grids override this via
/// [UserPermissionOverrides] — see that table's doc comment for why both exist.
class RolePermissions extends Table {
  IntColumn get roleId => integer().references(Roles, #id)();
  IntColumn get permissionId => integer().references(Permissions, #id)();

  @override
  Set<Column> get primaryKey => {roleId, permissionId};
}
