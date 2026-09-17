class AdminPortalUser {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String department;
  final String branch;
  final String role;
  final bool isActive;
  final List<String> grantedLinkKeys;

  bool get isAdmin =>
      role.trim().toLowerCase() == 'admin' ||
      username.trim().toLowerCase() == 'admin';

  const AdminPortalUser({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.department,
    required this.branch,
    this.role = 'user',
    required this.isActive,
    required this.grantedLinkKeys,
  });
}
