import 'package:flutter/material.dart';

import '../../../../core/device_auth/device_token_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared_widgets/gradient_filled_button.dart';

class MonthlyReverifyDialog extends StatefulWidget {
  final String deviceId;

  const MonthlyReverifyDialog({super.key, required this.deviceId});

  @override
  State<MonthlyReverifyDialog> createState() => _MonthlyReverifyDialogState();
}

class _MonthlyReverifyDialogState extends State<MonthlyReverifyDialog> {
  final _repository = DeviceTokenRepository();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String? _requestId;
  String? _maskedEmail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.requestMonthlyOtp(
      deviceId: widget.deviceId,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      final res = result.valueOrNull!;
      setState(() {
        _requestId = res.requestId;
        _maskedEmail = res.sentTo;
      });
    } else {
      setState(() {
        _errorMessage =
            result.errorOrNull?.message ?? 'Failed to send verification code.';
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) {
      setState(() => _errorMessage = 'Please enter a valid 6-digit OTP code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.verifyMonthlyOtp(
      deviceId: widget.deviceId,
      requestId: _requestId ?? '',
      otp: otp,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess && result.valueOrNull == true) {
      Navigator.of(context)
          .pop(true); // Return true to indicate successful unlock
    } else {
      setState(() {
        _errorMessage =
            'Incorrect or expired verification code. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentLedger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.security,
              color: AppColors.accentLedger,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Text(
            'Security Verification',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your installation requires a routine 30-day security re-verification before accessing company web tools.',
              style: TextStyle(fontSize: 13, color: AppColors.inkPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_maskedEmail != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lineHairline),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 18,
                      color: AppColors.accentLedger,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Code sent to: $_maskedEmail',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _sendOtp,
                      child: const Text(
                        'Resend',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(
                letterSpacing: 6,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                labelText: '6-Digit OTP Code',
                hintText: '123456',
                border: OutlineInputBorder(),
                counterText: '',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              onSubmitted: (_) => _verifyOtp(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.signalError,
                ),
              ),
            ],
            if (_isLoading) ...[
              const SizedBox(height: AppSpacing.md),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        GradientFilledButton(
          onPressed: _isLoading ? null : _verifyOtp,
          child: const Text('Verify & Unlock'),
        ),
      ],
    );
  }
}
