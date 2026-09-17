import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/device_access_controller.dart';

/// A persistent notification strip displayed immediately below the App Bar
/// whenever device token access is revoked or an activation request is pending.
class DeviceRevocationBanner extends ConsumerWidget {
  const DeviceRevocationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(deviceAccessControllerProvider);

    if (!access.isRevoked) {
      return const SizedBox.shrink();
    }

    final isPending = access.requestStatus == 'pending';
    final isRejected = access.requestStatus == 'rejected';

    final Color borderColor = isPending
        ? AppColors.signalAmber
        : AppColors.signalError;
    final Color bgColor = isPending
        ? AppColors.signalAmber.withValues(alpha: 0.08)
        : AppColors.signalError.withValues(alpha: 0.08);
    final IconData icon = isPending
        ? Icons.hourglass_top_rounded
        : Icons.gpp_bad_outlined;

    String title;
    if (isPending) {
      title = 'Activation Request Pending Administrator Approval';
    } else if (isRejected) {
      title = 'Access Revoked — Activation Request Rejected';
    } else {
      title = 'Portal Access Revoked';
    }

    String details;
    if (isPending) {
      details =
          'An access request for this device has been sent to the administrator. Device ID: ${access.deviceId}';
    } else if (isRejected && access.rejectionReason != null) {
      details =
          'Your previous request was rejected: "${access.rejectionReason}". Device ID: ${access.deviceId}';
    } else {
      details =
          'Your device access token has been revoked by an administrator. Device ID: ${access.deviceId}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
          bottom: BorderSide(
            color: borderColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: borderColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isPending
                        ? const Color(0xFF92400E)
                        : const Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: TextStyle(
                    fontSize: 12,
                    color: isPending
                        ? const Color(0xFFB45309)
                        : const Color(0xFFB91C1C),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (access.isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (isPending)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.signalAmber,
                side: const BorderSide(color: AppColors.signalAmber),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(Icons.sync, size: 16),
              label: const Text('Check Status'),
              onPressed: () =>
                  ref.read(deviceAccessControllerProvider.notifier).pollApproval(),
            )
          else
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.signalError,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(Icons.vpn_key_outlined, size: 16),
              label: const Text('Request Activation'),
              onPressed: () => ref
                  .read(deviceAccessControllerProvider.notifier)
                  .requestActivation(),
            ),
        ],
      ),
    );
  }
}

