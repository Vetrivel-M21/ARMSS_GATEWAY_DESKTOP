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
      PortalLink(key: 'kavi_manju.karumandapam', name: 'Karumandapam', url: 'http://103.156.171.71/fund_nidhi/login.php', icon: Icons.savings_outlined, color: Color(0xFF0D9488)),
      PortalLink(key: 'kavi_manju.neyveli', name: 'Neyveli', url: 'http://103.156.171.71/nidhi/login.php', icon: Icons.account_balance_outlined, color: Color(0xFF2563EB)),
      PortalLink(key: 'kavi_manju.karaikudi', name: 'Karaikudi', url: 'http://103.156.171.71/mahesan_nidhi/login.php', icon: Icons.account_balance_outlined, color: Color(0xFF7C3AED)),
      PortalLink(key: 'kavi_manju.nidhi_rd', name: 'Nidhi RD', url: 'http://103.156.171.71/NIDHI_RD/login.php', icon: Icons.repeat_outlined, color: Color(0xFF059669)),
    ],
  ),
  PortalCategory(
    name: 'Education',
    icon: Icons.school_outlined,
    links: [
      PortalLink(key: 'kavi_manju.smb_matriculation', name: 'SMB Matriculation', url: 'http://150.242.202.172/smbschool/loginpage.php', icon: Icons.school_outlined, color: Color(0xFF2563EB)),
      PortalLink(key: 'kavi_manju.smb_nursery', name: 'SMB Nursery', url: 'http://150.242.202.172/smbnursery/loginpage.php', icon: Icons.child_care_outlined, color: Color(0xFF06B6D4)),
    ],
  ),
  PortalCategory(
    name: 'Technology & Group Companies',
    icon: Icons.memory_outlined,
    links: [
      PortalLink(key: 'kavi_manju.infotech', name: 'Infotech', url: 'http://150.242.202.172/Infotech/login.php', icon: Icons.computer_outlined, color: Color(0xFFEC4899)),
      PortalLink(key: 'kavi_manju.mahesan_gl', name: 'Mahesan GL', url: 'http://103.207.3.66/mahesangl/login.php', icon: Icons.groups_outlined, color: Color(0xFF7C2D12)),
      PortalLink(key: 'kavi_manju.armss_gl', name: 'ARMSS GL', url: 'http://103.207.3.66/armssgl/login.php', icon: Icons.groups_outlined, color: Color(0xFF1D4ED8)),
    ],
  ),
  PortalCategory(
    name: 'Other',
    icon: Icons.widgets_outlined,
    links: [
      PortalLink(key: 'kavi_manju.mcf', name: 'MCF', url: 'https://mcf.arminfo.in/', icon: Icons.corporate_fare_outlined, color: Color(0xFFB91C1C)),
      PortalLink(key: 'kavi_manju.mis', name: 'MIS', url: 'http://mis.arminfo.in/', icon: Icons.dashboard_outlined, color: Color(0xFF334155)),
    ],
  ),
];

/// "Kavi Manju Portal" — a second, separate group of external app links,
/// alongside Abi Portal. Local ledger accounts see every link unchanged;
/// self-registered portal accounts only see what an admin has granted them.
class KaviManjuPortalScreen extends ConsumerWidget {
  const KaviManjuPortalScreen({super.key});

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
      tabName: 'Kavi Manju Portal',
    );
    final categories = showAll
        ? dynamicCategories
        : filterGrantedCategories(dynamicCategories, grantedKeys);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(title: 'Kavi Manju Portal', icon: Icons.apps_outlined, accentColor: Color(0xFF9333EA)),
        Expanded(child: PortalCategoryListView(categories: categories)),
      ],
    );
  }
}
