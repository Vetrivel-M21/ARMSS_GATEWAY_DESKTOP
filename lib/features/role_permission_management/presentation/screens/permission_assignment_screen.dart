import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/permission_keys.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared_widgets/filter_bar.dart';
import '../../../../shared_widgets/labeled_dropdown.dart';
import '../../../../shared_widgets/ledger_table.dart';
import '../../../../shared_widgets/page_header.dart';
import '../controllers/permission_assignment_controllers.dart';

/// Per-user permission grid editor — reproduces the old app's
/// userpermission.php UX: pick one `user`-role account, toggle their own
/// grid, save. One table, one row per module, one tristate checkbox per
/// action: unchecked = Deny, checked = Allow, dash (indeterminate) =
/// Inherit — which falls back to the role's default grant (nothing, for the
/// `user` role, so inherit behaves as deny, matching the old app's
/// deny-by-default).
class PermissionAssignmentScreen extends ConsumerWidget {
  const PermissionAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(selectableUsersProvider);
    final selectedUserId = ref.watch(selectedPermissionUserIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(title: 'User Permissions', icon: Icons.lock_outline, accentColor: Color(0xFF8B5CF6)),
        FilterBar(
          child: usersAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (users) => LabeledDropdown<int>(
              label: 'User',
              value: selectedUserId,
              width: 280,
              items: users.map((u) => (value: u.id, text: '${u.fullName} (${u.username})')).toList(),
              onChanged: (id) => ref.read(selectedPermissionUserIdProvider.notifier).state = id,
            ),
          ),
        ),
        if (selectedUserId != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PermissionGrid(userId: selectedUserId),
            ),
          )
        else
          const Expanded(
            child: Center(
              child: Text('Select a user above to view and edit their permissions.', style: TextStyle(color: AppColors.inkMuted)),
            ),
          ),
      ],
    );
  }
}

class _PermissionGrid extends ConsumerWidget {
  final int userId;
  const _PermissionGrid({required this.userId});

  String _moduleLabel(String module) => switch (module) {
        PermissionModule.titles => 'Titles (Chart of Accounts)',
        PermissionModule.balanceEntry => 'Transaction Entry',
        PermissionModule.balanceReport => 'Report',
        _ => module,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridAsync = ref.watch(permissionGridProvider(userId));

    return gridAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (grid) {
        final byModuleAndAction = <String, Map<String, ({Permission permission, bool? overrideValue})>>{};
        for (final row in grid) {
          byModuleAndAction.putIfAbsent(row.permission.module, () => {})[row.permission.action] = row;
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Click a checkbox to cycle: unchecked = Deny -> checked = Allow -> dash = Inherit (deny by default for the user role).',
                  style: TextStyle(fontSize: 12, color: Color(0xFF54604F)),
                ),
              ),
              LedgerTable(
                columns: [
                  const LedgerColumn('Module', width: FlexColumnWidth(2)),
                  for (final action in PermissionAction.values)
                    LedgerColumn(action[0].toUpperCase() + action.substring(1),
                        align: TextAlign.center, width: const FixedColumnWidth(90)),
                ],
                rows: [
                  for (final module in PermissionModule.values)
                    TableRow(
                      children: [
                        LedgerCell(child: Text(_moduleLabel(module))),
                        for (final action in PermissionAction.values)
                          LedgerCell(
                            align: TextAlign.center,
                            child: () {
                              final row = byModuleAndAction[module]?[action];
                              if (row == null) return const SizedBox.shrink();
                              return Checkbox(
                                tristate: true,
                                value: row.overrideValue,
                                onChanged: (allow) {
                                  ref.read(permissionAssignmentControllerProvider.notifier).setOverride(
                                        userId: userId,
                                        permissionId: row.permission.id,
                                        allow: allow,
                                      );
                                },
                              );
                            }(),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
