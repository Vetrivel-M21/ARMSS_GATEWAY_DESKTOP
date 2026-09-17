// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dao.dart';

// ignore_for_file: type=lint
mixin _$UserDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $UserDepartmentsTable get userDepartments => attachedDatabase.userDepartments;
  $RolesTable get roles => attachedDatabase.roles;
  UserDaoManager get managers => UserDaoManager(this);
}

class UserDaoManager {
  final _$UserDaoMixin _db;
  UserDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$UserDepartmentsTableTableManager get userDepartments =>
      $$UserDepartmentsTableTableManager(
        _db.attachedDatabase,
        _db.userDepartments,
      );
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db.attachedDatabase, _db.roles);
}
