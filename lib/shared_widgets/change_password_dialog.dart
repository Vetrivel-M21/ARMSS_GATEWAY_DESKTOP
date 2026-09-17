import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/di/providers.dart';
import '../core/rbac/current_user_provider.dart';
import '../core/theme/app_theme.dart';
import '../features/portal_admin/presentation/screens/portal_users_admin_screen.dart';
import '../features/portal_auth/presentation/controllers/portal_auth_controllers.dart';

/// Shows the Admin/User Change Password modal dialog.
Future<void> showChangePasswordDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const ChangePasswordDialog(),
  );
}

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final currentPass = _currentPasswordController.text;
    final newPass = _newPasswordController.text.trim();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final localUser = ref.read(currentUserProvider);
    final portalSession = ref.read(portalSessionControllerProvider).valueOrNull;

    try {
      if (localUser != null) {
        // Verify current password against local database
        final db = ref.read(appDatabaseProvider);
        final dbUser = await db.userDao.byId(localUser.id);
        if (dbUser == null) {
          setState(() {
            _isSaving = false;
            _errorMessage = 'User record not found in local database.';
          });
          return;
        }

        if (dbUser.password != currentPass) {
          setState(() {
            _isSaving = false;
            _errorMessage = 'Current password is incorrect.';
          });
          return;
        }

        // Update password in local database
        await db.userDao.resetPassword(localUser.id, newPass);

        // Invalidate providers so banners and sessions refresh
        ref.invalidate(isDefaultAdminPasswordProvider);
        ref.read(appRefreshSignalProvider.notifier).update((v) => v + 1);
      } else if (portalSession != null && portalSession.userId != null) {
        // Portal admin session
        final result = await ref
            .read(portalAdminRepositoryProvider)
            .setPassword(userId: portalSession.userId!, newPassword: newPass);

        if (result.isFailure) {
          setState(() {
            _isSaving = false;
            _errorMessage = result.errorOrNull?.message ?? 'Failed to update portal password.';
          });
          return;
        }
      } else {
        setState(() {
          _isSaving = false;
          _errorMessage = 'No active user session detected.';
        });
        return;
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Password updated successfully.'),
            ],
          ),
          backgroundColor: AppColors.signalCredit,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Error saving password: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localUser = ref.watch(currentUserProvider);
    final portalSession = ref.watch(portalSessionControllerProvider).valueOrNull;
    final username = localUser?.username ?? portalSession?.username ?? 'Admin';
    final isDefaultAsync = ref.watch(isDefaultAdminPasswordProvider);
    final isDefault = isDefaultAsync.valueOrNull ?? false;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 440,
        color: AppColors.surfacePanel,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Lock Icon and Title
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accentLedgerTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.accentLedger,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Password — $username',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.inkPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Update your administrator account credentials',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Default password warning tag if applicable
              if (isDefault) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.signalAmber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.signalAmber.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.signalAmber,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'You are currently using the default password ("admin123"). Please set a strong, unique password for production.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.signalAmber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Error alert banner if any
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.signalError.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.signalError.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.signalError,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.signalError,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Current Password Field
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  hintText: isDefault ? 'admin123' : 'Enter current password',
                  prefixIcon: const Icon(Icons.key_outlined, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Current password is required.';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // New Password Field
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Minimum 6 characters',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'New password is required.';
                  if (v.trim().length < 6) return 'Password must be at least 6 characters.';
                  if (v.trim() == 'admin123') return 'Cannot use the default password "admin123".';
                  if (v.trim() == _currentPasswordController.text) {
                    return 'New password must be different from current password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Confirm New Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  hintText: 'Re-enter new password',
                  prefixIcon: const Icon(Icons.check_circle_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please confirm your new password.';
                  if (v.trim() != _newPasswordController.text.trim()) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentLedger,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onPressed: _isSaving ? null : _submit,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(_isSaving ? 'Updating...' : 'Save Password'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

