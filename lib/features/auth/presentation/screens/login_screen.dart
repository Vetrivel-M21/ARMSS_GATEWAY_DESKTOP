import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/updates/app_update_service.dart';
import '../../../portal_auth/presentation/controllers/portal_auth_controllers.dart';
import '../../../portal_auth/presentation/screens/portal_forgot_password_screen.dart';
import '../../../portal_auth/presentation/screens/portal_register_screen.dart';

/// The one login screen for the whole app. Local ledger accounts (username)
/// and self-registered portal accounts (email) both log in here: local login
/// is tried first, and only falls back to a portal-account login if that
/// fails — a person only ever has one or the other.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final identifier = _usernameController.text.trim();
    final password = _passwordController.text;

    final portalResult = await ref
        .read(portalSessionControllerProvider.notifier)
        .login(identifier: identifier, password: password);

    if (portalResult.isSuccess) {
      return; // portal login succeeded — MisApp reacts to portalSessionControllerProvider
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _errorMessage = portalResult.errorOrNull?.message ?? 'Invalid username/email or password.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Card(
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.asset('assets/images/login_logo.png', height: 100),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(labelText: 'Username or Email'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Username or email is required' : null,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Log In'),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) => const PortalRegisterScreen())),
                              child: const Text('Register'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) => const PortalForgotPasswordScreen())),
                              child: const Text('Forgot password?'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
            left: 20,
            bottom: 16,
            child: FutureBuilder<String>(
              future: getCurrentAppVersion(),
              initialData: currentAppVersion,
              builder: (context, snapshot) {
                final version = snapshot.data ?? currentAppVersion;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: AppColors.inkSecondary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'v$version',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkSecondary.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
