import '../../../../core/database/app_database.dart';
import '../../../../core/errors/result.dart';

abstract class DepartmentRepository {
  Stream<List<Department>> watchAll();
  Future<Result<int>> add(String name);
  Future<Result<void>> rename(int id, String name);
  Future<Result<void>> delete(int id);
}
