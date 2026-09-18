class PortalSession {
  final int? userId;
  final String token;
  final String username;
  final String email;
  final String fullName;
  final String department;
  final String branch;
  final String role;
  final List<String> grantedLinkKeys;

  bool get isAdmin =>
      role.trim().toLowerCase() == 'admin' ||
      username.trim().toLowerCase() == 'admin';

  const PortalSession({
    this.userId,
    required this.token,
    required this.username,
    required this.email,
    required this.fullName,
    required this.department,
    required this.branch,
    this.role = 'user',
    required this.grantedLinkKeys,
  });
}
