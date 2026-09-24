import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di/providers.dart';
import '../core/constants/permission_keys.dart';
import '../core/rbac/current_user_provider.dart';
import '../core/theme/app_theme.dart';
import '../features/dinesh_portal/presentation/screens/dinesh_portal_screen.dart';
import '../features/kavi_manju_portal/presentation/screens/kavi_manju_portal_screen.dart';
import '../features/other_portals/presentation/screens/other_portals_screen.dart';
import '../features/portal_admin/presentation/screens/admin_audit_logs_screen.dart';
import '../features/portal_admin/presentation/screens/portal_users_admin_screen.dart';
import '../features/portal_auth/presentation/controllers/portal_auth_controllers.dart';
import '../features/portals/presentation/screens/portals_screen.dart';
import '../features/transactions/presentation/controllers/transaction_controllers.dart';
import '../features/vetri_portal/presentation/screens/vetri_portal_screen.dart';
import '../features/device_activation/presentation/controllers/device_access_controller.dart';
import '../features/device_activation/presentation/widgets/device_revocation_banner.dart';
import '../core/portal_links/portal_link_catalog_repository.dart';
import '../shared_widgets/app_nav_rail.dart';
import '../shared_widgets/app_footer.dart';
import '../shared_widgets/change_password_dialog.dart';
import '../shared_widgets/page_header.dart';
import '../features/profile/presentation/screens/user_profile_screen.dart';
import '../shared_widgets/portal_link_grid.dart';
import '../shared_widgets/status_badge.dart';

class _NavEntry {
  final String key;
  final String label;
  final IconData icon;
  final Widget screen;
  const _NavEntry({
    required this.key,
    required this.label,
    required this.icon,
    required this.screen,
  });
}

