import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared_widgets/gradient_filled_button.dart';
import '../controllers/portal_auth_controllers.dart';

/// Self-registration: username/email/password/name. No OTP step — the
/// account stays inactive until an admin approves it (and separately grants
/// specific links) from the Portal Users screen.
class PortalRegisterScreen extends ConsumerStatefulWidget {
  const PortalRegisterScreen({super.key});

  @override
  ConsumerState<PortalRegisterScreen> createState() =>
      _PortalRegisterScreenState();
}

class _PortalRegisterScreenState extends ConsumerState<PortalRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _branchController = TextEditingController();
  bool _obscurePassword = true;

  bool _isSubmitting = false;
  bool _registered = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _departmentController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final result = await ref
        .read(portalAuthRepositoryProvider)
        .register(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          department: _departmentController.text.trim(),
          branch: _branchController.text.trim(),
        );
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      if (result.isSuccess) {
        _registered = true;
      } else {
        _errorMessage = result.errorOrNull?.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkPrimary,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accentLedgerTint, AppColors.surfaceCanvas],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: AppColors.surfacePanel,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.softShadow(opacity: 0.10),
                  ),
                  child: _registered
                      ? _buildPendingApproval(context)
                      : _buildForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingApproval(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.accentLedger, AppColors.accentLedgerLight],
            ),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Account Created',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'An admin will approve your account within 1 working day. You can log in once it\'s approved.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.inkSecondary),
        ),
        const SizedBox(height: 28),
        GradientFilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          final intro = _buildFormIntro();
          final fields = _buildFormFields(context);

          return isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: intro),
                    const SizedBox(width: 44),
                    Expanded(child: fields),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [intro, const SizedBox(height: 28), fields],
                );
        },
      ),
    );
  }

  Widget _buildFormIntro() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.accentLedger, AppColors.accentLedgerLight],
            ),
          ),
          child: const Icon(
            Icons.person_add_alt_1_outlined,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Create Your Account',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        const Text(
          'Register for portal access. An administrator will review your account and grant access to the appropriate links.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.inkSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Username is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Email is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'Designation / Role',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Designation / Role is required'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _departmentController,
          decoration: const InputDecoration(
            labelText: 'Department',
            prefixIcon: Icon(Icons.account_tree_outlined),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Department is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _branchController,
          decoration: const InputDecoration(
            labelText: 'Branch',
            prefixIcon: Icon(Icons.business_outlined),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Branch is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Password is required' : null,
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 14),
          Text(
            _errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 28),
        _isSubmitting
            ? const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : GradientFilledButton(
                onPressed: _register,
                icon: Icons.arrow_forward,
                child: const Text('Register'),
              ),
      ],
    );
  }
}
