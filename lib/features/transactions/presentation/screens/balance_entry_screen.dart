import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/permission_keys.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/rbac/current_user_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared_widgets/amount_text.dart';
import '../../../../shared_widgets/confirm_dialog.dart';
import '../../../../shared_widgets/gradient_filled_button.dart';
import '../../../../shared_widgets/labeled_dropdown.dart';
import '../../../../shared_widgets/page_header.dart';
import '../../../../shared_widgets/status_badge.dart';
import '../../../chart_of_accounts/domain/repositories/chart_of_accounts_repository.dart';
import '../../../chart_of_accounts/presentation/controllers/chart_of_accounts_controllers.dart';
import '../../../departments/presentation/controllers/department_controllers.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/services/voice_command_parser.dart';
import '../controllers/transaction_controllers.dart';
import '../widgets/voice_entry_button.dart';

/// Rebuilt to match the old app's `balanceentry.php` structure: a 3-level
/// collapsible tree (Category -> Title -> Sub-title, all collapsed by
/// default), a live Calculated-vs-Actual-Closing bar recomputed on every
/// keystroke, and an inline "Set Actual Closing" panel — see the plan for
/// the full old-app fidelity analysis this was built from.
class BalanceEntryScreen extends ConsumerWidget {
  const BalanceEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider)!;
    final departmentsAsync = ref.watch(watchDepartmentsProvider);
    final selectedDeptId = ref.watch(selectedEntryDepartmentIdProvider);
    final selectedDate = ref.watch(selectedEntryDateProvider);

    return departmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allDepartments) {
        final visible =
            user.isAdminOrSuper ? allDepartments : allDepartments.where((d) => user.departmentIds.contains(d.id)).toList();
        if (visible.isEmpty) {
          return const Column(children: [
            PageHeader(title: 'Transaction Entry', icon: Icons.edit_note_outlined, accentColor: Color(0xFF0EA5E9)),
            Expanded(child: Center(child: Text('No accessible departments.'))),
          ]);
        }
        final deptId =
            (selectedDeptId != null && visible.any((d) => d.id == selectedDeptId)) ? selectedDeptId : visible.first.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Transaction Entry',
              icon: Icons.edit_note_outlined,
              accentColor: const Color(0xFF0EA5E9),
              actions: [
                LabeledDropdown<int>(
                  label: 'Department',
                  value: deptId,
                  items: visible.map((d) => (value: d.id, text: d.name)).toList(),
                  onChanged: (id) => ref.read(selectedEntryDepartmentIdProvider.notifier).state = id,
                ),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      ref.read(selectedEntryDateProvider.notifier).state = AppDateUtils.dateOnly(picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(AppDateUtils.format(selectedDate)),
                ),
              ],
            ),
            Expanded(child: _EntryBody(key: ValueKey('$deptId|${AppDateUtils.format(selectedDate)}'), departmentId: deptId, date: selectedDate)),
          ],
        );
      },
    );
  }
}

class _EntryBody extends ConsumerStatefulWidget {
  final int departmentId;
  final DateTime date;
  const _EntryBody({super.key, required this.departmentId, required this.date});

  @override
  ConsumerState<_EntryBody> createState() => _EntryBodyState();
}

class _EntryBodyState extends ConsumerState<_EntryBody> {
  final Map<int, TextEditingController> _opening = {};
  final Map<int, TextEditingController> _debit = {};
  final Map<int, TextEditingController> _credit = {};
  final Map<int, TextEditingController> _details = {};
  final Set<int> _expandedCategories = {};
  final Set<int> _expandedTitles = {};

  TextEditingController _ctrl(Map<int, TextEditingController> map, int id, String initial) {
    return map.putIfAbsent(id, () => TextEditingController(text: initial)..addListener(() => setState(() {})));
  }

  @override
  void dispose() {
    for (final c in [..._opening.values, ..._debit.values, ..._credit.values, ..._details.values]) {
      c.dispose();
    }
    super.dispose();
  }

  double _liveCalculatedClosing() {
    double total = 0;
    for (final id in _opening.keys) {
      final opening = double.tryParse(_opening[id]?.text ?? '') ?? 0;
      final debit = double.tryParse(_debit[id]?.text ?? '') ?? 0;
      final credit = double.tryParse(_credit[id]?.text ?? '') ?? 0;
      total += opening + credit - debit;
    }
    return total;
  }