/// Owns the persistent top bar (design system §3: company name / FY badge /
/// day-status badge / user+role+menu, always visible so "is today open?" is
/// never something the user has to hunt for) and the nav rail. Individual
/// screens no longer carry their own `AppBar` — only their page title, filter
/// row, and content, per the doc's layout diagram.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  List<_NavEntry> _buildEntries() {
    final portalSession = ref
        .watch(portalSessionControllerProvider)
        .valueOrNull;
    final isAdmin = portalSession?.isAdmin ?? false;

    // For regular portal users, show only the unified "Portals" tab with granted sites.
    // Named portals (Abi, Kavi Manju, Vetri, Dinesh) are hidden for them.
    if (!isAdmin) {
      return const <_NavEntry>[
        _NavEntry(
          key: 'portals',
          label: 'Portals',
          icon: Icons.apps_outlined,
          screen: PortalsScreen(),
        ),
      ];
    }

    final catalog = ref.watch(portalCatalogLinksProvider).valueOrNull ?? [];
    final knownTabs = {
      'abi portal',
      'kavi manju portal',
      'vetri portal',
      'dinesh portal',
    };
    final customTabs = <String>{};
    for (final l in catalog) {
      final t = l.tabName?.trim();
      if (t != null && t.isNotEmpty && !knownTabs.contains(t.toLowerCase())) {
        customTabs.add(t);
      }
    }

    // For admin users, show the named portals as configured along with admin tools.
    return <_NavEntry>[
      const _NavEntry(
        key: 'other_portals',
        label: 'Abi Portal',
        icon: Icons.apps_outlined,
        screen: OtherPortalsScreen(),
      ),
      const _NavEntry(
        key: 'kavi_manju_portal',
        label: 'Kavi Manju Portal',
        icon: Icons.apps_outlined,
        screen: KaviManjuPortalScreen(),
      ),
      const _NavEntry(
        key: 'vetri_portal',
        label: 'Vetri Portal',
        icon: Icons.apps_outlined,
        screen: VetriPortalScreen(),
      ),
      const _NavEntry(
        key: 'dinesh_portal',
        label: 'Dinesh Portal',
        icon: Icons.apps_outlined,
        screen: DineshPortalScreen(),
      ),
      for (final tab in customTabs)
        _NavEntry(
          key: 'tab_${tab.toLowerCase().replaceAll(' ', '_')}',
          label: tab,
          icon: Icons.apps_outlined,
          screen: GenericPortalScreen(tabName: tab),
        ),
      const _NavEntry(
        key: 'portal_users',
        label: 'Portal Users',
        icon: Icons.admin_panel_settings_outlined,
        screen: PortalUsersAdminScreen(),
      ),
      const _NavEntry(
        key: 'audit_logs',
        label: 'Audit Logs',
        icon: Icons.history_outlined,
        screen: AdminAuditLogsScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries();
    final selectedIndex = _selectedIndex < entries.length ? _selectedIndex : 0;
    final activeKey = entries[selectedIndex].key;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f5): () => _triggerAppRefresh(context, ref),
        const SingleActivator(LogicalKeyboardKey.keyR, control: true): () => _triggerAppRefresh(context, ref),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              _TopBar(activeKey: activeKey),
              const _DefaultAdminPasswordBanner(),
              const DeviceRevocationBanner(),
              Expanded(
                child: Row(
                  children: [
                    AppNavRail(
                      items: [
                        for (final e in entries)
                          AppNavRailItem(icon: e.icon, label: e.label),
                      ],
                      selectedIndex: selectedIndex,
                      onSelect: (i) => setState(() => _selectedIndex = i),
                    ),
                    Expanded(child: entries[selectedIndex].screen),
                  ],
                ),
              ),
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _triggerAppRefresh(BuildContext context, WidgetRef ref) async {
  try {
    await ref.read(deviceAccessControllerProvider.notifier).checkStatus();
    ref.invalidate(portalSessionControllerProvider);
    ref.read(appRefreshSignalProvider.notifier).update((val) => val + 1);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('App refreshed & data synchronized.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (_) {}
}

class _TopBar extends ConsumerWidget {
  final String activeKey;
  const _TopBar({required this.activeKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portalSession = ref
        .watch(portalSessionControllerProvider)
        .valueOrNull;
    final localUser = ref.watch(currentUserProvider);

    final username = portalSession?.username.isNotEmpty == true
        ? portalSession!.username
        : (localUser?.username.isNotEmpty == true
            ? localUser!.username
            : (portalSession?.fullName.isNotEmpty == true
                ? portalSession!.fullName
                : (localUser?.fullName.isNotEmpty == true
                    ? localUser!.fullName
                    : (portalSession?.email ?? 'User'))));

    final displayName = portalSession?.fullName.isNotEmpty == true
        ? portalSession!.fullName
        : (localUser?.fullName.isNotEmpty == true
            ? localUser!.fullName
            : (portalSession?.username ?? localUser?.username ?? portalSession?.email ?? 'User'));

    final isPortalAdmin = portalSession?.isAdmin ?? false;
    final isLocalAdmin = localUser != null && RoleName.isAdminOrSuper(localUser.roleName);
    final roleName = (isPortalAdmin || isLocalAdmin)
        ? 'Administrator'
        : (localUser?.roleName ?? (portalSession != null ? 'Portal User' : 'User'));

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        boxShadow: AppColors.softShadow(opacity: 0.04),
      ),
      child: Row(
        children: [
          Image.asset('assets/images/app_logo_mark.png', height: 32),
          const SizedBox(width: AppSpacing.md),
          _welcomeBadge(username),
          const SizedBox(width: AppSpacing.sm),
          if (activeKey == 'balance_entry') const _DayStatusBadge(),
          const Spacer(),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UserProfileScreen()),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_circle_outlined, size: 20, color: AppColors.inkPrimary),
                  const SizedBox(width: 6),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _roleBadge(roleName),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.manage_accounts_outlined, size: 21),
            tooltip: 'User Profile & Security',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UserProfileScreen()),
              );
            },
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Refresh Entire App (F5 / Ctrl+R)',
            onPressed: () => _triggerAppRefresh(context, ref),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Log out',
            onPressed: () {
              ref.read(currentUserIdProvider.notifier).setId(null);
              ref.read(portalSessionControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _welcomeBadge(String username) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text.rich(
        TextSpan(
          text: 'Welcome, ',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.inkSecondary,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: username,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.inkPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleBadge(String roleName) {
    final isAdmin = RoleName.isAdminOrSuper(roleName);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? AppColors.inkPrimary : AppColors.accentLedgerTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        roleName,
        style: TextStyle(
          fontSize: 11,
          color: isAdmin ? Colors.white : AppColors.accentLedger,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Contextual to whichever department is active in Transaction Entry — this
/// app is multi-department, so there is no single global "day," unlike the
/// design doc's assumed single-entity model.
class _DayStatusBadge extends ConsumerWidget {
  const _DayStatusBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentId = ref.watch(selectedEntryDepartmentIdProvider);
    final date = ref.watch(selectedEntryDateProvider);
    if (departmentId == null) return const SizedBox.shrink();

    final isClosedAsync = ref.watch(
      isDayClosedProvider((departmentId: departmentId, date: date)),
    );
    return isClosedAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (isClosed) => isClosed ? StatusBadge.closed() : StatusBadge.open(),
    );
  }
}

class GenericPortalScreen extends ConsumerWidget {
  final String tabName;
  const GenericPortalScreen({super.key, required this.tabName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(portalSessionControllerProvider).valueOrNull;
    final isPortalAdmin = session != null &&
        (session.username.toLowerCase() == 'admin' ||
            session.email.toLowerCase().startsWith('admin@'));
    final isLocalUser = ref.watch(currentUserProvider) != null;
    final showAll = isLocalUser || isPortalAdmin;
    final grantedKeys = session?.grantedLinkKeys ?? const [];

    final catalog = ref.watch(portalCatalogLinksProvider).valueOrNull ?? [];
    final matchingLinks = catalog
        .where((l) => l.tabName?.toLowerCase().trim() == tabName.toLowerCase().trim())
        .toList();

    final visibleLinks = showAll
        ? matchingLinks
        : matchingLinks.where((l) => grantedKeys.contains(l.key)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: tabName,
          icon: Icons.apps_outlined,
          accentColor: const Color(0xFF0284C7),
        ),
        Expanded(
          child: PortalCategoryListView(
            categories: [
              PortalCategory(
                name: tabName,
                icon: Icons.apps_outlined,
                links: visibleLinks,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DefaultAdminPasswordBanner extends ConsumerWidget {
  const _DefaultAdminPasswordBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDefaultAsync = ref.watch(isDefaultAdminPasswordProvider);
    final isDefault = isDefaultAsync.valueOrNull ?? false;

    if (!isDefault) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppColors.signalAmber,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.security_update_warning_rounded, color: Colors.white, size: 18),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              'Security Notice: You are currently using the default administrator password ("admin123"). Please change it before deploying to production.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.signalAmber,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            icon: const Icon(Icons.lock_reset_rounded, size: 14),
            label: const Text('Change Password'),
            onPressed: () => showChangePasswordDialog(context),
          ),
        ],
      ),
    );
  }
}
