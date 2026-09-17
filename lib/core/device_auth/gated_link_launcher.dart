import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/device_activation/presentation/controllers/device_access_controller.dart';
import '../../shared_widgets/portal_link_grid.dart';
import 'device_identity_service.dart';
import 'device_token_repository.dart';

/// Opens portal web application links.
///
/// Does not restrict navigation on the desktop side:
/// The web application's own token validation middleware verifies access on load.
/// If access is revoked, this updates the top notification banner with the
/// "Request Activation" button, while still allowing the browser to open.
Future<void> launchGatedPortalLink(
  BuildContext context,
  PortalLink link,
) async {
  final identityService = DeviceIdentityService();
  final identity = await identityService.getIdentity();
  final deviceId = await identityService.getDeviceId();
  final token = identity?.token;

  if (identity == null || token == null || token.isEmpty) {
    if (context.mounted) {
      try {
        ProviderScope.containerOf(context)
            .read(deviceAccessControllerProvider.notifier)
            .markRevoked(reason: 'no_token', deviceId: deviceId);
      } catch (_) {}
    }
    // Launch external browser anyway; web app token validation handles the block
    await _openUrl(link.url, deviceId: deviceId, token: token);
    return;
  }

  // Validate in background to update the desktop notification bar
  final repository = DeviceTokenRepository();
  repository.validateToken(
    deviceId: identity.deviceId,
    token: token,
  ).then((result) {
    if (result.isSuccess && !result.valueOrNull!.isValid) {
      if (context.mounted) {
        try {
          ProviderScope.containerOf(context)
              .read(deviceAccessControllerProvider.notifier)
              .markRevoked(
                reason: result.valueOrNull!.reason ?? 'revoked_by_admin',
                deviceId: identity.deviceId,
              );
        } catch (_) {}
      }
    }
  });

  // Always launch the external browser without restricting the user:
  await _openUrl(link.url, deviceId: identity.deviceId, token: token);
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
