import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared_widgets/ledger_table.dart';
import '../../../shared_widgets/page_header.dart';
import '../data/audit_repository_impl.dart';
import '../domain/repositories/audit_repository.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepositoryImpl(ref.watch(appDatabaseProvider));
});

final watchAuditLogsProvider = StreamProvider<List<AuditLog>>((ref) {
  return ref.watch(auditRepositoryProvider).watchAll();
});

/// Admin-only, net-new capability vs. the old app (which had no audit trail
/// at all) — currently populated by ledger-affecting writes (save/edit/
/// delete entries, day close).
class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(watchAuditLogsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(title: 'Audit Log', icon: Icons.history, accentColor: Color(0xFF64748B)),
        Expanded(
          child: logsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (logs) {
              if (logs.isEmpty) return const Center(child: Text('No audit entries yet.'));
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LedgerTable(
                  columns: const [
                    LedgerColumn('Time', width: FixedColumnWidth(140)),
                    LedgerColumn('Action', width: FixedColumnWidth(120)),
                    LedgerColumn('Table', width: FixedColumnWidth(140)),
                    LedgerColumn('Detail'),
                  ],
                  rows: [
                    for (final log in logs)
                      TableRow(
                        children: [
                          LedgerCell(
                            child: Text(AppDateUtils.format(log.createdAt),
                                style: AppTextStyles.monoWith(fontSize: 12, color: AppColors.inkSecondary)),
                          ),
                          LedgerCell(child: Text(log.action, style: const TextStyle(fontWeight: FontWeight.w500))),
                          LedgerCell(child: Text(log.entityTable)),
                          LedgerCell(
                            child: Text(
                              [
                                if (log.recordId != null) 'record #${log.recordId}',
                                if (log.oldValue != null) 'old: ${log.oldValue}',
                                if (log.newValue != null) 'new: ${log.newValue}',
                              ].join('  '),
                              style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
