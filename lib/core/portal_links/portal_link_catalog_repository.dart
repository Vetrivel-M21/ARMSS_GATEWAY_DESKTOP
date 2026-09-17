import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/providers.dart';
import '../../shared_widgets/portal_link_grid.dart';
import '../config/gateway_api_client.dart';
import 'portal_link_registry.dart';

final portalCatalogLinksProvider = FutureProvider<List<PortalLink>>((ref) async {
  ref.watch(appRefreshSignalProvider);
  try {
    return await PortalLinkCatalogRepository().listActive();
  } catch (_) {
    return kAllPortalLinks;
  }
});

class PortalLinkCatalogRepository {
  Future<List<PortalLink>> listActive() async {
    final response = await http
        .get(Uri.parse('${GatewayApiClient.apiBaseUrl}/portal/links'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Portal catalog request failed (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true) throw Exception('Portal catalog unavailable');
    return [
      for (final raw in (body['data'] as List).cast<Map<String, dynamic>>())
        _fromJson(raw),
    ];
  }

  PortalLink _fromJson(Map<String, dynamic> raw) {
    return PortalLink(
      key: raw['key'] as String,
      name: raw['name'] as String,
      url: raw['url'] as String,
      icon: _icons[raw['icon'] as String?] ?? Icons.apps,
      color: _parseColor(raw['color'] as String?),
      imageUrl: absoluteImageUrl(raw['image_path'] as String?),
      tabName: raw['tab_name'] as String?,
    );
  }

  static String? absoluteImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final base = Uri.parse(GatewayApiClient.apiBaseUrl);
    return base.replace(path: path).toString();
  }

  Color _parseColor(String? value) {
    final hex = (value ?? '#0284C7').replaceFirst('#', '');
    final normalized = hex.length == 6 ? 'FF$hex' : hex;
    return Color(int.tryParse(normalized, radix: 16) ?? 0xFF0284C7);
  }
}

List<PortalCategory> mergeCategoriesWithCatalog({
  required List<PortalCategory> staticCategories,
  required List<PortalLink>? catalog,
  required String tabName,
}) {
  if (catalog == null || catalog.isEmpty) return staticCategories;

  final catalogByKey = {for (final link in catalog) link.key: link};
  final matchedKeys = <String>{};

  final updatedCategories = <PortalCategory>[];
  for (final cat in staticCategories) {
    final updatedLinks = <PortalLink>[];
    for (final link in cat.links) {
      matchedKeys.add(link.key);
      final dynamicLink = catalogByKey[link.key];
      if (dynamicLink != null) {
        updatedLinks.add(link.copyWith(
          name: dynamicLink.name,
          url: dynamicLink.url,
          imageUrl: dynamicLink.imageUrl ?? link.imageUrl,
          tabName: dynamicLink.tabName ?? link.tabName,
        ));
      } else {
        updatedLinks.add(link);
      }
    }
    if (updatedLinks.isNotEmpty) {
      updatedCategories.add(PortalCategory(
        name: cat.name,
        icon: cat.icon,
        links: updatedLinks,
      ));
    }
  }

  // Also include any newly added links that belong to this tab
  final extraLinks = catalog
      .where((link) =>
          !matchedKeys.contains(link.key) &&
          (link.tabName?.toLowerCase().trim() == tabName.toLowerCase().trim()))
      .toList();

  if (extraLinks.isNotEmpty) {
    updatedCategories.add(PortalCategory(
      name: 'Custom Web Apps',
      icon: Icons.apps_outlined,
      links: extraLinks,
    ));
  }

  return updatedCategories;
}

const _icons = <String, IconData>{
  'verified_user_outlined': Icons.verified_user_outlined,
  'account_balance_wallet_outlined': Icons.account_balance_wallet_outlined,
  'savings_outlined': Icons.savings_outlined,
  'apps': Icons.apps,
  'work_outline': Icons.work_outline,
  'diamond_outlined': Icons.diamond_outlined,
  'business_outlined': Icons.business_outlined,
  'groups_outlined': Icons.groups_outlined,
  'public_outlined': Icons.public_outlined,
  'developer_board_outlined': Icons.developer_board_outlined,
  'account_balance_outlined': Icons.account_balance_outlined,
  'repeat_outlined': Icons.repeat_outlined,
  'school_outlined': Icons.school_outlined,
  'child_care_outlined': Icons.child_care_outlined,
  'computer_outlined': Icons.computer_outlined,
  'corporate_fare_outlined': Icons.corporate_fare_outlined,
  'dashboard_outlined': Icons.dashboard_outlined,
  'inventory_2_outlined': Icons.inventory_2_outlined,
  'payments_outlined': Icons.payments_outlined,
};
