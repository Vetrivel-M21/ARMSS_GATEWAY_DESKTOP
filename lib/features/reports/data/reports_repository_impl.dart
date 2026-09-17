import '../../../core/database/app_database.dart';
import '../domain/entities/report_line.dart';
import '../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final AppDatabase db;
  ReportsRepositoryImpl(this.db);

  @override
  Future<List<ReportLine>> generateReport({
    required int departmentId,
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await db.chartOfAccountsDao.reportRowsForDepartment(departmentId);
    final lines = <ReportLine>[];
    for (final row in rows) {
      final netBefore = await db.transactionDao.netBefore(subTitleId: row.subTitle.id, fromDate: from);
      final period = await db.transactionDao.periodTotals(subTitleId: row.subTitle.id, from: from, to: to);
      lines.add(ReportLine(
        subTitleId: row.subTitle.id,
        subTitleName: row.subTitle.subTitleName,
        titleId: row.titleId,
        titleName: row.titleName,
        vfNo: row.vfNo,
        mainTitleName: row.mainTitleName,
        openingCarry: row.subTitle.openingBalance + netBefore,
        periodDebit: period.debit,
        periodCredit: period.credit,
      ));
    }
    return lines;
  }
}
