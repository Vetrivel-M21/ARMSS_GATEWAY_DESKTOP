import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/providers.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../database/app_database.dart';

/// Identity only — which user id is logged in. Null means logged out. Set at
/// login, cleared at logout. Deliberately holds nothing else: permissions
/// and departments are derived reactively (see below) rather than cached
/// here, so they can't go stale.
class CurrentUserIdNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setId(int? id) => state = id;
}

final currentUserIdProvider = NotifierProvider<CurrentUserIdNotifier, int?>(CurrentUserIdNotifier.new);

/// Internal: the logged-in user's own row (name/role/active-status), watched
/// live so it re-emits if an admin edits this account mid-session.
final _currentUserRowProvider = StreamProvider<({User user, String roleName})?>((ref) {
  final id = ref.watch(currentUserIdProvider);
  if (id == null) return Stream.value(null);
  return ref.watch(appDatabaseProvider).userDao.watchByIdWithRole(id);
});

/// Internal: the logged-in user's effective permission codes, watched live —
/// this is what makes a permission grant visible without a fresh login.
final _currentUserPermissionsProvider = StreamProvider<Set<String>>((ref) {
  final id = ref.watch(currentUserIdProvider);
  final roleId = ref.watch(_currentUserRowProvider).value?.user.roleId;
  if (id == null || roleId == null) return Stream.value(const {});
  return ref.watch(appDatabaseProvider).rbacDao.watchEffectivePermissionCodes(userId: id, roleId: roleId);
});

/// Internal: the logged-in user's department assignments, watched live.
final _currentUserDepartmentIdsProvider = StreamProvider<List<int>>((ref) {
  final id = ref.watch(currentUserIdProvider);
  if (id == null) return Stream.value(const []);
  return ref.watch(appDatabaseProvider).userDao.watchDepartmentIds(id);
});

/// The current session's user, reactively recomposed from the streams above.
/// Public shape is unchanged from before this fix (`Provider<AppUser?>`), so
/// every existing `ref.watch(currentUserProvider)` / `ref.read(currentUserProvider)!`
/// call site keeps working — they now automatically see live permission and
/// department changes because the provider they already depend on is
/// reactive underneath, instead of a snapshot frozen at login time.
final currentUserProvider = Provider<AppUser?>((ref) {
  final row = ref.watch(_currentUserRowProvider).value;
  if (row == null) return null;
  return AppUser(
    id: row.user.id,
    username: row.user.username,
    fullName: row.user.fullName,
    roleId: row.user.roleId,
    roleName: row.roleName,
    departmentIds: ref.watch(_currentUserDepartmentIdsProvider).value ?? const [],
    permissionCodes: ref.watch(_currentUserPermissionsProvider).value ?? const {},
  );
});

final currentPermissionsProvider = Provider<Set<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.permissionCodes ?? const {};
});

/// Checks whether the currently logged-in local admin is still using the default password 'admin123'.
final isDefaultAdminPasswordProvider = FutureProvider<bool>((ref) async {
  final localUser = ref.watch(currentUserProvider);
  if (localUser == null || !localUser.isAdminOrSuper) return false;
  final dbUser = await ref.watch(appDatabaseProvider).userDao.byId(localUser.id);
  return dbUser?.password == 'admin123';
});
