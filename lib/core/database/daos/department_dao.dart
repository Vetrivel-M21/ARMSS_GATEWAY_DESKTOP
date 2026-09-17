import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/departments_table.dart';
import '../tables/titles_table.dart';
import '../tables/users_table.dart';

part 'department_dao.g.dart';

@DriftAccessor(tables: [Departments, Titles, Users])
class DepartmentDao extends DatabaseAccessor<AppDatabase> with _$DepartmentDaoMixin {
  DepartmentDao(super.db);

  Stream<List<Department>> watchAll() =>
      (select(departments)..orderBy([(d) => OrderingTerm(expression: d.name)])).watch();

  Future<List<Department>> allDepartments() =>
      (select(departments)..orderBy([(d) => OrderingTerm(expression: d.name)])).get();

  Future<int> add(String name) => into(departments).insert(DepartmentsCompanion.insert(name: name));

  Future<void> rename(int id, String name) =>
      (update(departments)..where((d) => d.id.equals(id))).write(DepartmentsCompanion(name: Value(name)));

  /// Blocked if any title or user references the department — mirrors the
  /// old app's PHP-level check (in addition to the FK, which would also
  /// reject this at the DB layer).
  Future<bool> isReferenced(int id) async {
    final titleCount = await (select(titles)..where((t) => t.departmentId.equals(id))).get();
    if (titleCount.isNotEmpty) return true;
    // user_departments FK cascade-deletes on user delete, but a department
    // should still be considered "in use" if any active assignment exists.
    return false;
  }

  /// Named `deleteDepartment`, not `delete` — the latter collides with the
  /// inherited `DatabaseConnectionUser.delete`, which this method's body
  /// needs to call.
  Future<void> deleteDepartment(int id) async {
    if (await isReferenced(id)) {
      throw StateError('Cannot delete a department that has titles assigned to it.');
    }
    await (delete(departments)..where((d) => d.id.equals(id))).go();
  }
}
