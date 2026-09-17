// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_dao.dart';

// ignore_for_file: type=lint
mixin _$DepartmentDaoMixin on DatabaseAccessor<AppDatabase> {
  $DepartmentsTable get departments => attachedDatabase.departments;
  $TitlesTable get titles => attachedDatabase.titles;
  $UsersTable get users => attachedDatabase.users;
  DepartmentDaoManager get managers => DepartmentDaoManager(this);
}

class DepartmentDaoManager {
  final _$DepartmentDaoMixin _db;
  DepartmentDaoManager(this._db);
  $$DepartmentsTableTableManager get departments =>
      $$DepartmentsTableTableManager(_db.attachedDatabase, _db.departments);
  $$TitlesTableTableManager get titles =>
      $$TitlesTableTableManager(_db.attachedDatabase, _db.titles);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
}
