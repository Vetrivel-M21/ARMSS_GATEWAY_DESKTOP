import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/rbac/current_user_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/reports_repository_impl.dart';
import '../../domain/entities/report_line.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/use_cases/export_report_use_case.dart';
import '../../domain/use_cases/generate_report_use_case.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepositoryImpl(ref.watch(appDatabaseProvider));
});

enum ReportFilterMode { financialYear, month, custom }

class ReportFilter {
  final ReportFilterMode mode;
  final DateTime from;
  final DateTime to;
  const ReportFilter({required this.mode, required this.from, required this.to});

  factory ReportFilter.defaultFilter() {
    final fy = AppDateUtils.financialYearContaining(DateTime.now());
    return ReportFilter(mode: ReportFilterMode.financialYear, from: fy.start, to: fy.end);
  }
}

final selectedReportDepartmentIdProvider = StateProvider<int?>((ref) => null);
final reportFilterProvider = StateProvider<ReportFilter>((ref) => ReportFilter.defaultFilter());

final reportProvider =
    FutureProvider.family<List<ReportLine>, ({int departmentId, DateTime from, DateTime to})>((ref, key) async {
  final actor = ref.watch(currentUserProvider)!;
  final useCase = GenerateReportUseCase(ref.watch(reportsRepositoryProvider));
  final result = await useCase.call(actor: actor, departmentId: key.departmentId, from: key.from, to: key.to);
  return result.fold((lines) => lines, (error) => throw error);
});

final exportReportUseCaseProvider = Provider((ref) => ExportReportUseCase(ref.watch(reportsRepositoryProvider)));
