import 'dart:io';

import 'package:flutter/material.dart' hide Title;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../../../core/rbac/current_user_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared_widgets/amount_text.dart';
import '../../../../shared_widgets/compact_icon_button.dart';
import '../../../../shared_widgets/confirm_dialog.dart';
import '../../../../shared_widgets/gradient_filled_button.dart';
import '../../../../shared_widgets/labeled_dropdown.dart';
import '../../../../shared_widgets/ledger_table.dart';
import '../../../../shared_widgets/page_header.dart';
import '../../../chart_of_accounts/presentation/controllers/chart_of_accounts_controllers.dart';
import '../../../departments/presentation/controllers/department_controllers.dart';
import '../../../transactions/presentation/controllers/transaction_controllers.dart';
import '../../data/export/excel_report_exporter.dart';
import '../../data/export/pdf_report_exporter.dart';
import '../../domain/entities/report_line.dart';
import '../controllers/reports_controllers.dart';

/// Rebuilt to match `balancereport.php`'s actual structure: one ledger table
/// with group/title/sub-title/entry rows (click-to-expand at each level) and
/// a running per-entry closing balance, instead of the previous
/// `ExpansionTile`-card layout. See the plan for the full old-app fidelity
/// analysis this was built from, including the deliberate Opening+Debit-
/// Credit sign convention (`ReportLine.closing`) that differs from
/// Transaction Entry's Opening+Credit-Debit.
class BalanceReportScreen extends ConsumerWidget {
  const BalanceReportScreen({super.key});

