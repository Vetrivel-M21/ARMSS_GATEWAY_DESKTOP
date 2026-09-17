import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/permission_keys.dart';
import 'daos/audit_dao.dart';
import 'daos/chart_of_accounts_dao.dart';
import 'daos/day_book_dao.dart';
import 'daos/department_dao.dart';
import 'daos/export_dao.dart';
import 'daos/financial_year_dao.dart';
import 'daos/rbac_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/user_dao.dart';
import 'seed_data.dart';
import 'tables/audit_logs_table.dart';
import 'tables/balance_entries_table.dart';
import 'tables/closing_balance_checks_table.dart';
import 'tables/day_books_table.dart';
import 'tables/departments_table.dart';
import 'tables/export_password_history_table.dart';
import 'tables/financial_years_table.dart';
import 'tables/main_titles_table.dart';
import 'tables/permissions_table.dart';
import 'tables/role_permissions_table.dart';
import 'tables/roles_table.dart';
import 'tables/sub_title_groups_table.dart';
import 'tables/sub_titles_table.dart';
import 'tables/title_groups_table.dart';
import 'tables/titles_table.dart';
import 'tables/user_departments_table.dart';
import 'tables/user_permission_overrides_table.dart';
import 'tables/users_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Roles,
    Permissions,
    RolePermissions,
    UserPermissionOverrides,
    Users,
    Departments,
    UserDepartments,
    MainTitles,
    TitleGroups,
    Titles,
    SubTitleGroups,
    SubTitles,
    BalanceEntries,
    DayBooks,
    ClosingBalanceChecks,
    ExportPasswordHistory,
    AuditLogs,
    FinancialYears,
  ],
  daos: [
    RbacDao,
    UserDao,
    DepartmentDao,
    ChartOfAccountsDao,
    TransactionDao,
    DayBookDao,
    ExportDao,
    AuditDao,
    FinancialYearDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  /// A consistent, compacted single-file snapshot taken directly from this
  /// live connection — safe even mid-transaction, unlike copying the raw
  /// `.sqlite` file, which could catch a half-written page or miss data
  /// still sitting in a journal. `VACUUM INTO` refuses to overwrite an
  /// existing file, so callers must pass a destination that doesn't exist
  /// yet (e.g. a timestamped filename).
  Future<void> vacuumInto(String destinationPath) =>
      customStatement('VACUUM INTO ?', [destinationPath]);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (m) async {
          await m.createAll();
          await _seed(this);
        },
      );
}

Future<void> _seed(AppDatabase db) async {
  await db.transaction(() async {
    final roleIds = <String, int>{};
    for (final r in SeedData.roles) {
      final id = await db.into(db.roles).insert(RolesCompanion.insert(
            name: r.name,
            description: Value(r.description),
            isSystemRole: Value(r.isSystemRole),
          ));
      roleIds[r.name] = id;
    }

    final permissionIds = <String, int>{};
    for (final perm in SeedData.permissions) {
      final id = await db.into(db.permissions).insert(PermissionsCompanion.insert(
            code: perm.code,
            module: perm.module,
            action: perm.action,
          ));
      permissionIds[perm.code] = id;
    }

    // admin/super_admin bypass permission checks entirely at the domain
    // layer, but the grid is still populated so the permission-assignment
    // screen shows a consistent "full access" state for these roles.
    for (final roleName in [RoleName.admin, RoleName.superAdmin]) {
      final roleId = roleIds[roleName]!;
      for (final permId in permissionIds.values) {
        await db
            .into(db.rolePermissions)
            .insert(RolePermissionsCompanion.insert(roleId: roleId, permissionId: permId));
      }
    }
    // 'user' role gets nothing by default — deny-by-default, matching the
    // old app; admins grant access per individual user via overrides.

    final superAdminRoleId = roleIds[RoleName.superAdmin]!;
    await db.into(db.users).insert(UsersCompanion.insert(
          username: SeedData.defaultAdminUsername,
          password: SeedData.defaultAdminPassword,
          fullName: 'Administrator',
          roleId: superAdminRoleId,
        ));

    for (final name in SeedData.mainTitles) {
      await db.into(db.mainTitles).insert(MainTitlesCompanion.insert(name: name));
    }
  });
}

/// The live database file's path — shared by the connection itself and by
/// the backup/restore feature, which needs to know exactly where to close
/// and swap the file on disk.
Future<File> resolveDatabaseFile() async {
  final dbFolder = await getApplicationSupportDirectory();
  return File(p.join(dbFolder.path, 'mis_desktop.sqlite'));
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = await resolveDatabaseFile();
    return NativeDatabase.createInBackground(file);
  });
}
