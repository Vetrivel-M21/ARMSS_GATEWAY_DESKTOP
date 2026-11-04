import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../features/device_activation/presentation/controllers/device_access_controller.dart';
import '../../features/device_activation/presentation/monthly_reverify_dialog.dart';
import '../../shared_widgets/gradient_filled_button.dart';
import '../../shared_widgets/portal_link_grid.dart';
import 'device_identity_service.dart';
import 'device_token_repository.dart';

/// Opens portal web application links.
///
/// If monthly security verification is required or awaiting admin approval,
/// navigation is blocked on the desktop side and an informative dialog is shown.
Future<void> launchGatedPortalLink(
  BuildContext context,
  PortalLink link,
) async {
  final identityService = DeviceIdentityService();
  final identity = await identityService.getIdentity();
  final deviceId = await identityService.getDeviceId();
  final token = identity?.token;

  // Check current controller state
  if (context.mounted) {
    try {
      final access = ProviderScope.containerOf(context)
          .read(deviceAccessControllerProvider);

      final isMonthlyPending = access.isMonthlyApprovalPending ||
          access.reason == 'monthly_approval_pending';
      final isOtpRequired = access.isOtpReverifyRequired ||
          access.reason == 'otp_reverification_required';

      if (isMonthlyPending) {
        _showPendingApprovalDialog(context, deviceId);
        return;
      }

      if (isOtpRequired) {
        _showOtpRequiredDialog(context, deviceId);
        return;
      }
    } catch (_) {}
  }

  if (identity == null || token == null || token.isEmpty) {
    if (context.mounted) {
      try {
        ProviderScope.containerOf(context)
            .read(deviceAccessControllerProvider.notifier)
            .markRevoked(reason: 'no_token', deviceId: deviceId);
      } catch (_) {}
    }
    await _openUrl(link.url, deviceId: deviceId, token: token);
    return;
  }

  // Pre-validate token synchronously before launching
  final repository = DeviceTokenRepository();
  final result = await repository.validateToken(
    deviceId: identity.deviceId,
    token: token,
  );

  if (result.isSuccess && !result.valueOrNull!.isValid) {
    final reason = result.valueOrNull!.reason ?? 'revoked_by_admin';
    if (context.mounted) {
      try {
        ProviderScope.containerOf(context)
            .read(deviceAccessControllerProvider.notifier)
            .markRevoked(
              reason: reason,
              deviceId: identity.deviceId,
            );
      } catch (_) {}

      if (reason == 'monthly_approval_pending') {
        _showPendingApprovalDialog(context, identity.deviceId);
        return;
      } else if (reason == 'otp_reverification_required') {
        _showOtpRequiredDialog(context, identity.deviceId);
        return;
      }
    }
  }

  await _openUrl(link.url, deviceId: identity.deviceId, token: token);
}

void _showPendingApprovalDialog(BuildContext context, String deviceId) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.hourglass_top_rounded, color: AppColors.signalAmber, size: 24),
          SizedBox(width: AppSpacing.md),
          Text('Admin Approval Required', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your monthly OTP code has been verified, but access to company web portals is locked while waiting for administrator approval.',
            style: TextStyle(fontSize: 13, color: AppColors.inkPrimary),
          ),
          SizedBox(height: 10),
          Text(
            'Please ask your administrator to approve your monthly verification request, then click "Check Status" to restore access.',
            style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close'),
        ),
        GradientFilledButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            try {
              final approved = await ProviderScope.containerOf(context)
                  .read(deviceAccessControllerProvider.notifier)
                  .pollMonthlyApproval();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      approved
                          ? 'Admin approved! Web portals are now accessible.'
                          : 'Still pending administrator approval. Please check again shortly.',
                    ),
                    backgroundColor: approved
                        ? AppColors.signalSuccess
                        : AppColors.signalAmber,
                  ),
                );
              }
            } catch (_) {}
          },
          child: const Text('Check Status'),
        ),
      ],
    ),
  );
}

void _showOtpRequiredDialog(BuildContext context, String deviceId) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.security, color: AppColors.accentLedger, size: 24),
          SizedBox(width: AppSpacing.md),
          Text('Security Verification Required', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Routine 30-day security verification is due before you can open company web portals.',
            style: TextStyle(fontSize: 13, color: AppColors.inkPrimary),
          ),
          SizedBox(height: 10),
          Text(
            'Please verify via email OTP and request administrator approval to continue.',
            style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        GradientFilledButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (_) => MonthlyReverifyDialog(deviceId: deviceId),
            );
          },
          child: const Text('Verify OTP Now'),
        ),
      ],
    ),
  );
}

Future<void> _openUrl(
  String targetUrl, {
  String? deviceId,
  String? token,
}) async {
  Uri uri = Uri.parse(targetUrl);
  if (deviceId != null && token != null && token.isNotEmpty) {
    final qp = Map<String, String>.from(uri.queryParameters);
    qp['gateway_device_id'] = deviceId;
    qp['gateway_token'] = token;
    uri = uri.replace(queryParameters: qp);
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