  Future<void> _save({required bool closeConfirm}) async {
    final user = ref.read(currentUserProvider)!;
    final canEditOpening = user.has(PermissionCode.balanceEntryEdit);

    final rows = <EntryRow>[
      for (final id in _debit.keys)
        EntryRow(
          subTitleId: id,
          debitAmount: double.tryParse(_debit[id]?.text ?? '') ?? 0,
          creditAmount: double.tryParse(_credit[id]?.text ?? '') ?? 0,
          details: _details[id]?.text,
          openingBalance: canEditOpening ? (double.tryParse(_opening[id]?.text ?? '') ?? 0) : null,
        ),
    ];

    if (closeConfirm) {
      final calc = _liveCalculatedClosing();
      final confirmed = await showHighStakesConfirmDialog(
        context,
        title: 'Save & Close ${AppDateUtils.format(widget.date)}',
        summary: [
          ('Calculated Closing', CurrencyFormatter.formatWithDrCr(calc)),
        ],
        confirmLabel: 'Save & Close',
      );
      if (!confirmed) return;
    }

    final ok = await ref
        .read(transactionActionsControllerProvider.notifier)
        .saveAll(departmentId: widget.departmentId, entryDate: widget.date, rows: rows, closeConfirm: closeConfirm);
    if (!mounted) return;
    if (!ok) {
      final error = ref.read(transactionActionsControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error?.message ?? 'Something went wrong.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(closeConfirm ? 'Saved and closed.' : 'Saved.')));
    }
  }

  Future<void> _showSetActualClosingDialog(List<Department> departments) async {
    final controller = TextEditingController();
    int? selectedDeptId = widget.departmentId;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Actual Closing Balance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${AppDateUtils.format(widget.date)}', style: const TextStyle(color: AppColors.inkSecondary)),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: selectedDeptId,
                decoration: const InputDecoration(labelText: 'Department'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Departments')),
                  for (final d in departments) DropdownMenuItem(value: d.id, child: Text(d.name)),
                ],
                onChanged: (v) => setState(() => selectedDeptId = v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Actual Closing Amount'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (result != true) return;
    final value = double.tryParse(controller.text);
    if (value == null) return;
    await ref.read(transactionActionsControllerProvider.notifier).saveClosingCheck(
          departmentId: selectedDeptId,
          checkDate: widget.date,
          actualClosing: value,
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider)!;
    final mainTitlesAsync = ref.watch(allMainTitlesProvider);
    final rowsAsync = ref.watch(watchLedgerRowsForDepartmentProvider(widget.departmentId));
    final existingAsync = ref.watch(watchEntriesForDateProvider((departmentId: widget.departmentId, date: widget.date)));
    final isClosedAsync = ref.watch(isDayClosedProvider((departmentId: widget.departmentId, date: widget.date)));
    final actualClosingAsync =
        ref.watch(effectiveActualClosingProvider((departmentId: widget.departmentId, date: widget.date)));
    final allDepartmentsAsync = ref.watch(watchDepartmentsProvider);

    if (!mainTitlesAsync.hasValue || !rowsAsync.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }

    final mainTitles = mainTitlesAsync.value!;
    final rows = rowsAsync.value!;
    final existingByCode = {for (final e in existingAsync.value ?? []) e.subTitleId: e};

    for (final row in rows) {
      final existing = existingByCode[row.subTitle.id];
      _ctrl(_opening, row.subTitle.id, row.subTitle.openingBalance == 0 ? '0' : row.subTitle.openingBalance.toString());
      _ctrl(_debit, row.subTitle.id, (existing == null || existing.debitAmount == 0) ? '' : existing.debitAmount.toString());
      _ctrl(_credit, row.subTitle.id, (existing == null || existing.creditAmount == 0) ? '' : existing.creditAmount.toString());
      _ctrl(_details, row.subTitle.id, existing?.details ?? '');
    }

    final isClosed = isClosedAsync.value ?? false;
    final readOnly = isClosed && !user.isAdminOrSuper;
    final actualClosing = actualClosingAsync.value?.actualClosing;
    final calculated = _liveCalculatedClosing();
    final matches = actualClosing != null && (calculated - actualClosing).abs() < 0.01;

    final rowsByCategory = <int, List<LedgerRow>>{};
    for (final row in rows) {
      rowsByCategory.putIfAbsent(row.mainTitleId, () => []).add(row);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfacePanel,
              borderRadius: BorderRadius.circular(10),
              boxShadow: AppColors.softShadow(),
            ),
            child: Wrap(
              spacing: 24,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Calculated Closing: ', style: TextStyle(color: AppColors.inkSecondary, fontSize: 12)),
                  AmountText(calculated, showDrCrSuffix: true, fontWeight: FontWeight.w600),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Actual Closing: ', style: TextStyle(color: AppColors.inkSecondary, fontSize: 12)),
                  actualClosing == null
                      ? const Text('— not set —', style: TextStyle(color: AppColors.inkMuted, fontSize: 13))
                      : AmountText(actualClosing, showDrCrSuffix: true, fontWeight: FontWeight.w600),
                ]),
                if (actualClosing == null)
                  const Text('No actual closing set for this date.', style: TextStyle(color: AppColors.inkMuted, fontSize: 12))
                else
                  _MatchBadge(matched: matches),
                isClosed ? StatusBadge.closed() : StatusBadge.open(),
                if (user.isAdminOrSuper)
                  TextButton(
                    onPressed: () => _showSetActualClosingDialog(allDepartmentsAsync.value ?? []),
                    child: const Text('Set Actual Closing'),
                  ),
                VoiceEntryButton(
                  rows: [
                    for (final row in rows)
                      (
                        subTitleId: row.subTitle.id,
                        subTitleName: row.subTitle.subTitleName,
                        titleName: row.titleName,
                        mainTitleName: row.mainTitleName,
                      ),
                  ],
                  onCommand: _applyVoiceCommand,
                ),
              ],
            ),
          ),
        ),
        if (readOnly)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('This day is closed. Entries can\'t be added here — an admin can still edit or delete existing entries.',
                style: TextStyle(color: AppColors.signalAmber)),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final mainTitle in mainTitles)
                _CategorySection(
                  mainTitleId: mainTitle.id,
                  mainTitleName: mainTitle.name,
                  rows: rowsByCategory[mainTitle.id] ?? const [],
                  expanded: _expandedCategories.contains(mainTitle.id),
                  onToggle: () => setState(() {
                    if (_expandedCategories.contains(mainTitle.id)) {
                      _expandedCategories.remove(mainTitle.id);
                    } else {
                      _expandedCategories.add(mainTitle.id);
                    }
                  }),
                  expandedTitles: _expandedTitles,
                  onToggleTitle: (titleId) => setState(() {
                    if (_expandedTitles.contains(titleId)) {
                      _expandedTitles.remove(titleId);
                    } else {
                      _expandedTitles.add(titleId);
                    }
                  }),
                  readOnly: readOnly,
                  canEditOpening: user.has(PermissionCode.balanceEntryEdit),
                  canAdd: user.has(PermissionCode.balanceEntryAdd),
                  isAdmin: user.isAdminOrSuper,
                  openingControllers: _opening,
                  debitControllers: _debit,
                  creditControllers: _credit,
                  detailsControllers: _details,
                  onDelete: (subTitleId) async {
                    final confirmed = await showConfirmDialog(context,
                        title: 'Delete Entry', message: 'Delete this entry for ${AppDateUtils.format(widget.date)}?', confirmLabel: 'Delete', destructive: true);
                    if (confirmed) {
                      await ref
                          .read(transactionActionsControllerProvider.notifier)
                          .deleteEntry(subTitleId: subTitleId, entryDate: widget.date);
                    }
                  },
                ),
            ],
          ),
        ),
        if (!readOnly && user.has(PermissionCode.balanceEntryAdd))
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () => _save(closeConfirm: false), child: const Text('Save (Draft)')),
                const SizedBox(width: 12),
                GradientFilledButton(
                  onPressed: matches ? () => _save(closeConfirm: true) : null,
                  icon: Icons.lock_outline,
                  child: const Text('Save & Close'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _applyVoiceCommand(VoiceEntryCommand command) {
    setState(() {
      final controllers = command.isCredit ? _credit : _debit;
      final controller = controllers[command.subTitleId];
      controller?.text = command.amount.toString();
    });
  }
}

class _MatchBadge extends StatelessWidget {
  final bool matched;
  const _MatchBadge({required this.matched});

  @override
  Widget build(BuildContext context) {
    return matched ? StatusBadge.match() : StatusBadge.mismatch();
  }
}

class _CategorySection extends StatelessWidget {
  final int mainTitleId;
  final String mainTitleName;
  final List<LedgerRow> rows;
  final bool expanded;
  final VoidCallback onToggle;
  final Set<int> expandedTitles;
  final ValueChanged<int> onToggleTitle;
  final bool readOnly;
  final bool canEditOpening;
  final bool canAdd;
  final bool isAdmin;
  final Map<int, TextEditingController> openingControllers;
  final Map<int, TextEditingController> debitControllers;
  final Map<int, TextEditingController> creditControllers;
  final Map<int, TextEditingController> detailsControllers;
  final void Function(int subTitleId) onDelete;

  const _CategorySection({
    required this.mainTitleId,
    required this.mainTitleName,
    required this.rows,
    required this.expanded,
    required this.onToggle,
    required this.expandedTitles,
    required this.onToggleTitle,
    required this.readOnly,
    required this.canEditOpening,
    required this.canAdd,
    required this.isAdmin,
    required this.openingControllers,
    required this.debitControllers,
    required this.creditControllers,
    required this.detailsControllers,
    required this.onDelete,
  });

  /// Each of the 4 fixed categories gets its own identity color (reused
  /// consistently with the Dashboard's per-feature card colors elsewhere in
  /// the app), so the 4 sections are visually distinguishable at a glance
  /// instead of 4 identical gray boxes.
  static Color _categoryColor(String name) => switch (name) {
        'ASSETS' => AppColors.categoryAssets,
        'LIABILITY' => AppColors.categoryLiability,
        'INCOME' => AppColors.categoryIncome,
        'EXPENSE' => AppColors.categoryExpense,
        _ => AppColors.accentLedger,
      };

  static IconData _categoryIcon(String name) => switch (name) {
        'ASSETS' => Icons.account_balance_wallet_outlined,
        'LIABILITY' => Icons.request_quote_outlined,
        'INCOME' => Icons.trending_up,
        'EXPENSE' => Icons.trending_down,
        _ => Icons.category_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final byTitle = <int, List<LedgerRow>>{};
    final titleNames = <int, String>{};
    for (final row in rows) {
      byTitle.putIfAbsent(row.titleId, () => []).add(row);
      titleNames[row.titleId] = row.titleName;
    }

    final color = _categoryColor(mainTitleName);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                border: Border(left: BorderSide(color: color, width: 4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(expanded ? Icons.arrow_drop_down : Icons.arrow_right, size: 18, color: color),
                  Icon(_categoryIcon(mainTitleName), size: 16, color: color),
                  const SizedBox(width: 8),
                  Text(mainTitleName, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                ],
              ),
            ),
          ),
          if (expanded)
            if (byTitle.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('No titles with sub-titles yet.', style: TextStyle(color: AppColors.inkMuted)),
              )
            else
              for (final entry in byTitle.entries)
                _TitleSection(
                  titleId: entry.key,
                  titleName: titleNames[entry.key]!,
                  rows: entry.value,
                  expanded: expandedTitles.contains(entry.key),
                  onToggle: () => onToggleTitle(entry.key),
                  readOnly: readOnly,
                  canEditOpening: canEditOpening,
                  canAdd: canAdd,
                  isAdmin: isAdmin,
                  openingControllers: openingControllers,
                  debitControllers: debitControllers,
                  creditControllers: creditControllers,
                  detailsControllers: detailsControllers,
                  onDelete: onDelete,
                ),
        ],
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  final int titleId;
  final String titleName;
  final List<LedgerRow> rows;
  final bool expanded;
  final VoidCallback onToggle;
  final bool readOnly;
  final bool canEditOpening;
  final bool canAdd;
  final bool isAdmin;
  final Map<int, TextEditingController> openingControllers;
  final Map<int, TextEditingController> debitControllers;
  final Map<int, TextEditingController> creditControllers;
  final Map<int, TextEditingController> detailsControllers;
  final void Function(int subTitleId) onDelete;

  const _TitleSection({
    required this.titleId,
    required this.titleName,
    required this.rows,
    required this.expanded,
    required this.onToggle,
    required this.readOnly,
    required this.canEditOpening,
    required this.canAdd,
    required this.isAdmin,
    required this.openingControllers,
    required this.debitControllers,
    required this.creditControllers,
    required this.detailsControllers,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(expanded ? Icons.arrow_drop_down : Icons.arrow_right, size: 16, color: AppColors.inkSecondary),
                Text(titleName, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        if (expanded)
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 4, 12, 4),
              child: Row(
                children: [
                  SizedBox(width: 160, child: Text('↳ ${row.subTitle.subTitleName}', overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: openingControllers[row.subTitle.id],
                      enabled: !readOnly && canEditOpening,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Opening', isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: debitControllers[row.subTitle.id],
                      enabled: !readOnly && canAdd,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Debit', isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: creditControllers[row.subTitle.id],
                      enabled: !readOnly && canAdd,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Credit', isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: detailsControllers[row.subTitle.id],
                      enabled: !readOnly && canAdd,
                      decoration: const InputDecoration(labelText: 'Details', isDense: true),
                    ),
                  ),
                  if (isAdmin)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.signalError),
                      onPressed: () => onDelete(row.subTitle.id),
                    ),
                ],
              ),
            ),
      ],
    );
  }
}
