import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/device_auth/gated_link_launcher.dart';
import '../../../../core/portal_links/portal_link_registry.dart';
import '../../../../core/portal_links/portal_link_catalog_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared_widgets/page_header.dart';
import '../../../../shared_widgets/portal_link_grid.dart';
import '../../../device_activation/presentation/controllers/device_access_controller.dart';
import '../../../portal_auth/presentation/controllers/portal_auth_controllers.dart';

/// Unified Portals screen for portal users.
///
/// Instead of displaying individual tabs named after people/departments,
/// this screen displays all web sites and enterprise systems that have
/// been granted to the currently logged-in account.
///
/// If no sites are currently granted to the user, an informative empty state
/// advises them to contact their administrator, with an immediate refresh option.
class PortalsScreen extends ConsumerStatefulWidget {
  const PortalsScreen({super.key});

  @override
  ConsumerState<PortalsScreen> createState() => _PortalsScreenState();
}

class _PortalsScreenState extends ConsumerState<PortalsScreen> {
  List<PortalLink>? _catalog;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      final links = await PortalLinkCatalogRepository().listActive();
      if (mounted) setState(() => _catalog = links);
    } catch (_) {
      if (mounted) setState(() => _catalog = kAllPortalLinks);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(portalSessionControllerProvider).valueOrNull;
    final isAdmin = session?.isAdmin ?? false;

    final grantedKeys = session?.grantedLinkKeys.toSet() ?? const <String>{};

    // If portal admin, show all links.
    // For regular portal user, show ONLY the links whose keys have been explicitly granted.
    final catalog = _catalog ?? kAllPortalLinks;
    final visibleLinks = isAdmin
        ? catalog
        : catalog.where((link) => grantedKeys.contains(link.key)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Portals',
          icon: Icons.apps_outlined,
          accentColor: Color(0xFF0284C7),
        ),
        Expanded(
          child: visibleLinks.isEmpty
              ? _NoPortalsEmptyState(
                  onRefresh: () async {
                    ref.invalidate(portalSessionControllerProvider);
                    await _loadCatalog();
                    await ref
                        .read(deviceAccessControllerProvider.notifier)
                        .checkStatus();
                    ref
                        .read(appRefreshSignalProvider.notifier)
                        .update((v) => v + 1);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Portal access permissions refreshed.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.lg,
                    children: [
                      for (final link in visibleLinks)
                        SizedBox(
                          width: 200,
                          height: 164,
                          child: PortalCardTile(
                            name: link.name,
                            icon: link.icon,
                            color: link.color,
                            imageUrl: link.imageUrl,
                            onTap: () => launchGatedPortalLink(context, link),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _NoPortalsEmptyState extends StatefulWidget {
  final Future<void> Function() onRefresh;

  const _NoPortalsEmptyState({required this.onRefresh});

  @override
  State<_NoPortalsEmptyState> createState() => _NoPortalsEmptyStateState();
}

class _NoPortalsEmptyStateState extends State<_NoPortalsEmptyState> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
          decoration: BoxDecoration(
            color: AppColors.surfacePanel,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.softShadow(),
            border: Border.all(color: AppColors.lineHairline),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.vpn_lock_outlined,
                  size: 32,
                  color: Color(0xFF0284C7),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Portals Assigned',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'No sites are provided to your account. Please contact your system administrator to grant access to the required portals.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.inkSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: const Text('Check for Updates'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isRefreshing
                    ? null
                    : () async {
                        setState(() => _isRefreshing = true);
                        try {
                          await widget.onRefresh();
                        } finally {
                          if (mounted) setState(() => _isRefreshing = false);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
