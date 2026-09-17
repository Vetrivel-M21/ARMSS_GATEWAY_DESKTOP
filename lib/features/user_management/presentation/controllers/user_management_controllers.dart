import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/rbac/current_user_provider.dart';
import '../../data/user_management_repository_impl.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../../domain/use_cases/create_user_use_case.dart';
import '../../domain/use_cases/reset_password_use_case.dart';
import '../../domain/use_cases/toggle_active_use_case.dart';
import '../../domain/use_cases/update_user_use_case.dart';

final userManagementRepositoryProvider = Provider<UserManagementRepository>((ref) {
  return UserManagementRepositoryImpl(ref.watch(appDatabaseProvider));
});

final watchUsersProvider = StreamProvider<List<User>>((ref) {
  return ref.watch(userManagementRepositoryProvider).watchAll();
});

final allRolesProvider = FutureProvider<List<Role>>((ref) {
  return ref.watch(userManagementRepositoryProvider).allRoles();
});

final userDepartmentIdsProvider = FutureProvider.family<List<int>, int>((ref, userId) {
  return ref.watch(userManagementRepositoryProvider).departmentIdsFor(userId);
});

class UserActionsController extends Notifier<AppException?> {
  @override
  AppException? build() => null;

  Future<bool> create({
    required String username,
    required String password,
    required String fullName,
    required int roleId,
    required String roleName,
    required List<int> departmentIds,
  }) async {
    final actor = ref.read(currentUserProvider)!;
    final useCase = CreateUserUseCase(ref.read(userManagementRepositoryProvider));
    final result = await useCase.call(
      actor: actor,
      username: username,
      password: password,
      fullName: fullName,
      roleId: roleId,
      roleName: roleName,
      departmentIds: departmentIds,
    );
    state = result.errorOrNull;
    return result.isSuccess;
  }

  Future<bool> update({
    required int id,
    required String username,
    required String fullName,
    required int roleId,
    required String roleName,
    required List<int> departmentIds,
  }) async {
    final actor = ref.read(currentUserProvider)!;
    final useCase = UpdateUserUseCase(ref.read(userManagementRepositoryProvider));
    final result = await useCase.call(
      actor: actor,
      id: id,
      username: username,
      fullName: fullName,
      roleId: roleId,
      roleName: roleName,
      departmentIds: departmentIds,
    );
    state = result.errorOrNull;
    return result.isSuccess;
  }

  Future<bool> resetPassword(int id, String newPassword) async {
    final actor = ref.read(currentUserProvider)!;
    final useCase = ResetPasswordUseCase(ref.read(userManagementRepositoryProvider));
    final result = await useCase.call(actor: actor, id: id, newPassword: newPassword);
    state = result.errorOrNull;
    return result.isSuccess;
  }

  Future<bool> toggleActive(int id) async {
    final actor = ref.read(currentUserProvider)!;
    final useCase = ToggleActiveUseCase(ref.read(userManagementRepositoryProvider));
    final result = await useCase.call(actor: actor, id: id);
    state = result.errorOrNull;
    return result.isSuccess;
  }
}

final userActionsControllerProvider = NotifierProvider<UserActionsController, AppException?>(UserActionsController.new);
