import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/rbac/current_user_provider.dart';
import '../../data/department_repository_impl.dart';
import '../../domain/repositories/department_repository.dart';
import '../../domain/use_cases/add_department_use_case.dart';
import '../../domain/use_cases/delete_department_use_case.dart';
import '../../domain/use_cases/rename_department_use_case.dart';

final departmentRepositoryProvider = Provider<DepartmentRepository>((ref) {
  return DepartmentRepositoryImpl(ref.watch(appDatabaseProvider));
});

final watchDepartmentsProvider = StreamProvider<List<Department>>((ref) {
  return ref.watch(departmentRepositoryProvider).watchAll();
});

final addDepartmentUseCaseProvider =
    Provider((ref) => AddDepartmentUseCase(ref.watch(departmentRepositoryProvider)));
final renameDepartmentUseCaseProvider =
    Provider((ref) => RenameDepartmentUseCase(ref.watch(departmentRepositoryProvider)));
final deleteDepartmentUseCaseProvider =
    Provider((ref) => DeleteDepartmentUseCase(ref.watch(departmentRepositoryProvider)));

class DepartmentActionsController extends Notifier<AppException?> {
  @override
  AppException? build() => null;

  Future<bool> add(String name) async {
    final actor = ref.read(currentUserProvider)!;
    final result = await ref.read(addDepartmentUseCaseProvider).call(actor: actor, name: name);
    state = result.errorOrNull;
    return result.isSuccess;
  }

  Future<bool> rename(int id, String name) async {
    final actor = ref.read(currentUserProvider)!;
    final result = await ref.read(renameDepartmentUseCaseProvider).call(actor: actor, id: id, name: name);
    state = result.errorOrNull;
    return result.isSuccess;
  }

  Future<bool> delete(int id) async {
    final actor = ref.read(currentUserProvider)!;
    final result = await ref.read(deleteDepartmentUseCaseProvider).call(actor: actor, id: id);
    state = result.errorOrNull;
    return result.isSuccess;
  }
}

final departmentActionsControllerProvider =
    NotifierProvider<DepartmentActionsController, AppException?>(DepartmentActionsController.new);
