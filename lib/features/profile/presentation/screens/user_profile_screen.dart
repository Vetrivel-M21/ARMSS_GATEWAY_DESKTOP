import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/rbac/current_user_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/updates/app_update_service.dart';
import '../../../portal_admin/presentation/screens/portal_users_admin_screen.dart';
import '../../../portal_auth/presentation/controllers/portal_auth_controllers.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _oldPassFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  late TextEditingController _departmentController;
  late TextEditingController _branchController;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _otpCodeController = TextEditingController();
  final _otpNewPasswordController = TextEditingController();
  final _otpConfirmPasswordController = TextEditingController();

  bool _initializedProfile = false;
  bool _isSavingProfile = false;

  int _passwordMethodIndex = 0; // 0: Old Password, 1: Email OTP

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSavingPassword = false;

  bool _obscureOtpNew = true;
  bool _obscureOtpConfirm = true;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _otpSent = false;
  int _otpCooldown = 0;
  Timer? _cooldownTimer;

  bool _isCheckingUpdate = false;
  String _currentVersionStr = '1.1.13';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _surfaceCanvas => _isDark ? AppColors.darkSurfaceCanvas : AppColors.surfaceCanvas;
  Color get _surfacePanel => _isDark ? AppColors.darkSurfacePanel : AppColors.surfacePanel;
  Color get _surfaceSunken => _isDark ? AppColors.darkSurfaceSunken : AppColors.surfaceSunken;
  Color get _lineBorder => _isDark ? AppColors.darkLineHairline : AppColors.lineHairline;
  Color get _primaryInk => _isDark ? AppColors.darkInkPrimary : AppColors.inkPrimary;
  Color get _secondaryInk => _isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary;

  @override
  void initState() {
    super.initState();
    getCurrentAppVersion().then((v) {
      if (mounted) setState(() => _currentVersionStr = v);
    });
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _fullNameController = TextEditingController();
    _departmentController = TextEditingController();
    _branchController = TextEditingController();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _departmentController.dispose();
    _branchController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpCodeController.dispose();
    _otpNewPasswordController.dispose();
    _otpConfirmPasswordController.dispose();
    super.dispose();
  }

  void _populateProfile(
    String username,
    String email,
    String fullName,
    String department,
    String branch,
  ) {
    if (!_initializedProfile) {
      _usernameController.text = username;
      _emailController.text = email;
      _fullNameController.text = fullName;
      _departmentController.text = department;
      _branchController.text = branch;
      _initializedProfile = true;
    }
  }

  void _startCooldown() {
    setState(() => _otpCooldown = 120);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpCooldown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _otpCooldown = 0);
      } else {
        if (mounted) setState(() => _otpCooldown--);
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;
    setState(() => _isSavingProfile = true);

    final portalSession = ref.read(portalSessionControllerProvider).valueOrNull;
    final localUser = ref.read(currentUserProvider);

    try {
      if (portalSession != null) {
        final result = await ref
            .read(portalAuthRepositoryProvider)
            .updateProfile(
              token: portalSession.token,
              email: _emailController.text.trim(),
              fullName: _fullNameController.text.trim(),
              department: _departmentController.text.trim(),
              branch: _branchController.text.trim(),
            );
        if (result.isFailure) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.errorOrNull?.message ??
                    'Failed to update profile on server.',
              ),
              backgroundColor: AppColors.signalDebit,
            ),
          );
          setState(() => _isSavingProfile = false);
          return;
        }
      }

      if (localUser != null) {
        try {
          final db = ref.read(appDatabaseProvider);
          await db.userDao.updateUser(
            localUser.id,
            UsersCompanion(
              fullName: drift.Value(_fullNameController.text.trim()),
            ),
          );
        } catch (_) {}
      }

      await ref.read(portalSessionControllerProvider.notifier).refreshSession();
      ref.read(appRefreshSignalProvider.notifier).update((v) => v + 1);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Profile details updated successfully.'),
            ],
          ),
          backgroundColor: AppColors.signalCredit,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: AppColors.signalDebit,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _changePasswordWithOld() async {
    if (!_oldPassFormKey.currentState!.validate()) return;
    setState(() => _isSavingPassword = true);

    final currentPass = _currentPasswordController.text;
    final newPass = _newPasswordController.text.trim();

    final portalSession = ref.read(portalSessionControllerProvider).valueOrNull;
    final localUser = ref.read(currentUserProvider);
    final isPortalAdmin =
        portalSession != null &&
        (portalSession.username.toLowerCase() == 'admin' ||
            portalSession.email.toLowerCase().startsWith('admin@'));
    final isLocalAdmin = localUser?.isAdminOrSuper ?? false;

    try {
      if (portalSession != null) {
        final result = await ref
            .read(portalAuthRepositoryProvider)
            .changePassword(
              token: portalSession.token,
              oldPassword: currentPass,
              newPassword: newPass,
            );
        if (result.isFailure) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.errorOrNull?.message ?? 'Failed to update password.',
              ),
              backgroundColor: AppColors.signalDebit,
            ),
          );
          setState(() => _isSavingPassword = false);
          return;
        }

        // If admin, also update local SQLite password so offline login matches
        if (isPortalAdmin) {
          try {
            final db = ref.read(appDatabaseProvider);
            final adminUser = await db.userDao.byUsername('admin');
            if (adminUser != null) {
              await db.userDao.resetPassword(adminUser.id, newPass);
            }
          } catch (_) {}
        }
      } else if (localUser != null) {
        final db = ref.read(appDatabaseProvider);
        final dbUser = await db.userDao.byId(localUser.id);
        if (dbUser == null || dbUser.password != currentPass) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Current password is incorrect.'),
              backgroundColor: AppColors.signalDebit,
            ),
          );
          setState(() => _isSavingPassword = false);
          return;
        }

        await db.userDao.resetPassword(localUser.id, newPass);

        if (isLocalAdmin) {
          // Sync with central backend
          try {
            await ref
                .read(portalAdminRepositoryProvider)
                .setAdminPassword(newPass);
          } catch (_) {}
        }
      }

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ref.invalidate(isDefaultAdminPasswordProvider);
      ref.read(appRefreshSignalProvider.notifier).update((v) => v + 1);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Password successfully updated across all systems!'),
            ],
          ),
          backgroundColor: AppColors.signalCredit,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error changing password: $e'),
          backgroundColor: AppColors.signalDebit,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSavingPassword = false);
    }
  }

  Future<void> _sendOtp(String targetEmail) async {
    if (targetEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No email address available for OTP delivery.'),
          backgroundColor: AppColors.signalDebit,
        ),
      );
      return;
    }

    setState(() => _isSendingOtp = true);

    try {
      final result = await ref
          .read(portalAuthRepositoryProvider)
          .forgotPasswordRequest(targetEmail);
      if (result.isFailure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorOrNull?.message ?? 'Failed to send OTP.'),
            backgroundColor: AppColors.signalDebit,
          ),
        );
        return;
      }

      setState(() => _otpSent = true);
      _startCooldown();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.mark_email_read_outlined, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'A 6-digit OTP code has been dispatched to $targetEmail.',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.signalCredit,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error dispatching OTP: $e'),
          backgroundColor: AppColors.signalDebit,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _verifyOtpAndChangePassword(String targetEmail) async {
    if (!_otpFormKey.currentState!.validate()) return;
    setState(() => _isVerifyingOtp = true);

    final otp = _otpCodeController.text.trim();
    final newPass = _otpNewPasswordController.text.trim();
    final portalSession = ref.read(portalSessionControllerProvider).valueOrNull;
    final isPortalAdmin =
        portalSession != null &&
        (portalSession.username.toLowerCase() == 'admin' ||
            portalSession.email.toLowerCase().startsWith('admin@'));

    try {
      final result = await ref
          .read(portalAuthRepositoryProvider)
          .forgotPasswordReset(
            email: targetEmail,
            otp: otp,
            newPassword: newPass,
          );

      if (result.isFailure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.errorOrNull?.message ?? 'OTP verification failed.',
            ),
            backgroundColor: AppColors.signalDebit,
          ),
        );
        setState(() => _isVerifyingOtp = false);
        return;
      }

      // If admin, also update local SQLite password so offline login matches
      if (isPortalAdmin || targetEmail.toLowerCase().startsWith('admin@')) {
        try {
          final db = ref.read(appDatabaseProvider);
          final adminUser = await db.userDao.byUsername('admin');
          if (adminUser != null) {
            await db.userDao.resetPassword(adminUser.id, newPass);
          }
        } catch (_) {}
      }

      _otpCodeController.clear();
      _otpNewPasswordController.clear();
      _otpConfirmPasswordController.clear();
      setState(() {
        _otpSent = false;
        _otpCooldown = 0;
      });
      _cooldownTimer?.cancel();

      ref.invalidate(isDefaultAdminPasswordProvider);
      ref.read(appRefreshSignalProvider.notifier).update((v) => v + 1);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('OTP verified! Password successfully changed.'),
            ],
          ),
          backgroundColor: AppColors.signalCredit,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resetting password: $e'),
          backgroundColor: AppColors.signalDebit,
        ),
      );
    } finally {
      if (mounted) setState(() => _isVerifyingOtp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localUser = ref.watch(currentUserProvider);
    final portalSession = ref
        .watch(portalSessionControllerProvider)
        .valueOrNull;

    final isPortalAdmin =
        portalSession != null &&
        (portalSession.username.toLowerCase() == 'admin' ||
            portalSession.email.toLowerCase().startsWith('admin@'));
    final isAdmin = (localUser?.isAdminOrSuper ?? false) || isPortalAdmin;

    final username = portalSession?.username ?? localUser?.username ?? 'admin';
    final email =
        portalSession?.email ?? (isAdmin ? 'armssdirector@gmail.com' : '');
    final currentFullName =
        portalSession?.fullName ?? localUser?.fullName ?? '';
    final currentDepartment = portalSession?.department ?? '';
    final currentBranch = portalSession?.branch ?? '';

    _populateProfile(
      username,
      email,
      currentFullName,
      currentDepartment,
      currentBranch,
    );

    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: _surfaceCanvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: _surfacePanel,
                border: Border(bottom: BorderSide(color: _lineBorder)),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  if (canPop) ...[
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: _primaryInk,
                      ),
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Icon(
                    Icons.account_circle_outlined,
                    color: _primaryInk,
                    size: 28,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Profile & Security',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryInk,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Manage personal details, branch assignments, and update passwords',
                        style: TextStyle(
                          fontSize: 12,
                          color: _secondaryInk,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.scrollBottomPad,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Profile details & App Updates
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              _buildProfileCard(
                                username: username,
                                email: email,
                                roleName: isAdmin ? 'Administrator' : 'Portal User',
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _buildAppearanceCard(context),
                              const SizedBox(height: AppSpacing.lg),
                              _buildAppUpdateCard(context),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        // Right Column: Password security
                        Expanded(
                          flex: 6,
                          child: _buildSecurityCard(
                            email: email,
                            isAdmin: isAdmin,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkForAppUpdate() async {
    setState(() => _isCheckingUpdate = true);
    try {
      final service = AppUpdateService();
      final update = await service.check();
      if (!mounted) return;
      if (update != null) {
        await showDesktopUpdateDialog(
          context,
          updateInfo: update,
          currentVersion: _currentVersionStr,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('ARMSS Gateway is up to date (v$_currentVersionStr)'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update check error: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCheckingUpdate = false);
    }
  }

  Widget _buildAppearanceCard(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _lineBorder),
      ),
      color: _surfacePanel,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.palette_outlined, size: 20, color: Color(0xFFF59E0B)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance & Themes',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _primaryInk),
                      ),
                      Text(
                        'Customize color schemes and display options',
                        style: TextStyle(fontSize: 12, color: _secondaryInk),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Theme Mode row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _surfaceSunken,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _lineBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    size: 18,
                    color: isDark ? const Color(0xFFFBBF24) : _secondaryInk,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isDark ? 'Dark Theme' : 'Light Theme',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _primaryInk),
                    ),
                  ),
                  Switch.adaptive(
                    value: isDark,
                    activeTrackColor: AppColors.accentIndigo,
                    onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppUpdateCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _lineBorder),
      ),
      color: _surfacePanel,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.system_update_rounded, size: 20, color: Color(0xFF10B981)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Version & Updates',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _primaryInk),
                      ),
                      Text(
                        'Installed Version: v$_currentVersionStr',
                        style: TextStyle(fontSize: 12, color: _secondaryInk),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: _lineBorder),
                ),
                icon: _isCheckingUpdate
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 16),
                label: Text(_isCheckingUpdate ? 'Checking Server...' : 'Check for Updates'),
                onPressed: _isCheckingUpdate ? null : _checkForAppUpdate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String username,
    required String email,
    required String roleName,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _lineBorder),
      ),
      color: _surfacePanel,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _profileFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _primaryInk,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _surfacePanel,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryInk,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentLedgerTint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            roleName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentLedger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 32, color: _lineBorder),
              Text(
                'Personal & Work Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _primaryInk,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _usernameController,
                readOnly: true,
                style: TextStyle(color: _primaryInk),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: _secondaryInk),
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  suffixIcon: Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: _secondaryInk,
                  ),
                  helperText: 'Username cannot be changed',
                  helperStyle: TextStyle(color: _secondaryInk),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: _primaryInk),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: _secondaryInk),
                  prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                  suffixIcon: const Icon(
                    Icons.verified_user_outlined,
                    size: 16,
                    color: AppColors.signalCredit,
                  ),
                  hintText: 'e.g. user@example.com',
                  helperText: 'Used for system communications and OTP recovery',
                  helperStyle: TextStyle(color: _secondaryInk),
                ),
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) return 'Email address is required';
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(text)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _fullNameController,
                style: TextStyle(color: _primaryInk),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: _secondaryInk),
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  hintText: 'e.g. John Doe',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Full name is required'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _departmentController,
                style: TextStyle(color: _primaryInk),
                decoration: InputDecoration(
                  labelText: 'Department',
                  labelStyle: TextStyle(color: _secondaryInk),
                  prefixIcon: const Icon(Icons.apartment_outlined, size: 20),
                  hintText: 'e.g. Operations, IT, Finance',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _branchController,
                style: TextStyle(color: _primaryInk),
                decoration: InputDecoration(
                  labelText: 'Branch',
                  labelStyle: TextStyle(color: _secondaryInk),
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                  hintText: 'e.g. Head Office, Chennai, Madurai',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isSavingProfile
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: Text(
                    _isSavingProfile ? 'Saving...' : 'Save Profile Changes',
                  ),
                  onPressed: _isSavingProfile ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityCard({required String email, required bool isAdmin}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _lineBorder),
      ),
      color: _surfacePanel,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: _primaryInk,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Password & Security',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryInk,
                  ),
                ),
                const Spacer(),
                if (isAdmin)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.signalAmber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Centralized Admin Sync',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.signalAmber,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select a verification method to securely update your password.',
              style: TextStyle(fontSize: 12, color: _secondaryInk),
            ),
            const SizedBox(height: AppSpacing.md),
            // Segmented toggle
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _surfaceSunken,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _lineBorder),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _tabButton(
                      index: 0,
                      label: 'Via Current Password',
                      icon: Icons.key_outlined,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _tabButton(
                      index: 1,
                      label: 'Via Email OTP Code',
                      icon: Icons.mark_email_unread_outlined,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 28, color: _lineBorder),
            if (_passwordMethodIndex == 0)
              _buildOldPasswordForm(isAdmin: isAdmin)
            else
              _buildEmailOtpForm(email: email, isAdmin: isAdmin),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _passwordMethodIndex == index;
    return InkWell(
      onTap: () => setState(() => _passwordMethodIndex = index),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _surfacePanel : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected && !_isDark ? AppColors.softShadow(opacity: 0.05) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? _primaryInk : _secondaryInk,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? _primaryInk : _secondaryInk,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOldPasswordForm({required bool isAdmin}) {
    return Form(
      key: _oldPassFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _currentPasswordController,
            obscureText: _obscureCurrent,
            decoration: InputDecoration(
              labelText: 'Current Password',
              prefixIcon: const Icon(Icons.lock_open_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Enter your current password' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNew,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: const Icon(Icons.lock_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'New password cannot be empty';
              }
              if (v.trim().length < 4) {
                return 'Password must be at least 4 characters long';
              }
              if (isAdmin && v.trim() == 'admin123') {
                return 'Cannot use default password "admin123"';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: const Icon(Icons.check_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: _isSavingPassword
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lock_reset_rounded, size: 18),
              label: Text(
                _isSavingPassword ? 'Updating...' : 'Update Password',
              ),
              onPressed: _isSavingPassword ? null : _changePasswordWithOld,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailOtpForm({required String email, required bool isAdmin}) {
    final candidateEmail = _emailController.text.trim();
    final effectiveEmail = candidateEmail.isNotEmpty
        ? candidateEmail
        : (email.isNotEmpty
              ? email
              : (isAdmin ? 'armssdirector@gmail.com' : ''));

    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSunken,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.lineHairline),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.inkSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    effectiveEmail.isNotEmpty
                        ? 'Verification OTP will be sent to registered email:\n$effectiveEmail'
                        : 'No email found for OTP delivery.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.inkPrimary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: (_isSendingOtp || _otpCooldown > 0)
                      ? null
                      : () => _sendOtp(effectiveEmail),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: _isSendingOtp
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _otpCooldown > 0
                              ? 'Resend (${_otpCooldown}s)'
                              : (_otpSent ? 'Resend OTP' : 'Send OTP'),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _otpCodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: '6-Digit OTP Code',
              prefixIcon: Icon(Icons.password_rounded, size: 20),
              counterText: '',
              hintText: 'e.g. 123456',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Enter the 6-digit code received';
              }
              if (v.trim().length != 6) {
                return 'OTP must be 6 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _otpNewPasswordController,
            obscureText: _obscureOtpNew,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: const Icon(Icons.lock_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureOtpNew ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _obscureOtpNew = !_obscureOtpNew),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'New password cannot be empty';
              }
              if (v.trim().length < 4) {
                return 'Password must be at least 4 characters long';
              }
              if (isAdmin && v.trim() == 'admin123') {
                return 'Cannot use default password "admin123"';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _otpConfirmPasswordController,
            obscureText: _obscureOtpConfirm,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: const Icon(Icons.check_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureOtpConfirm ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _obscureOtpConfirm = !_obscureOtpConfirm),
              ),
            ),
            validator: (v) {
              if (v != _otpNewPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: _isVerifyingOtp
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.verified_outlined, size: 18),
              label: Text(
                _isVerifyingOtp
                    ? 'Verifying...'
                    : 'Verify OTP & Change Password',
              ),
              onPressed: _isVerifyingOtp
                  ? null
                  : () => _verifyOtpAndChangePassword(effectiveEmail),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
