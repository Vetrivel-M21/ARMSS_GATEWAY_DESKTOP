import '../../../../core/database/app_database.dart';

abstract class AuditRepository {
  Stream<List<AuditLog>> watchAll();
}
