import '../../../core/database/app_database.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/result.dart';
import '../domain/repositories/department_repository.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final AppDatabase db;
  DepartmentRepositoryImpl(this.db);

  @override
  Stream<List<Department>> watchAll() => db.departmentDao.watchAll();

  @override
  Future<Result<int>> add(String name) async {
    try {
      return Success(await db.departmentDao.add(name));
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<Result<void>> rename(int id, String name) async {
    try {
      await db.departmentDao.rename(id, name);
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<Result<void>> delete(int id) async {
    try {
      await db.departmentDao.deleteDepartment(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }
}