  Future<void> _exportPdf(BuildContext context, WidgetRef ref, int departmentId, String departmentName, ReportFilter filter) async {
    final actor = ref.read(currentUserProvider)!;
    final result = await ref.read(exportReportUseCaseProvider).call(actor: actor, departmentId: departmentId, from: filter.from, to: filter.to);
    if (result.isFailure) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.errorOrNull!.message)));
      return;
    }
    final bytes = await PdfReportExporter().build(departmentName: departmentName, from: filter.from, to: filter.to, lines: result.valueOrNull!);
    await Printing.sharePdf(bytes: bytes, filename: 'balance_report_$departmentName.pdf');
  }

  Future<void> _exportExcel(BuildContext context, WidgetRef ref, int departmentId, String departmentName, ReportFilter filter) async {
    final actor = ref.read(currentUserProvider)!;
    final result = await ref.read(exportReportUseCaseProvider).call(actor: actor, departmentId: departmentId, from: filter.from, to: filter.to);
    if (result.isFailure) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.errorOrNull!.message)));
      return;
    }
    final bytes = ExcelReportExporter().build(departmentName: departmentName, from: filter.from, to: filter.to, lines: result.valueOrNull!);
    final dir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory(p.join(dir.path, 'ARMSS Gateway Exports'));
    if (!await exportsDir.exists()) await exportsDir.create(recursive: true);
    final file = File(p.join(exportsDir.path, 'balance_report_$departmentName.xlsx'));
    await file.writeAsBytes(bytes);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to ${file.path}')));
  }

  Future<void> _print(int departmentId, String departmentName, ReportFilter filter, List<ReportLine> lines) async {
    final bytes = await PdfReportExporter().build(departmentName: departmentName, from: filter.from, to: filter.to, lines: lines);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider)!;
    final departmentsAsync = ref.watch(watchDepartmentsProvider);
    final selectedDeptId = ref.watch(selectedReportDepartmentIdProvider);
    final filter = ref.watch(reportFilterProvider);

    return departmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allDepartments) {
        final visible = user.isAdminOrSuper ? allDepartments : allDepartments.where((d) => user.departmentIds.contains(d.id)).toList();
        if (visible.isEmpty) {
          return const Column(children: [
            PageHeader(title: 'Balance Report', icon: Icons.summarize_outlined, accentColor: Color(0xFF16A34A)),
            Expanded(child: Center(child: Text('No accessible departments.'))),
          ]);
        }
        final deptId = (selectedDeptId != null && visible.any((d) => d.id == selectedDeptId)) ? selectedDeptId : visible.first.id;
        final deptName = visible.firstWhere((d) => d.id == deptId).name;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Balance Report',
              icon: Icons.summarize_outlined,
              accentColor: const Color(0xFF16A34A),
              actions: [
                if (user.isAdminOrSuper) ...[
                  GradientFilledButton(
                    onPressed: () => _exportPdf(context, ref, deptId, deptName, filter),
                    icon: Icons.picture_as_pdf_outlined,
                    child: const Text('Export PDF'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GradientFilledButton(
                    onPressed: () => _exportExcel(context, ref, deptId, deptName, filter),
                    icon: Icons.table_chart_outlined,
                    child: const Text('Export Excel'),
                  ),
                ],
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LabeledDropdown<int>(
                label: 'Department',
                value: deptId,
                items: visible.map((d) => (value: d.id, text: d.name)).toList(),
                onChanged: (id) => ref.read(selectedReportDepartmentIdProvider.notifier).state = id,
              ),
            ),
            _FilterTabBar(filter: filter),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final reportAsync = ref.watch(reportProvider((departmentId: deptId, from: filter.from, to: filter.to)));
                  return reportAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (lines) {
                      if (lines.isEmpty) return const Center(child: Text('No titles in this department yet.'));
                      return _ReportTableSection(
                        lines: lines,
                        from: filter.from,
                        to: filter.to,
                        isAdmin: user.isAdminOrSuper,
                        onPrint: () => _print(deptId, deptName, filter, lines),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Financial Year / Month wise / Custom Range tab bar swapping inline
/// controls under one shared apply action — matches the old app's tabbed
/// filter bar instead of a `SegmentedButton` that pops separate dialogs. FY
/// and Month apply immediately on selection (matching the old app's
/// `onchange` auto-submit); Custom Range needs an explicit Filter tap since
/// it's two free-form date fields.
class _FilterTabBar extends ConsumerStatefulWidget {
  final ReportFilter filter;
  const _FilterTabBar({required this.filter});

  @override
  ConsumerState<_FilterTabBar> createState() => _FilterTabBarState();
}

class _FilterTabBarState extends ConsumerState<_FilterTabBar> {
  late ReportFilterMode _activeTab = widget.filter.mode;
  DateTime? _customFrom;
  DateTime? _customTo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (final mode in ReportFilterMode.values) ...[
                _TabButton(
                  label: switch (mode) {
                    ReportFilterMode.financialYear => 'Financial Year',
                    ReportFilterMode.month => 'Month wise',
                    ReportFilterMode.custom => 'Custom Range',
                  },
                  selected: _activeTab == mode,
                  onTap: () => setState(() => _activeTab = mode),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 8),
          switch (_activeTab) {
            ReportFilterMode.financialYear => _financialYearRow(),
            ReportFilterMode.month => _monthRow(),
            ReportFilterMode.custom => _customRangeRow(),
          },
        ],
      ),
    );
  }

  Widget _financialYearRow() {
    final currentFyStart = AppDateUtils.financialYearContaining(DateTime.now()).start.year;
    final options = [for (int i = 0; i < 10; i++) currentFyStart + 1 - i];
    final currentValue = widget.filter.mode == ReportFilterMode.financialYear ? widget.filter.from.year : null;

    return LabeledDropdown<int>(
      label: 'Financial Year',
      value: options.contains(currentValue) ? currentValue : null,
      items: [for (final y in options) (value: y, text: '$y-${y + 1}')],
      onChanged: (year) {
        if (year == null) return;
        ref.read(reportFilterProvider.notifier).state =
            ReportFilter(mode: ReportFilterMode.financialYear, from: DateTime(year, 4, 1), to: DateTime(year + 1, 3, 31));
      },
    );
  }

  Widget _monthRow() {
    final now = DateTime.now();
    final currentMonth = widget.filter.mode == ReportFilterMode.month ? widget.filter.from.month : now.month;
    final currentYear = widget.filter.mode == ReportFilterMode.month ? widget.filter.from.year : now.year;

    void apply(int month, int year) {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 0);
      ref.read(reportFilterProvider.notifier).state = ReportFilter(mode: ReportFilterMode.month, from: start, to: end);
    }

    return Row(
      children: [
        LabeledDropdown<int>(
          label: 'Month',
          value: currentMonth,
          items: [
            for (var m = 1; m <= 12; m++)
              (value: m, text: AppDateUtils.monthName(m)),
          ],
          onChanged: (m) => m == null ? null : apply(m, currentYear),
        ),
        const SizedBox(width: 12),
        LabeledDropdown<int>(
          label: 'Year',
          value: currentYear,
          width: 120,
          items: [for (var y = currentYear + 1; y >= currentYear - 8; y--) (value: y, text: '$y')],
          onChanged: (y) => y == null ? null : apply(currentMonth, y),
        ),
      ],
    );
  }

  Widget _customRangeRow() {
    final from = _customFrom ?? (widget.filter.mode == ReportFilterMode.custom ? widget.filter.from : widget.filter.from);
    final to = _customTo ?? (widget.filter.mode == ReportFilterMode.custom ? widget.filter.to : widget.filter.to);

    return Row(
      children: [
        TextButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(context: context, initialDate: from, firstDate: DateTime(2000), lastDate: DateTime(2100));
            if (picked != null) setState(() => _customFrom = AppDateUtils.dateOnly(picked));
          },
          icon: const Icon(Icons.calendar_today, size: 14),
          label: Text('From: ${AppDateUtils.format(from)}'),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(context: context, initialDate: to, firstDate: DateTime(2000), lastDate: DateTime(2100));
            if (picked != null) setState(() => _customTo = AppDateUtils.dateOnly(picked));
          },
          icon: const Icon(Icons.calendar_today, size: 14),
          label: Text('To: ${AppDateUtils.format(to)}'),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: () {
            ref.read(reportFilterProvider.notifier).state = ReportFilter(mode: ReportFilterMode.custom, from: from, to: to);
          },
          child: const Text('Filter'),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.accentLedger : null,
        foregroundColor: selected ? Colors.white : AppColors.inkPrimary,
        side: selected ? BorderSide.none : const BorderSide(color: AppColors.lineHairline),
      ),
      child: Text(label),
    );
  }
}

