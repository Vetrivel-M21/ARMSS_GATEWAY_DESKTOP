import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/audit_logs_table.dart';

part 'audit_dao.g.dart';

@DriftAccessor(tables: [AuditLogs])
class AuditDao extends DatabaseAccessor<AppDatabase> with _$AuditDaoMixin {
  AuditDao(super.db);

  /// Meant to be called inside the same `transaction()` block as the write
  /// it's logging, so a failed audit insert rolls back the whole write.
  Future<void> log({
    required int userId,
    required String action,
    required String entityTable,
    int? recordId,
    String? oldValue,
    String? newValue,
  }) {
    return into(auditLogs).insert(AuditLogsCompanion.insert(
      userId: userId,
      action: action,
      entityTable: entityTable,
      recordId: Value(recordId),
      oldValue: Value(oldValue),
      newValue: Value(newValue),
    ));
  }

  Stream<List<AuditLog>> watchAll() =>
      (select(auditLogs)..orderBy([(a) => OrderingTerm.desc(a.createdAt)])).watch();
}
