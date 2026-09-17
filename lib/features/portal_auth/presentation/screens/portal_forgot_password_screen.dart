import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/portal_auth_controllers.dart';

/// Two-step OTP-verified password reset: request an OTP by email, then
/// submit that OTP with a new password.
class PortalForgotPasswordScreen extends ConsumerStatefulWidget {
  const PortalForgotPasswordScreen({super.key});

  @override
  ConsumerState<PortalForgotPasswordScreen> createState() =>
      _PortalForgotPasswordScreenState();
}

class _PortalForgotPasswordScreenState
    extends ConsumerState<PortalForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _otpRequested = false;
  bool _isSubmitting = false;
  int _otpCooldown = 0;
  Timer? _cooldownTimer;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
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

  Future<void> _requestOtp() async {
    if (_emailController.text.trim().isEmpty) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    await ref
        .read(portalAuthRepositoryProvider)
        .forgotPasswordRequest(_emailController.text.trim());
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _otpRequested = true;
    });
    _startCooldown();
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final result = await ref
        .read(portalAuthRepositoryProvider)
        .forgotPasswordReset(
          email: _emailController.text.trim(),
          otp: _otpController.text.trim(),
          newPassword: _newPasswordController.text,
        );
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset — you can now log in with your new password.',
          ),
        ),
      );
      return;
    }
    setState(() {
      _isSubmitting = false;
      _errorMessage = result.errorOrNull?.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      enabled: !_otpRequested,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Email is required'
                          : null,
                    ),
                    if (_otpRequested) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'An OTP has been emailed to ${_emailController.text.trim()} if that account exists.',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          TextButton(
                            onPressed: (_isSubmitting || _otpCooldown > 0)
                                ? null
                                : _requestOtp,
                            child: Text(
                              _otpCooldown > 0
                                  ? 'Resend (${_otpCooldown}s)'
                                  : 'Resend OTP',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _otpController,
                        decoration: const InputDecoration(labelText: 'OTP'),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'OTP is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'New password is required'
                            : null,
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSubmitting
                          ? null
                          : (_otpRequested ? _reset : _requestOtp),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_otpRequested ? 'Reset Password' : 'Send OTP'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
