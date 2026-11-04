import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device_auth/device_token_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared_widgets/gradient_filled_button.dart';
import 'controllers/device_access_controller.dart';

class MonthlyReverifyDialog extends ConsumerStatefulWidget {
  final String deviceId;

  const MonthlyReverifyDialog({super.key, required this.deviceId});

  @override
  ConsumerState<MonthlyReverifyDialog> createState() =>
      _MonthlyReverifyDialogState();
}

class _MonthlyReverifyDialogState extends ConsumerState<MonthlyReverifyDialog> {
  final _repository = DeviceTokenRepository();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String? _requestId;
  String? _maskedEmail;
  String? _errorMessage;

  // Flow stages:
  // 1: OTP Entry
  // 2: Need Admin Approval (OTP verified, awaiting user click on 'Request Approve')
  // 3: Request Submitted (waiting for admin to approve)
  bool _isOtpVerified = false;
  bool _isApprovalSubmitted = false;

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
      // OTP verified! Transition to "Need Admin Approval" stage
      setState(() {
        _isOtpVerified = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage =
            'Incorrect or expired verification code. Please check your email and try again.';
      });
    }
  }

  Future<void> _requestApproval() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.requestMonthlyApproval(
      deviceId: widget.deviceId,
      requestId: _requestId ?? '',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess && result.valueOrNull == true) {
      ref
          .read(deviceAccessControllerProvider.notifier)
          .setMonthlyApprovalPending(_requestId ?? '');

      setState(() {
        _isApprovalSubmitted = true;
      });
    } else {
      setState(() {
        _errorMessage =
            result.errorOrNull?.message ?? 'Failed to submit approval request.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isApprovalSubmitted) {
      return _buildSubmittedView();
    }
    if (_isOtpVerified) {
      return _buildNeedAdminApprovalView();
    }
    return _buildOtpEntryView();
  }

  // ── Stage 1: Enter OTP sent to user email ──────────────────────────────────
  Widget _buildOtpEntryView() {
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
        width: 440,
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
                        'Code sent to your email: $_maskedEmail',
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
          child: const Text('Verify OTP'),
        ),
      ],
    );
  }

  // ── Stage 2: Need Admin Approval Dialog ────────────────────────────────────
  Widget _buildNeedAdminApprovalView() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.signalAmber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: AppColors.signalAmber,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Text(
            'Need Admin Approval',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.signalSuccess.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.signalSuccess.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.signalSuccess,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Email OTP verified successfully!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.signalSuccess,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Administrator approval is now required to restore access to company web portals.',
              style: TextStyle(fontSize: 13, color: AppColors.inkPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Click "Request Approve" below to submit this verification request to the administrator. In the meantime, access to web portals remains restricted.',
              style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
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
          onPressed: _isLoading ? null : _requestApproval,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.send_rounded, size: 16),
              SizedBox(width: 6),
              Text('Request Approve'),
            ],
          ),
        ),
      ],
    );
  }

  // ── Stage 3: Request Submitted Confirmation ────────────────────────────────
  Widget _buildSubmittedView() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.signalAmber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: AppColors.signalAmber,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Text(
            'Request Sent to Admin',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: const SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your monthly verification request has been successfully sent to the administrator.',
              style: TextStyle(fontSize: 13, color: AppColors.inkPrimary),
            ),
            SizedBox(height: 10),
            Text(
              'In the meantime, access to web portals remains locked. Once the admin approves your request, click the "Check Status" button in the header bar to unlock access.',
              style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
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
        GradientFilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
