import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/rbac/current_user_provider.dart';
import '../../data/chart_of_accounts_repository_impl.dart';
import '../../domain/repositories/chart_of_accounts_repository.dart';
import '../../domain/use_cases/add_sub_title_use_case.dart';
import '../../domain/use_cases/add_title_use_case.dart';
import '../../domain/use_cases/delete_sub_title_use_case.dart';
import '../../domain/use_cases/delete_title_use_case.dart';
import '../../domain/use_cases/edit_sub_title_use_case.dart';
import '../../domain/use_cases/edit_title_use_case.dart';

final chartOfAccountsRepositoryProvider = Provider<ChartOfAccountsRepository>((ref) {
  return ChartOfAccountsRepositoryImpl(ref.watch(appDatabaseProvider));
});

final allMainTitlesProvider = FutureProvider<List<MainTitle>>((ref) {
  return ref.watch(chartOfAccountsRepositoryProvider).allMainTitles();
});

final selectedTitleDepartmentIdProvider = StateProvider<int?>((ref) => null);

final watchTitlesForDepartmentProvider = StreamProvider.family<List<Title>, int>((ref, departmentId) {
  return ref.watch(chartOfAccountsRepositoryProvider).watchTitlesForDepartment(departmentId);
});

final watchSubTitlesForTitleProvider = StreamProvider.family<List<SubTitle>, int>((ref, titleId) {
  return ref.watch(chartOfAccountsRepositoryProvider).watchSubTitlesForTitle(titleId);
});

final watchLedgerRowsForDepartmentProvider = StreamProvider.family<List<LedgerRow>, int>((ref, departmentId) {
  return ref.watch(chartOfAccountsRepositoryProvider).watchLedgerRowsForDepartment(departmentId);
});

class ChartOfAccountsActionsController extends Notifier<AppException?> {
  @override
  AppException? build() => null;

  Future<bool> addTitle({
    required int mainTitleId,
    required int departmentId,
    required String titleName,
    String? vfNo,
    bool applyAllDepartments = false,
  }) async {
    final actor = ref.read(currentUserProvider)!;
    final useCase = AddTitleUseCase(ref.read(chartOfAccountsRepositoryProvider));
    final result = await useCase.call(
      actor: actor,
      mainTitleId: mainTitleId,
      departmentId: departmentId,
      titleName: titleName,
      vfNo: vfNo,
      applyAllDepartments: applyAllDepartments,
    );
    state = result.errorOrNull;
    return result.isSuccess;
  }

  Future<bool> addSubTitle({
    required int titleId,
    required String subTitleName,
    required double openingBalance,
    bool applyAllDepartments = false,
  }) async {
    final actor = ref.read(currentUserProvider)!;
    final useCase = AddSubTitleUseCase(ref.read(chartOfAccountsRepositoryProvider));
    final result = await useCase.call(
      actor: actor,
      titleId: titleId,
      subTitleName: subTitleName,
      openingBalance: openingBalance,
      applyAllDepartments: applyAllDepartments,
    );
    state = result.errorOrNull;
    return result.isSuccess;
  }

  Future<bool> editTitle({
    required int id,
    required String titleName,
    String? vfNo,
    bool applyAllDepartments = false,
  }) async {
    final actor = ref.read(currentUserProvider)!;
    final useCase = EditTitleUseCase(ref.read(chartOfAccountsRepositoryProvider));
    final result = await useCase.call(
      actor: actor,
      id: id,
      titleName: titleName,
      vfNo: vfNo,
      applyAllDepartments: applyAllDepartments,
    );
    state = result.errorOrNull;
    return result.isSuccess;
  }

  Future<bool> editSubTitle({required int id, required String subTitleName, bool applyAllDepartments = false}) async {
    final actor = ref.read(currentUserProvider)!;
    final useCase = EditSubTitleUseCase(ref.read(chartOfAccountsRepositoryProvider));
    final result =
        await useCase.call(actor: actor, id: id, subTitleName: subTitleName, applyAllDepartments: applyAllDepartments);
    state = result.errorOrNull;
    return result.isSuccess;
  }

  Future<bool> deleteTitle(int id) async {
    final actor = ref.read(currentUserProvider)!;
    final result = await DeleteTitleUseCase(ref.read(chartOfAccountsRepositoryProvider)).call(actor: actor, id: id);
    state = result.errorOrNull;
    return result.isSuccess;
  }

  Future<bool> deleteSubTitle(int id) async {
    final actor = ref.read(currentUserProvider)!;
    final result = await DeleteSubTitleUseCase(ref.read(chartOfAccountsRepositoryProvider)).call(actor: actor, id: id);
    state = result.errorOrNull;
    return result.isSuccess;
  }
}

final chartOfAccountsActionsControllerProvider =
    NotifierProvider<ChartOfAccountsActionsController, AppException?>(ChartOfAccountsActionsController.new);
