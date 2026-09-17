import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/rbac/current_user_provider.dart';
import '../../data/permission_assignment_repository_impl.dart';
import '../../domain/repositories/permission_assignment_repository.dart';
import '../../domain/use_cases/set_user_permission_use_case.dart';

final permissionAssignmentRepositoryProvider = Provider<PermissionAssignmentRepository>((ref) {
  return PermissionAssignmentRepositoryImpl(ref.watch(appDatabaseProvider));
});

final selectableUsersProvider = FutureProvider<List<User>>((ref) {
  return ref.watch(permissionAssignmentRepositoryProvider).selectableUsers();
});

final selectedPermissionUserIdProvider = StateProvider<int?>((ref) => null);

final permissionGridProvider =
    FutureProvider.family<List<({Permission permission, bool? overrideValue})>, int>((ref, userId) {
  return ref.watch(permissionAssignmentRepositoryProvider).gridForUser(userId);
});

class PermissionAssignmentController extends Notifier<void> {
  @override
  void build() {}

  Future<void> setOverride({required int userId, required int permissionId, required bool? allow}) async {
    final actor = ref.read(currentUserProvider)!;
    final useCase = SetUserPermissionUseCase(ref.read(permissionAssignmentRepositoryProvider));
    await useCase.call(actor: actor, userId: userId, permissionId: permissionId, allow: allow);
    ref.invalidate(permissionGridProvider(userId));
  }
}

final permissionAssignmentControllerProvider =
    NotifierProvider<PermissionAssignmentController, void>(PermissionAssignmentController.new);
