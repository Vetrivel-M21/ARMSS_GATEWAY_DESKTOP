import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../../../core/config/trust_app_client.dart';
import '../../../../shared_widgets/gradient_filled_button.dart';
import '../../../../shared_widgets/page_header.dart';
import '../../domain/entities/device_token.dart';
import '../controllers/trust_portal_controllers.dart';

/// Embeds the Trust Management web app in-app. The React app only works
/// through this tab: the device token obtained from `TrustPortalTokenController`
/// is injected into the page's `sessionStorage` before its own scripts run, and
/// the backend rejects every API call that doesn't carry it — a plain browser
/// hitting the same URL has no way to get that token.
class TrustPortalScreen extends ConsumerStatefulWidget {
  const TrustPortalScreen({super.key});

  @override
  ConsumerState<TrustPortalScreen> createState() => _TrustPortalScreenState();
}

class _TrustPortalScreenState extends ConsumerState<TrustPortalScreen> {
  final _controller = WebviewController();
  ScriptID? _scriptId;
  bool _webviewReady = false;
  Object? _loadError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _setTokenScript(String token) => "window.sessionStorage.setItem('device_token', '$token');";

  Future<void> _loadWithToken(String token) async {
    try {
      await _controller.initialize();
      _scriptId = await _controller.addScriptToExecuteOnDocumentCreated(_setTokenScript(token));
      // The query param is only needed on this first navigation — the dev
      // server sets a cookie once it validates it, which the WebView then
      // resends automatically on every request afterward.
      await _controller.loadUrl('${TrustAppClient.portalUrl}?entry_secret=${TrustAppClient.clientSecret}');
      if (mounted) setState(() => _webviewReady = true);
    } catch (e) {
      if (mounted) setState(() => _loadError = e);
    }
  }

  Future<void> _refreshToken(String token) async {
    await _controller.executeScript(_setTokenScript(token));
    final oldScriptId = _scriptId;
    _scriptId = await _controller.addScriptToExecuteOnDocumentCreated(_setTokenScript(token));
    if (oldScriptId != null) {
      await _controller.removeScriptToExecuteOnDocumentCreated(oldScriptId);
    }
  }

  Future<void> _openInBrowser(String token) async {
    final url = '${TrustAppClient.portalUrl}?entry_secret=${TrustAppClient.clientSecret}&device_token=$token';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<DeviceToken>>(trustPortalTokenControllerProvider, (previous, next) {
      next.whenData((deviceToken) {
        if (!_webviewReady) {
          _loadWithToken(deviceToken.token);
        } else if (previous?.valueOrNull?.token != deviceToken.token) {
          _refreshToken(deviceToken.token);
        }
      });
    });

    final tokenAsync = ref.watch(trustPortalTokenControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Trust Portal',
          icon: Icons.account_balance_outlined,
          accentColor: const Color(0xFFF97316),
          actions: [
            OutlinedButton.icon(
              onPressed: tokenAsync.valueOrNull == null ? null : () => _openInBrowser(tokenAsync.valueOrNull!.token),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open in Browser'),
            ),
          ],
        ),
        Expanded(
          child: _loadError != null
              ? _ErrorState(message: 'Could not load the Trust Portal: $_loadError')
              : tokenAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _ErrorState(message: 'Could not connect to the Trust Management server: $e'),
                  data: (_) => _webviewReady ? Webview(_controller) : const Center(child: CircularProgressIndicator()),
                ),
        ),
      ],
    );
  }
}

class _ErrorState extends ConsumerWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Text(message, textAlign: TextAlign.center)),
          const SizedBox(height: 16),
          GradientFilledButton(
            onPressed: () => ref.invalidate(trustPortalTokenControllerProvider),
            icon: Icons.refresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
