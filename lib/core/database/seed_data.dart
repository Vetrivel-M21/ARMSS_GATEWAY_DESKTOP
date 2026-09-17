import '../constants/permission_keys.dart';

/// Seed rows written once in the DB's `onCreate` migration. Mirrors the old
/// app's default install: `admin`/`admin123` super_admin account, 3 roles,
/// 12 permissions (3 modules x 4 actions), and the 4 fixed main titles.
class SeedData {
  static const defaultAdminUsername = 'admin';
  static const defaultAdminPassword = 'admin123';

  static const roles = [
    (name: RoleName.superAdmin, description: 'Full unrestricted access', isSystemRole: true),
    (name: RoleName.admin, description: 'Full unrestricted access', isSystemRole: true),
    (name: RoleName.user, description: 'Access governed by per-user permissions', isSystemRole: true),
  ];

  static List<({String code, String module, String action})> get permissions => [
        for (final module in PermissionModule.values)
          for (final action in PermissionAction.values)
            (code: PermissionCode.of(module, action), module: module, action: action),
      ];

  static const mainTitles = ['ASSETS', 'LIABILITY', 'INCOME', 'EXPENSE'];
}
