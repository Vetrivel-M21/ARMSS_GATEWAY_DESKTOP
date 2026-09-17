import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../entities/report_line.dart';
import '../repositories/reports_repository.dart';

/// Export is effectively admin-only in the old app (drill-down edit/delete/
/// export on balancereport.php all require `is_admin_or_super()`), unlike
/// plain viewing which follows the normal `balance_report.view` permission.
class ExportReportUseCase {
  final ReportsRepository _repository;
  ExportReportUseCase(this._repository);

  Future<Result<List<ReportLine>>> call({
    required AppUser actor,
    required int departmentId,
    required DateTime from,
    required DateTime to,
  }) async {
    if (!actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can export reports.'));
    }
    final lines = await _repository.generateReport(departmentId: departmentId, from: from, to: to);
    return Success(lines);
  }
}
