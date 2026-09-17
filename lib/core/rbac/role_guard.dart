import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'current_user_provider.dart';

/// Route/UI-level gate. This hides/disables what a user can't use, but it is
/// NOT the security boundary — every use case re-checks permission before
/// touching the DB (see core/errors/app_exception.dart's
/// PermissionDeniedException and each feature's use cases). A hidden button
/// is not security.
class RoleGuard extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  final bool Function(String roleName)? roleCheck;
  final String? requiredPermission;

  const RoleGuard({
    super.key,
    required this.child,
    this.fallback,
    this.roleCheck,
    this.requiredPermission,
  });

  const RoleGuard.adminOnly({super.key, required this.child, this.fallback})
      : roleCheck = _isAdminOrSuper,
        requiredPermission = null;

  static bool _isAdminOrSuper(String roleName) => roleName == 'admin' || roleName == 'super_admin';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return fallback ?? const SizedBox.shrink();

    if (roleCheck != null && !roleCheck!(user.roleName)) {
      return fallback ?? const SizedBox.shrink();
    }
    if (requiredPermission != null && !user.has(requiredPermission!)) {
      return fallback ?? const SizedBox.shrink();
    }
    return child;
  }
}