class _ReportTableSection extends ConsumerStatefulWidget {
  final List<ReportLine> lines;
  final DateTime from;
  final DateTime to;
  final bool isAdmin;
  final VoidCallback onPrint;

  const _ReportTableSection({required this.lines, required this.from, required this.to, required this.isAdmin, required this.onPrint});

  @override
  ConsumerState<_ReportTableSection> createState() => _ReportTableSectionState();
}

class _ReportTableSectionState extends ConsumerState<_ReportTableSection> {
  final Set<int> _expandedTitleIds = {};
  final Set<int> _expandedSubTitleIds = {};

  Future<void> _editEntry(dynamic entry) async {
    final debitController = TextEditingController(text: entry.debitAmount == 0 ? '' : entry.debitAmount.toString());
    final creditController = TextEditingController(text: entry.creditAmount == 0 ? '' : entry.creditAmount.toString());
    final detailsController = TextEditingController(text: entry.details ?? '');

    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Entry'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: debitController, decoration: const InputDecoration(labelText: 'Debit'), keyboardType: TextInputType.number),
          TextField(controller: creditController, decoration: const InputDecoration(labelText: 'Credit'), keyboardType: TextInputType.number),
          TextField(controller: detailsController, decoration: const InputDecoration(labelText: 'Details')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Save')),
        ],
      ),
    );
    if (save != true) return;
    await ref.read(transactionActionsControllerProvider.notifier).editEntry(
          id: entry.id,
          debitAmount: double.tryParse(debitController.text) ?? 0,
          creditAmount: double.tryParse(creditController.text) ?? 0,
          details: detailsController.text,
        );
  }

  Future<void> _deleteEntry(dynamic entry) async {
    final confirmed = await showConfirmDialog(context,
        title: 'Delete Entry', message: 'Delete the entry for ${AppDateUtils.format(entry.entryDate)}?', confirmLabel: 'Delete', destructive: true);
    if (!confirmed) return;
    await ref.read(transactionActionsControllerProvider.notifier).deleteEntry(subTitleId: entry.subTitleId, entryDate: entry.entryDate);
  }

  @override
  Widget build(BuildContext context) {
    final mainTitlesAsync = ref.watch(allMainTitlesProvider);
    final mainTitleOrder = mainTitlesAsync.value?.map((m) => m.name).toList() ?? const ['ASSETS', 'LIABILITY', 'INCOME', 'EXPENSE'];

    final byMain = <String, List<ReportLine>>{};
    for (final line in widget.lines) {
      byMain.putIfAbsent(line.mainTitleName, () => []).add(line);
    }
    final grandTotal = widget.lines.fold<double>(0, (sum, l) => sum + l.closing);

    final rows = <TableRow>[];
    for (final mainTitleName in mainTitleOrder) {
      final mainLines = byMain[mainTitleName];
      if (mainLines == null || mainLines.isEmpty) continue;
      final mainClosing = mainLines.fold<double>(0, (sum, l) => sum + l.closing);

      rows.add(TableRow(
        decoration: const BoxDecoration(color: AppColors.accentLedgerTint),
        children: [
          LedgerCell(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text(mainTitleName, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const LedgerCell(child: SizedBox.shrink()),
          const LedgerCell(child: SizedBox.shrink()),
          const LedgerCell(child: SizedBox.shrink()),
          const LedgerCell(child: SizedBox.shrink()),
          const LedgerCell(child: SizedBox.shrink()),
          LedgerCell(align: TextAlign.right, child: AmountText(mainClosing, showDrCrSuffix: true, fontWeight: FontWeight.w700)),
          const LedgerCell(child: SizedBox.shrink()),
        ],
      ));

      final byTitle = <int, List<ReportLine>>{};
      for (final line in mainLines) {
        byTitle.putIfAbsent(line.titleId, () => []).add(line);
      }

      for (final titleEntry in byTitle.entries) {
        final titleId = titleEntry.key;
        final titleLines = titleEntry.value;
        final titleOpening = titleLines.fold<double>(0, (sum, l) => sum + l.openingCarry);
        final titleDebit = titleLines.fold<double>(0, (sum, l) => sum + l.periodDebit);
        final titleCredit = titleLines.fold<double>(0, (sum, l) => sum + l.periodCredit);
        final titleClosing = titleOpening + titleDebit - titleCredit;
        final titleExpanded = _expandedTitleIds.contains(titleId);

        rows.add(TableRow(
          children: [
            LedgerCell(
              child: InkWell(
                onTap: () => setState(() => titleExpanded ? _expandedTitleIds.remove(titleId) : _expandedTitleIds.add(titleId)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(titleExpanded ? Icons.arrow_drop_down : Icons.arrow_right, size: 18, color: AppColors.accentLedger),
                  Flexible(child: Text(titleLines.first.titleName, style: const TextStyle(fontWeight: FontWeight.w600))),
                ]),
              ),
            ),
            LedgerCell(child: Text(titleLines.first.vfNo ?? '—')),
            const LedgerCell(child: SizedBox.shrink()),
            LedgerCell(child: Text('Opening: ${titleOpening.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary))),
            LedgerCell(align: TextAlign.right, child: ColumnAmountText(titleDebit, isDebitColumn: true)),
            LedgerCell(align: TextAlign.right, child: ColumnAmountText(titleCredit, isDebitColumn: false)),
            LedgerCell(align: TextAlign.right, child: AmountText(titleClosing, showDrCrSuffix: true, fontWeight: FontWeight.w600)),
            const LedgerCell(child: SizedBox.shrink()),
          ],
        ));

        if (!titleExpanded) continue;

        for (final line in titleLines) {
          final subExpanded = _expandedSubTitleIds.contains(line.subTitleId);
          rows.add(TableRow(
            decoration: const BoxDecoration(color: AppColors.surfaceCanvas),
            children: [
              LedgerCell(
                padding: const EdgeInsets.only(left: 32, top: 10, bottom: 10, right: 12),
                child: InkWell(
                  onTap: () => setState(() => subExpanded ? _expandedSubTitleIds.remove(line.subTitleId) : _expandedSubTitleIds.add(line.subTitleId)),
                  child: Text('↳ ${line.subTitleName}'),
                ),
              ),
              const LedgerCell(child: SizedBox.shrink()),
              const LedgerCell(child: SizedBox.shrink()),
              LedgerCell(child: Text('Opening: ${line.openingCarry.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary))),
              LedgerCell(align: TextAlign.right, child: ColumnAmountText(line.periodDebit, isDebitColumn: true)),
              LedgerCell(align: TextAlign.right, child: ColumnAmountText(line.periodCredit, isDebitColumn: false)),
              LedgerCell(align: TextAlign.right, child: AmountText(line.closing, showDrCrSuffix: true)),
              const LedgerCell(child: SizedBox.shrink()),
            ],
          ));

          if (!subExpanded) continue;

          final entriesAsync = ref.watch(entriesInRangeProvider((subTitleId: line.subTitleId, from: widget.from, to: widget.to)));
          final entries = entriesAsync.value;
          if (entries == null) {
            rows.add(const TableRow(children: [
              LedgerCell(padding: EdgeInsets.only(left: 56), child: Text('Loading…')),
              LedgerCell(child: SizedBox.shrink()),
              LedgerCell(child: SizedBox.shrink()),
              LedgerCell(child: SizedBox.shrink()),
              LedgerCell(child: SizedBox.shrink()),
              LedgerCell(child: SizedBox.shrink()),
              LedgerCell(child: SizedBox.shrink()),
              LedgerCell(child: SizedBox.shrink()),
            ]));
          } else if (entries.isEmpty) {
            rows.add(const TableRow(children: [
              LedgerCell(padding: EdgeInsets.only(left: 56), child: Text('No entries in this period.', style: TextStyle(color: AppColors.inkMuted))),
              LedgerCell(child: SizedBox.shrink()),
              LedgerCell(child: SizedBox.shrink()),
              LedgerCell(child: SizedBox.shrink()),
              LedgerCell(child: SizedBox.shrink()),
              LedgerCell(child: SizedBox.shrink()),
              LedgerCell(child: SizedBox.shrink()),
              LedgerCell(child: SizedBox.shrink()),
            ]));
          } else {
            var running = line.openingCarry;
            for (final entry in entries) {
              running += entry.debitAmount - entry.creditAmount;
              rows.add(TableRow(
                decoration: const BoxDecoration(color: AppColors.surfacePanel),
                children: [
                  LedgerCell(padding: const EdgeInsets.only(left: 56, top: 8, bottom: 8, right: 12), child: Text('• ${line.subTitleName}', style: const TextStyle(fontSize: 12))),
                  const LedgerCell(child: SizedBox.shrink()),
                  LedgerCell(child: Text(AppDateUtils.format(entry.entryDate), style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary))),
                  LedgerCell(child: Text(entry.details ?? '—', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                  LedgerCell(align: TextAlign.right, child: ColumnAmountText(entry.debitAmount, isDebitColumn: true, fontSize: 12)),
                  LedgerCell(align: TextAlign.right, child: ColumnAmountText(entry.creditAmount, isDebitColumn: false, fontSize: 12)),
                  LedgerCell(align: TextAlign.right, child: AmountText(running, showDrCrSuffix: true, fontSize: 12)),
                  LedgerCell(
                    align: TextAlign.right,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
                    child: widget.isAdmin
                        ? Row(mainAxisSize: MainAxisSize.min, children: [
                            CompactIconButton(icon: Icons.edit_outlined, onPressed: () => _editEntry(entry)),
                            CompactIconButton(icon: Icons.delete_outline, onPressed: () => _deleteEntry(entry)),
                          ])
                        : const SizedBox.shrink(),
                  ),
                ],
              ));
            }
          }
        }
      }
    }

    return Column(
      children: [
        if (widget.isAdmin)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextButton.icon(onPressed: widget.onPrint, icon: const Icon(Icons.print_outlined, size: 16), label: const Text('Print')),
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LedgerTable(
              columns: const [
                LedgerColumn('Title / Sub-title', width: FlexColumnWidth(2.2)),
                LedgerColumn('VF No', width: FixedColumnWidth(70)),
                LedgerColumn('Date', width: FixedColumnWidth(90)),
                LedgerColumn('Details', width: FlexColumnWidth(1.6)),
                LedgerColumn('Debit', align: TextAlign.right, width: FixedColumnWidth(100)),
                LedgerColumn('Credit', align: TextAlign.right, width: FixedColumnWidth(100)),
                LedgerColumn('Closing', align: TextAlign.right, width: FixedColumnWidth(130)),
                LedgerColumn('Actions', align: TextAlign.right, width: FixedColumnWidth(80)),
              ],
              rows: rows,
              footer: TableRow(
                decoration: ledgerFooterDecoration,
                children: [
                  const LedgerCell(child: Text('GRAND TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
                  const LedgerCell(child: SizedBox.shrink()),
                  const LedgerCell(child: SizedBox.shrink()),
                  const LedgerCell(child: SizedBox.shrink()),
                  const LedgerCell(child: SizedBox.shrink()),
                  const LedgerCell(child: SizedBox.shrink()),
                  LedgerCell(align: TextAlign.right, child: AmountText(grandTotal, showDrCrSuffix: true, fontWeight: FontWeight.bold)),
                  const LedgerCell(child: SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
