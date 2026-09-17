import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../departments/presentation/controllers/department_controllers.dart';

class UserEditorResult {
  final String username;
  final String fullName;
  final String? password;
  final int roleId;
  final String roleName;
  final List<int> departmentIds;

  UserEditorResult({
    required this.username,
    required this.fullName,
    required this.password,
    required this.roleId,
    required this.roleName,
    required this.departmentIds,
  });
}

/// Shared add/edit form. When [existing] is null this is a "create user"
/// dialog (password required); otherwise it's an "edit user" dialog
/// (username/full name/role/departments only — password reset is a
/// separate action, matching the old app's separate `reset_pw`).
Future<UserEditorResult?> showUserEditorDialog(
  BuildContext context, {
  User? existing,
  required List<Role> roles,
  required List<int> initialDepartmentIds,
}) {
  return showDialog<UserEditorResult>(
    context: context,
    builder: (context) => _UserEditorDialog(existing: existing, roles: roles, initialDepartmentIds: initialDepartmentIds),
  );
}

class _UserEditorDialog extends ConsumerStatefulWidget {
  final User? existing;
  final List<Role> roles;
  final List<int> initialDepartmentIds;

  const _UserEditorDialog({required this.existing, required this.roles, required this.initialDepartmentIds});

  @override
  ConsumerState<_UserEditorDialog> createState() => _UserEditorDialogState();
}

class _UserEditorDialogState extends ConsumerState<_UserEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController =
      TextEditingController(text: widget.existing?.username ?? '');
  late final TextEditingController _fullNameController =
      TextEditingController(text: widget.existing?.fullName ?? '');
  final _passwordController = TextEditingController();
  late int _roleId = widget.existing?.roleId ?? widget.roles.first.id;
  late final Set<int> _selectedDepartmentIds = widget.initialDepartmentIds.toSet();

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final departmentsAsync = ref.watch(watchDepartmentsProvider);
    final selectedRoleName = widget.roles.firstWhere((r) => r.id == _roleId).name;
    final isUserRole = selectedRoleName == 'user';

    return AlertDialog(
      title: Text(_isEdit ? 'Edit User' : 'Add User'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                if (!_isEdit) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _roleId,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: widget.roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
                  onChanged: (v) => setState(() => _roleId = v!),
                ),
                if (isUserRole) ...[
                  const SizedBox(height: 12),
                  const Text('Departments', style: TextStyle(fontWeight: FontWeight.w600)),
                  departmentsAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                    data: (departments) => Wrap(
                      spacing: 8,
                      children: departments.map((d) {
                        final selected = _selectedDepartmentIds.contains(d.id);
                        return FilterChip(
                          label: Text(d.name),
                          selected: selected,
                          onSelected: (v) => setState(() {
                            if (v) {
                              _selectedDepartmentIds.add(d.id);
                            } else {
                              _selectedDepartmentIds.remove(d.id);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(UserEditorResult(
              username: _usernameController.text.trim(),
              fullName: _fullNameController.text.trim(),
              password: _isEdit ? null : _passwordController.text,
              roleId: _roleId,
              roleName: selectedRoleName,
              departmentIds: isUserRole ? _selectedDepartmentIds.toList() : const [],
            ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
