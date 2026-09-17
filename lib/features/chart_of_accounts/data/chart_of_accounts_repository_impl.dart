import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/result.dart';
import '../domain/repositories/chart_of_accounts_repository.dart';

class ChartOfAccountsRepositoryImpl implements ChartOfAccountsRepository {
  final AppDatabase db;
  ChartOfAccountsRepositoryImpl(this.db);

  @override
  Future<List<MainTitle>> allMainTitles() => db.chartOfAccountsDao.allMainTitles();

  @override
  Stream<List<Title>> watchTitlesForDepartment(int departmentId) =>
      db.chartOfAccountsDao.watchTitlesForDepartment(departmentId);

  @override
  Stream<List<SubTitle>> watchSubTitlesForTitle(int titleId) =>
      db.chartOfAccountsDao.watchSubTitlesForTitle(titleId);

  @override
  Stream<List<LedgerRow>> watchLedgerRowsForDepartment(int departmentId) =>
      db.chartOfAccountsDao.watchLedgerRowsForDepartment(departmentId);

  @override
  Future<Result<int>> addTitle({
    required int mainTitleId,
    required int departmentId,
    required String titleName,
    String? vfNo,
    required int createdBy,
    required bool applyAllDepartments,
  }) async {
    try {
      final dao = db.chartOfAccountsDao;
      if (!applyAllDepartments) {
        return Success(await dao.addTitle(
          mainTitleId: mainTitleId,
          departmentId: departmentId,
          titleName: titleName,
          vfNo: vfNo,
          createdBy: createdBy,
        ));
      }

      // "Apply to all departments": find/create the group by value, then
      // backfill every department that doesn't have this title yet.
      final groupId = await dao.findOrCreateTitleGroup(mainTitleId: mainTitleId, titleName: titleName, vfNo: vfNo);
      await dao.propagateTitleToAllDepartments(titleGroupId: groupId, createdBy: createdBy);
      final createdInDepartment =
          (await dao.watchTitlesForDepartment(departmentId).first).firstWhere((t) => t.titleGroupId == groupId);
      return Success(createdInDepartment.id);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<Result<int>> addSubTitle({
    required int titleId,
    required String subTitleName,
    required double openingBalance,
    required int createdBy,
    required bool applyAllDepartments,
  }) async {
    try {
      final dao = db.chartOfAccountsDao;
      if (!applyAllDepartments) {
        return Success(await dao.addSubTitle(
          titleId: titleId,
          subTitleName: subTitleName,
          openingBalance: openingBalance,
          createdBy: createdBy,
        ));
      }

      final title = await dao.titleById(titleId);
      if (title == null) {
        return const Failure(NotFoundException('Title not found.'));
      }
      // Retroactively groups the title by value if it wasn't already grouped
      // — cross-department correlation is created lazily, the first time
      // "apply to all departments" is used, on either a title or sub-title.
      final titleGroupId = title.titleGroupId ??
          await dao.findOrCreateTitleGroup(
              mainTitleId: title.mainTitleId, titleName: title.titleName, vfNo: title.vfNo);
      if (title.titleGroupId == null) {
        await dao.setTitleGroup(titleId, titleGroupId);
      }

      final subTitleGroupId = await dao.findOrCreateSubTitleGroup(titleGroupId: titleGroupId, subTitleName: subTitleName);
      final subTitleId = await dao.addSubTitle(
        titleId: titleId,
        subTitleName: subTitleName,
        openingBalance: openingBalance,
        createdBy: createdBy,
        subTitleGroupId: subTitleGroupId,
      );
      await dao.propagateSubTitleToAllDepartments(subTitleGroupId: subTitleGroupId, createdBy: createdBy);
      return Success(subTitleId);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<Result<void>> editTitle({
    required int id,
    required String titleName,
    String? vfNo,
    int? newDepartmentId,
    required bool applyAllDepartments,
    required int actingUserId,
  }) async {
    try {
      final dao = db.chartOfAccountsDao;
      await dao.updateTitleFields(id: id, titleName: titleName, vfNo: vfNo, newDepartmentId: newDepartmentId);

      if (applyAllDepartments) {
        final title = await dao.titleById(id);
        if (title != null) {
          final groupId = title.titleGroupId ??
              await dao.findOrCreateTitleGroup(mainTitleId: title.mainTitleId, titleName: titleName, vfNo: vfNo);
          if (title.titleGroupId == null) {
            await dao.setTitleGroup(id, groupId);
          }
          await dao.propagateTitleToAllDepartments(titleGroupId: groupId, createdBy: actingUserId);
        }
      }
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<Result<void>> editSubTitle({
    required int id,
    required String subTitleName,
    required bool applyAllDepartments,
    required int actingUserId,
  }) async {
    try {
      final dao = db.chartOfAccountsDao;
      await dao.updateSubTitleFields(id: id, subTitleName: subTitleName);

      if (applyAllDepartments) {
        final subTitle = await dao.subTitleById(id);
        final title = subTitle == null ? null : await dao.titleById(subTitle.titleId);
        if (subTitle != null && title != null) {
          final titleGroupId = title.titleGroupId ??
              await dao.findOrCreateTitleGroup(
                  mainTitleId: title.mainTitleId, titleName: title.titleName, vfNo: title.vfNo);
          if (title.titleGroupId == null) {
            await dao.setTitleGroup(title.id, titleGroupId);
          }
          final subTitleGroupId = subTitle.subTitleGroupId ??
              await dao.findOrCreateSubTitleGroup(titleGroupId: titleGroupId, subTitleName: subTitleName);
          if (subTitle.subTitleGroupId == null) {
            await dao.setSubTitleGroup(id, subTitleGroupId);
          }
          await dao.propagateSubTitleToAllDepartments(subTitleGroupId: subTitleGroupId, createdBy: actingUserId);
        }
      }
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<Result<void>> deleteTitle(int id) async {
    try {
      await db.chartOfAccountsDao.deleteTitle(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<Result<void>> deleteSubTitle(int id) async {
    try {
      await db.chartOfAccountsDao.deleteSubTitle(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }
}
