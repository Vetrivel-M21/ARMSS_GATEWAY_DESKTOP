/// The current session's user — decoupled from the Drift row type so the
/// rest of the app never depends on the persistence layer's shape.
class AppUser {
  final int id;
  final String username;
  final String fullName;
  final int roleId;
  final String roleName;
  final List<int> departmentIds;
  final Set<String> permissionCodes;

  const AppUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.roleId,
    required this.roleName,
    required this.departmentIds,
    required this.permissionCodes,
  });

  bool get isAdminOrSuper => roleName == 'admin' || roleName == 'super_admin';

  /// Empty list means unrestricted (admin/super_admin), matching the old
  /// app's `current_department_ids()` semantics.
  bool canAccessDepartment(int departmentId) =>
      isAdminOrSuper || departmentIds.contains(departmentId);

  bool has(String permissionCode) => isAdminOrSuper || permissionCodes.contains(permissionCode);
}
