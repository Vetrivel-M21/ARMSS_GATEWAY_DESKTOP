// `Title` (the DB row type from app_database.dart) collides with Flutter's
// own `Title` widget (used only internally for OS task-switcher metadata) —
// hidden here since this screen never needs the widget.
import 'package:flutter/material.dart' hide Title;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/permission_keys.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/rbac/current_user_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared_widgets/amount_text.dart';
import '../../../../shared_widgets/compact_icon_button.dart';
import '../../../../shared_widgets/confirm_dialog.dart';
import '../../../../shared_widgets/gradient_filled_button.dart';
import '../../../../shared_widgets/labeled_dropdown.dart';
import '../../../../shared_widgets/ledger_table.dart';
import '../../../../shared_widgets/page_header.dart';
import '../../../departments/presentation/controllers/department_controllers.dart';
import '../controllers/chart_of_accounts_controllers.dart';

class TitleListScreen extends ConsumerWidget {
  const TitleListScreen({super.key});

  List<Department> _visibleDepartments(List<Department> all, dynamic user) {
    if (user.isAdminOrSuper as bool) return all;
    return all.where((d) => (user.departmentIds as List<int>).contains(d.id)).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider)!;
    final departmentsAsync = ref.watch(watchDepartmentsProvider);
    final selectedDeptId = ref.watch(selectedTitleDepartmentIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        departmentsAsync.when(
          loading: () => const PageHeader(
              title: 'Titles & Sub-Titles', icon: Icons.account_tree_outlined, accentColor: Color(0xFF6366F1)),
          error: (e, _) => const PageHeader(
              title: 'Titles & Sub-Titles', icon: Icons.account_tree_outlined, accentColor: Color(0xFF6366F1)),
          data: (allDepartments) {
            final visible = _visibleDepartments(allDepartments, user);
            final effectiveDeptId = (selectedDeptId != null && visible.any((d) => d.id == selectedDeptId))
                ? selectedDeptId
                : (visible.isNotEmpty ? visible.first.id : null);
            return PageHeader(
              title: 'Titles & Sub-Titles',
              icon: Icons.account_tree_outlined,
              accentColor: const Color(0xFF6366F1),
              actions: [
                if (visible.isNotEmpty)
                  LabeledDropdown<int>(
                    label: 'Department',
                    value: effectiveDeptId,
                    items: visible.map((d) => (value: d.id, text: d.name)).toList(),
                    onChanged: (id) => ref.read(selectedTitleDepartmentIdProvider.notifier).state = id,
                  ),
                if (effectiveDeptId != null && user.has(PermissionCode.titlesAdd))
                  GradientFilledButton(
                    onPressed: () => _showAddTitleDialog(context, ref, effectiveDeptId),
                    icon: Icons.add,
                    child: const Text('Add Title'),
                  ),
              ],
            );
          },
        ),
        Expanded(
          child: departmentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (allDepartments) {
              final visible = _visibleDepartments(allDepartments, user);
              if (visible.isEmpty) {
                return const Center(child: Text('No accessible departments.'));
              }
              final effectiveDeptId = (selectedDeptId != null && visible.any((d) => d.id == selectedDeptId))
                  ? selectedDeptId
                  : visible.first.id;
              return _TitleTable(departmentId: effectiveDeptId);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showAddTitleDialog(BuildContext context, WidgetRef ref, int departmentId) async {
    final mainTitlesAsync = ref.read(allMainTitlesProvider);
    final mainTitles = mainTitlesAsync.value;
    if (mainTitles == null || mainTitles.isEmpty) return;

    final nameController = TextEditingController();
    final vfNoController = TextEditingController();
    int selectedMainTitleId = mainTitles.first.id;
    bool applyAll = false;
    final user = ref.read(currentUserProvider)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Title'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                initialValue: selectedMainTitleId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: mainTitles.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                onChanged: (v) => setState(() => selectedMainTitleId = v!),
              ),
              const SizedBox(height: 12),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Title Name')),
              const SizedBox(height: 12),
              TextField(controller: vfNoController, decoration: const InputDecoration(labelText: 'VF No (optional)')),
              if (user.isAdminOrSuper) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(value: applyAll, onChanged: (v) => setState(() => applyAll = v ?? false)),
                    const SizedBox(width: 4),
                    const Text('Apply to all departments'),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Add')),
          ],
        ),
      ),
    );

    if (result != true || nameController.text.trim().isEmpty) return;
    final ok = await ref.read(chartOfAccountsActionsControllerProvider.notifier).addTitle(
          mainTitleId: selectedMainTitleId,
          departmentId: departmentId,
          titleName: nameController.text,
          vfNo: vfNoController.text.trim().isEmpty ? null : vfNoController.text.trim(),
          applyAllDepartments: applyAll,
        );
    if (!ok && context.mounted) {
      final error = ref.read(chartOfAccountsActionsControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error?.message ?? 'Something went wrong.')));
    }
  }
}

