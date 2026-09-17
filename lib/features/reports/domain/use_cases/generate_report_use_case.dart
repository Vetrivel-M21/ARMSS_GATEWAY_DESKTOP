import '../../../../core/constants/permission_keys.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../entities/report_line.dart';
import '../repositories/reports_repository.dart';

class GenerateReportUseCase {
  final ReportsRepository _repository;
  GenerateReportUseCase(this._repository);

  Future<Result<List<ReportLine>>> call({
    required AppUser actor,
    required int departmentId,
    required DateTime from,
    required DateTime to,
  }) async {
    if (!actor.has(PermissionCode.balanceReportView)) {
      return const Failure(PermissionDeniedException('You do not have permission to view reports.'));
    }
    if (!actor.canAccessDepartment(departmentId)) {
      return const Failure(PermissionDeniedException('You do not have access to this department.'));
    }
    final lines = await _repository.generateReport(departmentId: departmentId, from: from, to: to);
    return Success(lines);
  }
}
