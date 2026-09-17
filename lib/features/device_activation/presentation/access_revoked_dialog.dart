import 'package:flutter/material.dart';

import '../../../../core/device_auth/device_identity_service.dart';
import '../../../../core/device_auth/device_token_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared_widgets/gradient_filled_button.dart';

class AccessRevokedDialog extends StatefulWidget {
  final String domainRequested;
  final String deviceId;
  final String? initialReason;

  const AccessRevokedDialog({
    super.key,
    required this.domainRequested,
    required this.deviceId,
    this.initialReason,
  });

  @override
  State<AccessRevokedDialog> createState() => _AccessRevokedDialogState();
}

class _AccessRevokedDialogState extends State<AccessRevokedDialog> {
  final _repository = DeviceTokenRepository();
  final _identityService = DeviceIdentityService();

  bool _isLoading = false;
  String? _statusMessage;
  bool _hasRequested = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    setState(() => _isLoading = true);
    final result = await _repository.checkActivation(deviceId: widget.deviceId);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      final data = result.valueOrNull!;
      if (data.status == 'approved' &&
          data.token != null &&
          data.token!.isNotEmpty) {
        await _identityService.saveToken(
          data.token!,
          deviceId: widget.deviceId,
        );
        if (!mounted) return;
        Navigator.of(context).pop(true);
        return;
      }
      if (data.status == 'pending') {
        setState(() {
          _hasRequested = true;
          _statusMessage =
              'An activation request is currently pending admin approval.';
        });
      } else if (data.status == 'rejected') {
        setState(() {
          _hasRequested = false;
          _statusMessage =
              'Previous activation request was rejected: ${data.reason ?? "Contact your administrator."}';
        });
      }
    }
  }

  Future<void> _requestActivation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.requestActivation(
      deviceId: widget.deviceId,
      domainRequested: widget.domainRequested,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      setState(() {
        _hasRequested = true;
        _statusMessage = 'Activation request submitted successfully! Waiting for admin approval.';
      });
    } else {
      setState(() {
        _errorMessage =
            result.errorOrNull?.message ??
            'Failed to submit activation request.';
      });
    }
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.checkActivation(deviceId: widget.deviceId);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      final data = result.valueOrNull!;
      if (data.status == 'approved' &&
          data.token != null &&
          data.token!.isNotEmpty) {
        await _identityService.saveToken(
          data.token!,
          deviceId: widget.deviceId,
        );
        if (!mounted) return;
        Navigator.of(context)
            .pop(true); // Return true to indicate newly active token!
      } else if (data.status == 'pending') {
        setState(() {
          _statusMessage =
              'Still pending. Admin has not approved this request yet.';
        });
      } else if (data.status == 'rejected') {
        setState(() {
          _hasRequested = false;
          _statusMessage =
              'Request was rejected: ${data.reason ?? "No reason specified."}';
        });
      } else {
        setState(() {
          _hasRequested = false;
          _statusMessage = 'No active request found. Please submit a request.';
        });
      }
    } else {
      setState(() {
        _errorMessage =
            result.errorOrNull?.message ??
            'Failed to verify activation status.';
      });
    }
  }

  Future<void> _reRegisterDevice() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final newIdentity = await _identityService.registerDeviceOnServer();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (newIdentity != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device registered successfully!')),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage =
            'Could not register device with server. Please check your network connection or contact your administrator.';
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
              color: AppColors.signalError.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.block_rounded,
              color: AppColors.signalError,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Text(
            'Access Revoked',
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
            Text(
              'Your access to "${widget.domainRequested}" is currently blocked or your device token has been revoked by an administrator.',
              style: const TextStyle(fontSize: 13, color: AppColors.inkPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
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
                    Icons.devices,
                    size: 18,
                    color: AppColors.inkSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Device ID: ${widget.deviceId}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'IBM Plex Mono',
                        color: AppColors.inkSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.accentLedgerTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.accentLedger,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.signalError,
                ),
              ),
              if (_errorMessage!.toLowerCase().contains('device not found')) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  icon: const Icon(Icons.sync, size: 16),
                  label: const Text('Register / Reconnect This Device'),
                  onPressed: _isLoading ? null : _reRegisterDevice,
                ),
              ],
            ],
            if (_isLoading) ...[
              const SizedBox(height: AppSpacing.lg),
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
          child: const Text('Close'),
        ),
        if (!_hasRequested)
          GradientFilledButton(
            onPressed: _isLoading ? null : _requestActivation,
            child: const Text('Request Activation'),
          )
        else
          GradientFilledButton(
            onPressed: _isLoading ? null : _checkStatus,
            child: const Text('Check Status'),
          ),
      ],
    );
  }
}