/// One ledger table: title rows (▸/▾ toggle) with sub-title rows nested
/// beneath, shown only while expanded — same expand-on-click convention the
/// Report screen uses, for consistency across the app.
class _TitleTable extends ConsumerStatefulWidget {
  final int departmentId;
  const _TitleTable({required this.departmentId});

  @override
  ConsumerState<_TitleTable> createState() => _TitleTableState();
}

class _TitleTableState extends ConsumerState<_TitleTable> {
  final Set<int> _expandedTitleIds = {};

  Future<void> _deleteTitle(BuildContext context, Title title) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Title',
      message: 'Delete "${title.titleName}"? This also deletes all its sub-titles and entries.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(chartOfAccountsActionsControllerProvider.notifier).deleteTitle(title.id);
  }

  Future<void> _showAddSubTitleDialog(BuildContext context, Title title) async {
    final nameController = TextEditingController();
    final openingController = TextEditingController(text: '0');
    bool applyAll = false;
    final user = ref.read(currentUserProvider)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Sub-Title'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Sub-Title Name')),
              const SizedBox(height: 12),
              TextField(
                controller: openingController,
                decoration: const InputDecoration(labelText: 'Opening Balance'),
                keyboardType: TextInputType.number,
              ),
              if (user.isAdminOrSuper) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(value: applyAll, onChanged: (v) => setState(() => applyAll = v ?? false)),
                    const SizedBox(width: 4),
                    const Text('Apply to all departments'),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Add')),
          ],
        ),
      ),
    );

    if (result != true || nameController.text.trim().isEmpty) return;
    await ref.read(chartOfAccountsActionsControllerProvider.notifier).addSubTitle(
          titleId: title.id,
          subTitleName: nameController.text,
          openingBalance: double.tryParse(openingController.text) ?? 0,
          applyAllDepartments: applyAll,
        );
  }

  Future<void> _deleteSubTitle(BuildContext context, SubTitle subTitle) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Sub-Title',
      message: 'Delete "${subTitle.subTitleName}"?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed) {
      await ref.read(chartOfAccountsActionsControllerProvider.notifier).deleteSubTitle(subTitle.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider)!;
    final titlesAsync = ref.watch(watchTitlesForDepartmentProvider(widget.departmentId));

    return titlesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (titles) {
        if (titles.isEmpty) return const Center(child: Text('No titles yet.'));

        final rows = <TableRow>[];
        for (final title in titles) {
          final expanded = _expandedTitleIds.contains(title.id);
          rows.add(TableRow(
            children: [
              LedgerCell(
                child: InkWell(
                  onTap: () => setState(() {
                    if (expanded) {
                      _expandedTitleIds.remove(title.id);
                    } else {
                      _expandedTitleIds.add(title.id);
                    }
                  }),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(expanded ? Icons.arrow_drop_down : Icons.arrow_right, size: 18, color: AppColors.accentLedger),
                      Text(title.titleName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              LedgerCell(child: Text(title.vfNo ?? '—')),
              LedgerCell(
                align: TextAlign.right,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (user.has(PermissionCode.titlesAdd))
                      CompactIconButton(
                        icon: Icons.playlist_add,
                        onPressed: () => _showAddSubTitleDialog(context, title),
                      ),
                    if (user.has(PermissionCode.titlesDelete))
                      CompactIconButton(
                        icon: Icons.delete_outline,
                        onPressed: () => _deleteTitle(context, title),
                      ),
                  ],
                ),
              ),
            ],
          ));

          if (expanded) {
            final subTitlesAsync = ref.watch(watchSubTitlesForTitleProvider(title.id));
            subTitlesAsync.whenData((subTitles) {
              for (final subTitle in subTitles) {
                rows.add(TableRow(
                  decoration: const BoxDecoration(color: AppColors.surfaceCanvas),
                  children: [
                    LedgerCell(
                      padding: const EdgeInsets.only(left: 36, top: 10, bottom: 10, right: 12),
                      child: Text('↳ ${subTitle.subTitleName}'),
                    ),
                    LedgerCell(child: AmountText(subTitle.openingBalance)),
                    LedgerCell(
                      align: TextAlign.right,
                      child: user.has(PermissionCode.titlesDelete)
                          ? CompactIconButton(
                              icon: Icons.delete_outline,
                              onPressed: () => _deleteSubTitle(context, subTitle),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ));
              }
            });
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LedgerTable(
            columns: const [
              LedgerColumn('Title / Sub-Title', width: FlexColumnWidth(2)),
              LedgerColumn('VF No / Opening', width: FixedColumnWidth(160)),
              LedgerColumn('Actions', align: TextAlign.right, width: FixedColumnWidth(100)),
            ],
            rows: rows,
          ),
        );
      },
    );
  }
}
