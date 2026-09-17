import '../../../../core/database/app_database.dart';
import '../../../../core/errors/result.dart';

/// One sub-title with its title and main-title (category) names attached —
/// what both the Transaction Entry grid and the Report groups/rolls up.
typedef LedgerRow = ({SubTitle subTitle, int titleId, String titleName, String? vfNo, int mainTitleId, String mainTitleName});

abstract class ChartOfAccountsRepository {
  Future<List<MainTitle>> allMainTitles();
  Stream<List<Title>> watchTitlesForDepartment(int departmentId);
  Stream<List<SubTitle>> watchSubTitlesForTitle(int titleId);
  Stream<List<LedgerRow>> watchLedgerRowsForDepartment(int departmentId);

  Future<Result<int>> addTitle({
    required int mainTitleId,
    required int departmentId,
    required String titleName,
    String? vfNo,
    required int createdBy,
    required bool applyAllDepartments,
  });

  Future<Result<int>> addSubTitle({
    required int titleId,
    required String subTitleName,
    required double openingBalance,
    required int createdBy,
    required bool applyAllDepartments,
  });

  Future<Result<void>> editTitle({
    required int id,
    required String titleName,
    String? vfNo,
    int? newDepartmentId,
    required bool applyAllDepartments,
    required int actingUserId,
  });

  Future<Result<void>> editSubTitle({
    required int id,
    required String subTitleName,
    required bool applyAllDepartments,
    required int actingUserId,
  });

  Future<Result<void>> deleteTitle(int id);
  Future<Result<void>> deleteSubTitle(int id);
}
