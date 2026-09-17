import '../entities/report_line.dart';

abstract class ReportsRepository {
  Future<List<ReportLine>> generateReport({
    required int departmentId,
    required DateTime from,
    required DateTime to,
  });
}
