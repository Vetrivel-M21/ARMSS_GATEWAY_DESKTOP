import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/departments_table.dart';
import '../tables/main_titles_table.dart';
import '../tables/sub_title_groups_table.dart';
import '../tables/sub_titles_table.dart';
import '../tables/title_groups_table.dart';
import '../tables/titles_table.dart';

part 'chart_of_accounts_dao.g.dart';

@DriftAccessor(tables: [MainTitles, TitleGroups, Titles, SubTitleGroups, SubTitles, Departments])
class ChartOfAccountsDao extends DatabaseAccessor<AppDatabase> with _$ChartOfAccountsDaoMixin {
  ChartOfAccountsDao(super.db);

  Future<List<MainTitle>> allMainTitles() => select(mainTitles).get();

  Stream<List<Title>> watchTitlesForDepartment(int departmentId) =>
      (select(titles)..where((t) => t.departmentId.equals(departmentId))).watch();

  Future<Title?> titleById(int id) => (select(titles)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<SubTitle?> subTitleById(int id) => (select(subTitles)..where((s) => s.id.equals(id))).getSingleOrNull();

  Stream<List<SubTitle>> watchSubTitlesForTitle(int titleId) =>
      (select(subTitles)..where((s) => s.titleId.equals(titleId))).watch();

  Future<List<SubTitle>> subTitlesForTitle(int titleId) =>
      (select(subTitles)..where((s) => s.titleId.equals(titleId))).get();

  /// Every sub-title in a department with its title and main-title (4 fixed
  /// category) names attached — what the transaction-entry grid groups by
  /// Category -> Title -> Sub-title, mirroring the old app's collapsible tree.
  Stream<List<({SubTitle subTitle, int titleId, String titleName, String? vfNo, int mainTitleId, String mainTitleName})>>
      watchLedgerRowsForDepartment(int departmentId) {
    final query = select(subTitles).join([
      innerJoin(titles, titles.id.equalsExp(subTitles.titleId)),
      innerJoin(mainTitles, mainTitles.id.equalsExp(titles.mainTitleId)),
    ])
      ..where(titles.departmentId.equals(departmentId));
    return query.watch().map((rows) => rows
        .map((r) => (
              subTitle: r.readTable(subTitles),
              titleId: r.readTable(titles).id,
              titleName: r.readTable(titles).titleName,
              vfNo: r.readTable(titles).vfNo,
              mainTitleId: r.readTable(mainTitles).id,
              mainTitleName: r.readTable(mainTitles).name,
            ))
        .toList());
  }

  /// Same shape/join as [watchLedgerRowsForDepartment], fetched once — used
  /// by the report, which recomputes on filter change rather than watching.
  Future<List<({SubTitle subTitle, int titleId, String titleName, String? vfNo, int mainTitleId, String mainTitleName})>>
      reportRowsForDepartment(int departmentId) async {
    final query = select(subTitles).join([
      innerJoin(titles, titles.id.equalsExp(subTitles.titleId)),
      innerJoin(mainTitles, mainTitles.id.equalsExp(titles.mainTitleId)),
    ])
      ..where(titles.departmentId.equals(departmentId));
    final rows = await query.get();
    return rows
        .map((r) => (
              subTitle: r.readTable(subTitles),
              titleId: r.readTable(titles).id,
              titleName: r.readTable(titles).titleName,
              vfNo: r.readTable(titles).vfNo,
              mainTitleId: r.readTable(mainTitles).id,
              mainTitleName: r.readTable(mainTitles).name,
            ))
        .toList();
  }

  /// Finds an existing group by value `(mainTitleId, titleName, vfNo)` before
  /// creating a new one — reproduces the old app's by-value correlation as
  /// the discovery path, while giving "apply to all departments" a durable
  /// FK to propagate through afterward.
  Future<int> findOrCreateTitleGroup({
    required int mainTitleId,
    required String titleName,
    String? vfNo,
  }) async {
    final existing = await (select(titleGroups)
          ..where((g) =>
              g.mainTitleId.equals(mainTitleId) &
              g.titleName.equals(titleName) &
              (vfNo == null ? g.vfNo.isNull() : g.vfNo.equals(vfNo))))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return into(titleGroups)
        .insert(TitleGroupsCompanion.insert(mainTitleId: mainTitleId, titleName: titleName, vfNo: Value(vfNo)));
  }

  Future<int> findOrCreateSubTitleGroup({required int titleGroupId, required String subTitleName}) async {
    final existing = await (select(subTitleGroups)
          ..where((g) => g.titleGroupId.equals(titleGroupId) & g.subTitleName.equals(subTitleName)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return into(subTitleGroups)
        .insert(SubTitleGroupsCompanion.insert(titleGroupId: titleGroupId, subTitleName: subTitleName));
  }

  Future<int> addTitle({
    required int mainTitleId,
    required int departmentId,
    required String titleName,
    String? vfNo,
    required int createdBy,
    int? titleGroupId,
  }) {
    return into(titles).insert(TitlesCompanion.insert(
      mainTitleId: mainTitleId,
      departmentId: departmentId,
      titleName: titleName,
      vfNo: Value(vfNo),
      createdBy: createdBy,
      titleGroupId: Value(titleGroupId),
    ));
  }

  Future<int> addSubTitle({
    required int titleId,
    required String subTitleName,
    required double openingBalance,
    required int createdBy,
    int? subTitleGroupId,
  }) {
    return into(subTitles).insert(SubTitlesCompanion.insert(
      titleId: titleId,
      subTitleName: subTitleName,
      openingBalance: Value(openingBalance),
      createdBy: createdBy,
      subTitleGroupId: Value(subTitleGroupId),
    ));
  }

  /// Backfills the title into every department lacking a row for this group,
  /// and updates name/vf_no on every existing row to match the group — same
  /// "create missing + update existing" behavior as the old app's edit_title.
  Future<void> propagateTitleToAllDepartments({
    required int titleGroupId,
    required int createdBy,
  }) async {
    final group = await (select(titleGroups)..where((g) => g.id.equals(titleGroupId))).getSingle();
    final allDepartments = await select(departments).get();
    final existingTitles =
        await (select(titles)..where((t) => t.titleGroupId.equals(titleGroupId))).get();
    final existingByDept = {for (final t in existingTitles) t.departmentId: t};

    await transaction(() async {
      for (final dept in allDepartments) {
        final existing = existingByDept[dept.id];
        if (existing == null) {
          await addTitle(
            mainTitleId: group.mainTitleId,
            departmentId: dept.id,
            titleName: group.titleName,
            vfNo: group.vfNo,
            createdBy: createdBy,
            titleGroupId: titleGroupId,
          );
        } else if (existing.titleName != group.titleName || existing.vfNo != group.vfNo) {
          await (update(titles)..where((t) => t.id.equals(existing.id))).write(
            TitlesCompanion(titleName: Value(group.titleName), vfNo: Value(group.vfNo), updatedAt: Value(DateTime.now())),
          );
        }
      }
    });
  }

  Future<void> propagateSubTitleToAllDepartments({
    required int subTitleGroupId,
    required int createdBy,
  }) async {
    final group = await (select(subTitleGroups)..where((g) => g.id.equals(subTitleGroupId))).getSingle();
    final linkedTitles = await (select(titles)..where((t) => t.titleGroupId.equals(group.titleGroupId))).get();
    final existingSubTitles =
        await (select(subTitles)..where((s) => s.subTitleGroupId.equals(subTitleGroupId))).get();
    final existingByTitleId = {for (final s in existingSubTitles) s.titleId: s};

    await transaction(() async {
      for (final title in linkedTitles) {
        final existing = existingByTitleId[title.id];
        if (existing == null) {
          await addSubTitle(
            titleId: title.id,
            subTitleName: group.subTitleName,
            openingBalance: 0,
            createdBy: createdBy,
            subTitleGroupId: subTitleGroupId,
          );
        } else if (existing.subTitleName != group.subTitleName) {
          await (update(subTitles)..where((s) => s.id.equals(existing.id))).write(
            SubTitlesCompanion(subTitleName: Value(group.subTitleName), updatedAt: Value(DateTime.now())),
          );
        }
      }
    });
  }

  Future<void> updateTitleFields({
    required int id,
    required String titleName,
    String? vfNo,
    int? newDepartmentId,
  }) {
    return (update(titles)..where((t) => t.id.equals(id))).write(TitlesCompanion(
      titleName: Value(titleName),
      vfNo: Value(vfNo),
      departmentId: newDepartmentId != null ? Value(newDepartmentId) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateSubTitleFields({required int id, required String subTitleName}) {
    return (update(subTitles)..where((s) => s.id.equals(id)))
        .write(SubTitlesCompanion(subTitleName: Value(subTitleName), updatedAt: Value(DateTime.now())));
  }

  Future<void> setTitleGroup(int titleId, int titleGroupId) =>
      (update(titles)..where((t) => t.id.equals(titleId))).write(TitlesCompanion(titleGroupId: Value(titleGroupId)));

  Future<void> setSubTitleGroup(int subTitleId, int subTitleGroupId) =>
      (update(subTitles)..where((s) => s.id.equals(subTitleId)))
          .write(SubTitlesCompanion(subTitleGroupId: Value(subTitleGroupId)));

  Future<void> deleteTitle(int id) => (delete(titles)..where((t) => t.id.equals(id))).go();

  Future<void> deleteSubTitle(int id) => (delete(subTitles)..where((s) => s.id.equals(id))).go();
}
