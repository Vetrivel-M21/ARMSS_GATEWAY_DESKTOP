/// The 3 controllable modules and 4 actions the old app's `user_permissions`
/// table covered (`addtitle`, `balanceentry`, `balancereport` × view/add/edit/delete).
/// Kept as the same 3-module boundary here, just stored as role/permission
/// rows instead of raw per-user boolean columns.
class PermissionModule {
  static const titles = 'titles';
  static const balanceEntry = 'balance_entry';
  static const balanceReport = 'balance_report';

  static const values = [titles, balanceEntry, balanceReport];
}

class PermissionAction {
  static const view = 'view';
  static const add = 'add';
  static const edit = 'edit';
  static const delete = 'delete';

  static const values = [view, add, edit, delete];
}

class PermissionCode {
  static String of(String module, String action) => '$module.$action';

  static const titlesView = 'titles.view';
  static const titlesAdd = 'titles.add';
  static const titlesEdit = 'titles.edit';
  static const titlesDelete = 'titles.delete';

  static const balanceEntryView = 'balance_entry.view';
  static const balanceEntryAdd = 'balance_entry.add';
  static const balanceEntryEdit = 'balance_entry.edit';
  static const balanceEntryDelete = 'balance_entry.delete';

  static const balanceReportView = 'balance_report.view';
  static const balanceReportAdd = 'balance_report.add';
  static const balanceReportEdit = 'balance_report.edit';
  static const balanceReportDelete = 'balance_report.delete';

  static const values = [
    titlesView, titlesAdd, titlesEdit, titlesDelete,
    balanceEntryView, balanceEntryAdd, balanceEntryEdit, balanceEntryDelete,
    balanceReportView, balanceReportAdd, balanceReportEdit, balanceReportDelete,
  ];
}

/// Roles: `super_admin` and `admin` bypass all permission and department
/// checks everywhere (is_admin_or_super equivalent). Only `user` accounts
/// are gated by `user_permission_overrides` / `role_permissions`.
class RoleName {
  static const superAdmin = 'super_admin';
  static const admin = 'admin';
  static const user = 'user';

  static bool isAdminOrSuper(String role) => role == admin || role == superAdmin;
}
