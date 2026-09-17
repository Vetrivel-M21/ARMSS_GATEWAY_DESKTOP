import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/portal_links/portal_link_catalog_repository.dart';
import '../../../../core/rbac/current_user_provider.dart';
import '../../../../shared_widgets/page_header.dart';
import '../../../../shared_widgets/portal_link_grid.dart';
import '../../../portal_auth/presentation/controllers/portal_auth_controllers.dart';

const _portalCategories = [
  PortalCategory(
    name: 'Payroll',
    icon: Icons.payments_outlined,
    links: [
      PortalLink(key: 'dinesh.payroll', name: 'Payroll', url: 'http://103.156.171.71/payroll/public/index.php', icon: Icons.payments_outlined, color: Color(0xFF15803D)),
    ],
  ),
];

/// "Dinesh Portal" — its own separate tab, its own group of app links. Local
/// ledger accounts see every link unchanged; self-registered portal
/// accounts only see what an admin has granted them.
class DineshPortalScreen extends ConsumerWidget {
  const DineshPortalScreen({super.key});

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
      tabName: 'Dinesh Portal',
    );
    final categories = showAll
        ? dynamicCategories
        : filterGrantedCategories(dynamicCategories, grantedKeys);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(title: 'Dinesh Portal', icon: Icons.apps_outlined, accentColor: Color(0xFF15803D)),
        Expanded(child: PortalCategoryListView(categories: categories)),
      ],
    );
  }
}
