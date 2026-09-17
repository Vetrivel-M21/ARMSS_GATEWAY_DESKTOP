import 'package:drift/drift.dart';

import 'departments_table.dart';
import 'users_table.dart';

/// Meaningful only for `role = user`; admin/super_admin accounts remain
/// unrestricted regardless of rows here (empty-list-means-all semantics,
/// resolved live rather than session-cached).
class UserDepartments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  IntColumn get departmentId =>
      integer().references(Departments, #id, onDelete: KeyAction.cascade)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, departmentId},
      ];
}
