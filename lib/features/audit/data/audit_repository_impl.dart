import '../../../core/database/app_database.dart';
import '../domain/repositories/audit_repository.dart';

class AuditRepositoryImpl implements AuditRepository {
  final AppDatabase db;
  AuditRepositoryImpl(this.db);

  @override
  Stream<List<AuditLog>> watchAll() => db.auditDao.watchAll();
}
