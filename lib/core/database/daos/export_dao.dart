import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/export_password_history_table.dart';

part 'export_dao.g.dart';

@DriftAccessor(tables: [ExportPasswordHistory])
class ExportDao extends DatabaseAccessor<AppDatabase> with _$ExportDaoMixin {
  ExportDao(super.db);

  Future<void> logExport({
    required int userId,
    required String exportType,
    required String exportPassword,
    required DateTime fromDate,
    DateTime? toDate,
    int? departmentId,
  }) {
    return into(exportPasswordHistory).insert(ExportPasswordHistoryCompanion.insert(
      userId: userId,
      exportType: exportType,
      exportPassword: exportPassword,
      fromDate: fromDate,
      toDate: Value(toDate),
      departmentId: Value(departmentId),
    ));
  }

  Stream<List<ExportPasswordHistoryData>> watchByType(String exportType) {
    return (select(exportPasswordHistory)
          ..where((e) => e.exportType.equals(exportType))
          ..orderBy([(e) => OrderingTerm.desc(e.downloadedAt)]))
        .watch();
  }
}
