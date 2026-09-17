// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_of_accounts_dao.dart';

// ignore_for_file: type=lint
mixin _$ChartOfAccountsDaoMixin on DatabaseAccessor<AppDatabase> {
  $MainTitlesTable get mainTitles => attachedDatabase.mainTitles;
  $TitleGroupsTable get titleGroups => attachedDatabase.titleGroups;
  $TitlesTable get titles => attachedDatabase.titles;
  $SubTitleGroupsTable get subTitleGroups => attachedDatabase.subTitleGroups;
  $SubTitlesTable get subTitles => attachedDatabase.subTitles;
  $DepartmentsTable get departments => attachedDatabase.departments;
  ChartOfAccountsDaoManager get managers => ChartOfAccountsDaoManager(this);
}

class ChartOfAccountsDaoManager {
  final _$ChartOfAccountsDaoMixin _db;
  ChartOfAccountsDaoManager(this._db);
  $$MainTitlesTableTableManager get mainTitles =>
      $$MainTitlesTableTableManager(_db.attachedDatabase, _db.mainTitles);
  $$TitleGroupsTableTableManager get titleGroups =>
      $$TitleGroupsTableTableManager(_db.attachedDatabase, _db.titleGroups);
  $$TitlesTableTableManager get titles =>
      $$TitlesTableTableManager(_db.attachedDatabase, _db.titles);
  $$SubTitleGroupsTableTableManager get subTitleGroups =>
      $$SubTitleGroupsTableTableManager(
        _db.attachedDatabase,
        _db.subTitleGroups,
      );
  $$SubTitlesTableTableManager get subTitles =>
      $$SubTitlesTableTableManager(_db.attachedDatabase, _db.subTitles);
  $$DepartmentsTableTableManager get departments =>
      $$DepartmentsTableTableManager(_db.attachedDatabase, _db.departments);
}
