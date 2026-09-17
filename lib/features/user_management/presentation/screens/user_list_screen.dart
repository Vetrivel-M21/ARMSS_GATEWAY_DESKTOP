import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared_widgets/compact_icon_button.dart';
import '../../../../shared_widgets/confirm_dialog.dart';
import '../../../../shared_widgets/gradient_filled_button.dart';
import '../../../../shared_widgets/ledger_table.dart';
import '../../../../shared_widgets/page_header.dart';
import '../../../../shared_widgets/status_badge.dart';
import '../controllers/user_management_controllers.dart';
import '../widgets/user_editor_dialog.dart';

/// Mirrors the old app's user.php: renders every user's plaintext password
/// with a show/hide toggle. This is intentional (matches decision to keep
/// plaintext passwords everywhere), not an oversight.
class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final Set<int> _visiblePasswordIds = {};

  Future<void> _showAddDialog(List<Role> roles) async {
    final result = await showUserEditorDialog(context, roles: roles, initialDepartmentIds: const []);
    if (result == null) return;
    final ok = await ref.read(userActionsControllerProvider.notifier).create(
          username: result.username,
          password: result.password!,
          fullName: result.fullName,
          roleId: result.roleId,
          roleName: result.roleName,
          departmentIds: result.departmentIds,
        );
    if (!ok && mounted) _showError();
  }

  Future<void> _showEditDialog(User user, List<Role> roles) async {
    final initialDepartmentIds = await ref.read(userDepartmentIdsProvider(user.id).future);
    if (!mounted) return;
    final result =
        await showUserEditorDialog(context, existing: user, roles: roles, initialDepartmentIds: initialDepartmentIds);
    if (result == null) return;
    final ok = await ref.read(userActionsControllerProvider.notifier).update(
          id: user.id,
          username: result.username,
          fullName: result.fullName,
          roleId: result.roleId,
          roleName: result.roleName,
          departmentIds: result.departmentIds,
        );
    if (!ok && mounted) _showError();
  }

  Future<void> _showResetPasswordDialog(User user) async {
    final controller = TextEditingController();
    final newPassword = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password — ${user.username}'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'New Password')),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Reset')),
        ],
      ),
    );
    if (newPassword == null || newPassword.isEmpty) return;
    final ok = await ref.read(userActionsControllerProvider.notifier).resetPassword(user.id, newPassword);
    if (!ok && mounted) _showError();
  }

  Future<void> _toggleActive(User user) async {
    final confirmed = await showConfirmDialog(
      context,
      title: user.isActive ? 'Deactivate User' : 'Activate User',
      message: user.isActive
          ? 'Deactivate "${user.username}"? They will no longer be able to log in.'
          : 'Activate "${user.username}"?',
      confirmLabel: user.isActive ? 'Deactivate' : 'Activate',
      destructive: user.isActive,
    );
    if (!confirmed) return;
    final ok = await ref.read(userActionsControllerProvider.notifier).toggleActive(user.id);
    if (!ok && mounted) _showError();
  }

  void _showError() {
    final error = ref.read(userActionsControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error?.message ?? 'Something went wrong.')));
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(watchUsersProvider);
    final rolesAsync = ref.watch(allRolesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Users',
          icon: Icons.people_outline,
          accentColor: const Color(0xFFEC4899),
          actions: [
            rolesAsync.maybeWhen(
              data: (roles) => GradientFilledButton(
                onPressed: () => _showAddDialog(roles),
                icon: Icons.add,
                child: const Text('Add User'),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        Expanded(
          child: rolesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (roles) {
              final roleNameById = {for (final r in roles) r.id: r.name};
              return usersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (users) {
                  if (users.isEmpty) return const Center(child: Text('No users yet.'));
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LedgerTable(
                      columns: const [
                        LedgerColumn('Name', width: FlexColumnWidth(2)),
                        LedgerColumn('Role', width: FixedColumnWidth(140)),
                        LedgerColumn('Password', width: FixedColumnWidth(180)),
                        LedgerColumn('Status', width: FixedColumnWidth(100)),
                        LedgerColumn('Actions', align: TextAlign.right, width: FixedColumnWidth(168)),
                      ],
                      rows: [
                        for (final user in users)
                          TableRow(
                            children: [
                              LedgerCell(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(user.fullName),
                                    const SizedBox(width: 6),
                                    Text('(${user.username})',
                                        style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
                                  ],
                                ),
                              ),
                              LedgerCell(child: Text(roleNameById[user.roleId] ?? '?', maxLines: 1, overflow: TextOverflow.ellipsis)),
                              LedgerCell(child: _PasswordCell(
                                user: user,
                                visible: _visiblePasswordIds.contains(user.id),
                                onToggle: () => setState(() {
                                  if (_visiblePasswordIds.contains(user.id)) {
                                    _visiblePasswordIds.remove(user.id);
                                  } else {
                                    _visiblePasswordIds.add(user.id);
                                  }
                                }),
                              )),
                              LedgerCell(child: user.isActive ? StatusBadge.active() : StatusBadge.inactive()),
                              LedgerCell(
                                align: TextAlign.right,
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CompactIconButton(
                                      icon: Icons.edit_outlined,
                                      onPressed: () => _showEditDialog(user, roles),
                                    ),
                                    CompactIconButton(
                                      icon: Icons.password,
                                      tooltip: 'Reset password',
                                      onPressed: () => _showResetPasswordDialog(user),
                                    ),
                                    CompactIconButton(
                                      icon: user.isActive ? Icons.block : Icons.check_circle_outline,
                                      tooltip: user.isActive ? 'Deactivate' : 'Activate',
                                      onPressed: () => _toggleActive(user),
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
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PasswordCell extends StatelessWidget {
  final User user;
  final bool visible;
  final VoidCallback onToggle;

  const _PasswordCell({required this.user, required this.visible, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          visible ? user.password : '••••••••',
          style: AppTextStyles.monoWith(fontSize: 12, color: AppColors.inkSecondary),
        ),
        IconButton(
          icon: Icon(visible ? Icons.visibility_off : Icons.visibility, size: 16),
          onPressed: onToggle,
        ),
      ],
    );
  }
}
