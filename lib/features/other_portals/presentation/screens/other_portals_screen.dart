import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/portal_links/portal_link_catalog_repository.dart';
import '../../../../core/rbac/current_user_provider.dart';
import '../../../../shared_widgets/page_header.dart';
import '../../../../shared_widgets/portal_link_grid.dart';
import '../../../portal_auth/presentation/controllers/portal_auth_controllers.dart';

const _portalCategories = [
  PortalCategory(
    name: 'Finance & Lending',
    icon: Icons.account_balance_outlined,
    links: [
      PortalLink(key: 'abi.trust', name: 'TRUST', url: 'http://103.156.171.71/TRUST/login.php', icon: Icons.verified_user_outlined, color: Color(0xFFDC2626)),
      PortalLink(key: 'abi.overall_accounts', name: 'Overall Accounts', url: 'https://account.arminfo.in/', icon: Icons.account_balance_wallet_outlined, color: Color(0xFF0891B2)),
      PortalLink(key: 'abi.mfi', name: 'MFI', url: 'http://103.156.171.71/MFI/login.php', icon: Icons.savings_outlined, color: Color(0xFFCA8A04)),
    ],
  ),
  PortalCategory(
    name: 'Trading & Enterprises',
    icon: Icons.storefront_outlined,
    links: [
      PortalLink(key: 'abi.hanniji', name: 'HANNIJI', url: 'http://103.156.171.71/HANNIJI/login.php', icon: Icons.apps, color: Color(0xFF6366F1)),
      PortalLink(key: 'abi.aura', name: 'AURA', url: 'http://103.156.171.71/AURA/login.php', icon: Icons.apps, color: Color(0xFF0EA5E9)),
      PortalLink(key: 'abi.employment', name: 'Employment', url: 'http://150.242.202.172/employment/login.php', icon: Icons.work_outline, color: Color(0xFF16A34A)),
      PortalLink(key: 'abi.ornaments', name: 'Ornaments', url: 'http://150.242.202.172/ORNAMENTS/login.php', icon: Icons.diamond_outlined, color: Color(0xFFD97706)),
      PortalLink(key: 'abi.enterprises', name: 'Enterprises', url: 'http://150.242.202.172/enterprices/login.php', icon: Icons.business_outlined, color: Color(0xFF8B5CF6)),
      PortalLink(key: 'abi.veyon_agency', name: 'Veyon Agency', url: 'https://veyonag.arminfo.in/login.php', icon: Icons.groups_outlined, color: Color(0xFFEC4899)),
      PortalLink(key: 'abi.veyon_global', name: 'Veyon Global', url: 'https://veyongb.arminfo.in/login.php', icon: Icons.public_outlined, color: Color(0xFF14B8A6)),
    ],
  ),
  PortalCategory(
    name: 'Technology',
    icon: Icons.memory_outlined,
    links: [
      PortalLink(key: 'abi.hardware', name: 'Hardware', url: 'http://103.156.171.71/hardware/login.php', icon: Icons.developer_board_outlined, color: Color(0xFF475569)),
    ],
  ),
];

/// "Abi Portal" — plain launcher for other internal applications. Distinct
/// from the Trust Portal tab (device-token-gated embedded WebView) and from
/// Kavi Manju Portal (a separate group of apps in their own tab). Local
/// ledger accounts see every link unchanged; self-registered portal
/// accounts only see what an admin has granted them.
class OtherPortalsScreen extends ConsumerWidget {
  const OtherPortalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(portalSessionControllerProvider).valueOrNull;
    final isPortalAdmin = session?.isAdmin ?? false;
    final isLocalUser = ref.watch(currentUserProvider) != null;
    final showAll = isLocalUser || isPortalAdmin;
    final grantedKeys = session?.grantedLinkKeys ?? const [];
    final catalog = ref.watch(portalCatalogLinksProvider).valueOrNull;
    final dynamicCategories = mergeCategoriesWithCatalog(
      staticCategories: _portalCategories,
      catalog: catalog,
      tabName: 'Abi Portal',
    );
    final categories = showAll
        ? dynamicCategories
        : filterGrantedCategories(dynamicCategories, grantedKeys);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(title: 'Abi Portal', icon: Icons.apps_outlined, accentColor: Color(0xFF14B8A6)),
        Expanded(child: PortalCategoryListView(categories: categories)),
      ],
    );
  }
}
