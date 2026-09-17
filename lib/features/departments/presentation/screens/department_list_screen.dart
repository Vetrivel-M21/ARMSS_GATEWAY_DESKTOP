import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared_widgets/compact_icon_button.dart';
import '../../../../shared_widgets/confirm_dialog.dart';
import '../../../../shared_widgets/gradient_filled_button.dart';
import '../../../../shared_widgets/ledger_table.dart';
import '../../../../shared_widgets/page_header.dart';
import '../controllers/department_controllers.dart';

class DepartmentListScreen extends ConsumerWidget {
  const DepartmentListScreen({super.key});

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Department'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final ok = await ref.read(departmentActionsControllerProvider.notifier).add(name);
    if (!ok && context.mounted) {
      _showError(context, ref);
    }
  }

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref, int id, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Department'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty || name == currentName) return;
    final ok = await ref.read(departmentActionsControllerProvider.notifier).rename(id, name);
    if (!ok && context.mounted) {
      _showError(context, ref);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, int id, String name) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Department',
      message: 'Delete "$name"? This is blocked if any titles are assigned to it.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    final ok = await ref.read(departmentActionsControllerProvider.notifier).delete(id);
    if (!ok && context.mounted) {
      _showError(context, ref);
    }
  }

  void _showError(BuildContext context, WidgetRef ref) {
    final error = ref.read(departmentActionsControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error?.message ?? 'Something went wrong.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsAsync = ref.watch(watchDepartmentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Departments',
          icon: Icons.apartment_outlined,
          accentColor: const Color(0xFFD97706),
          actions: [
            GradientFilledButton(
              onPressed: () => _showAddDialog(context, ref),
              icon: Icons.add,
              child: const Text('Add Department'),
            ),
          ],
        ),
        Expanded(
          child: departmentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (departments) {
              if (departments.isEmpty) {
                return const Center(child: Text('No departments yet. Add one to get started.'));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LedgerTable(
                  columns: const [
                    LedgerColumn('Name'),
                    LedgerColumn('Actions', align: TextAlign.right, width: FixedColumnWidth(120)),
                  ],
                  rows: [
                    for (final dept in departments)
                      TableRow(
                        children: [
                          LedgerCell(child: Text(dept.name)),
                          LedgerCell(
                            align: TextAlign.right,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CompactIconButton(
                                  icon: Icons.edit_outlined,
                                  onPressed: () => _showRenameDialog(context, ref, dept.id, dept.name),
                                ),
                                CompactIconButton(
                                  icon: Icons.delete_outline,
                                  onPressed: () => _delete(context, ref, dept.id, dept.name),
                                ),
                              ],
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
