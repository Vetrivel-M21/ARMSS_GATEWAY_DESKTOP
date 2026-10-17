import 'package:flutter/material.dart';

import '../../shared_widgets/portal_link_grid.dart';

/// Central registry of all 25 grantable portal links in ARMSS Gateway.
const List<PortalLink> kAllPortalLinks = [
  // Abi Portal links
  PortalLink(
    key: 'abi.trust',
    name: 'TRUST',
    url: 'http://103.156.171.71/TRUST/login.php',
    icon: Icons.verified_user_outlined,
    color: Color(0xFFDC2626),
  ),
  PortalLink(
    key: 'abi.overall_accounts',
    name: 'Overall Accounts',
    url: 'https://account.arminfo.in/',
    icon: Icons.account_balance_wallet_outlined,
    color: Color(0xFF0891B2),
  ),
  PortalLink(
    key: 'abi.mfi',
    name: 'MFI',
    url: 'http://103.156.171.71/MFI/login.php',
    icon: Icons.savings_outlined,
    color: Color(0xFFCA8A04),
  ),
  PortalLink(
    key: 'abi.hanniji',
    name: 'HANNIJI',
    url: 'http://103.156.171.71/HANNIJI/login.php',
    icon: Icons.apps,
    color: Color(0xFF6366F1),
  ),
  PortalLink(
    key: 'abi.aura',
    name: 'AURA',
    url: 'http://103.156.171.71/AURA/login.php',
    icon: Icons.apps,
    color: Color(0xFF0EA5E9),
  ),
  PortalLink(
    key: 'abi.employment',
    name: 'Employment',
    url: 'http://150.242.202.172/employment/login.php',
    icon: Icons.work_outline,
    color: Color(0xFF16A34A),
  ),
  PortalLink(
    key: 'abi.ornaments',
    name: 'Ornaments',
    url: 'http://150.242.202.172/ORNAMENTS/login.php',
    icon: Icons.diamond_outlined,
    color: Color(0xFFD97706),
  ),
  PortalLink(
    key: 'abi.enterprises',
    name: 'Enterprises',
    url: 'http://150.242.202.172/enterprices/login.php',
    icon: Icons.business_outlined,
    color: Color(0xFF8B5CF6),
  ),
  PortalLink(
    key: 'abi.veyon_agency',
    name: 'Veyon Agency',
    url: 'https://veyonag.arminfo.in/login.php',
    icon: Icons.groups_outlined,
    color: Color(0xFFEC4899),
  ),
  PortalLink(
    key: 'abi.veyon_global',
    name: 'Veyon Global',
    url: 'https://veyongb.arminfo.in/login.php',
    icon: Icons.public_outlined,
    color: Color(0xFF14B8A6),
  ),
  PortalLink(
    key: 'abi.hardware',
    name: 'Hardware',
    url: 'http://103.156.171.71/hardware/login.php',
    icon: Icons.developer_board_outlined,
    color: Color(0xFF475569),
  ),

  // Kavi Manju Portal links
  PortalLink(
    key: 'kavi_manju.karumandapam',
    name: 'Karumandapam',
    url: 'http://103.156.171.71/fund_nidhi/login.php',
    icon: Icons.savings_outlined,
    color: Color(0xFF0D9488),
  ),
  PortalLink(
    key: 'kavi_manju.neyveli',
    name: 'Neyveli',
    url: 'http://103.156.171.71/nidhi/login.php',
    icon: Icons.account_balance_outlined,
    color: Color(0xFF2563EB),
  ),
  PortalLink(
    key: 'kavi_manju.karaikudi',
    name: 'Karaikudi',
    url: 'http://103.156.171.71/mahesan_nidhi/login.php',
    icon: Icons.account_balance_outlined,
    color: Color(0xFF7C3AED),
  ),
  PortalLink(
    key: 'kavi_manju.nidhi_rd',
    name: 'Nidhi RD',
    url: 'http://103.156.171.71/NIDHI_RD/login.php',
    icon: Icons.repeat_outlined,
    color: Color(0xFF059669),
  ),
  PortalLink(
    key: 'kavi_manju.smb_matriculation',
    name: 'SMB Matriculation',
    url: 'http://150.242.202.172/smbschool/loginpage.php',
    icon: Icons.school_outlined,
    color: Color(0xFF2563EB),
  ),
  PortalLink(
    key: 'kavi_manju.smb_nursery',
    name: 'SMB Nursery',
    url: 'http://150.242.202.172/smbnursery/loginpage.php',
    icon: Icons.child_care_outlined,
    color: Color(0xFF06B6D4),
  ),
  PortalLink(
    key: 'kavi_manju.infotech',
    name: 'Infotech',
    url: 'http://150.242.202.172/Infotech/login.php',
    icon: Icons.computer_outlined,
    color: Color(0xFFEC4899),
  ),
  PortalLink(
    key: 'kavi_manju.mahesan_gl',
    name: 'Mahesan GL',
    url: 'http://103.207.3.66/mahesangl/login.php',
    icon: Icons.groups_outlined,
    color: Color(0xFF7C2D12),
  ),
  PortalLink(
    key: 'kavi_manju.armss_gl',
    name: 'ARMSS GL',
    url: 'http://103.207.3.66/armssgl/login.php',
    icon: Icons.groups_outlined,
    color: Color(0xFF1D4ED8),
  ),
  PortalLink(
    key: 'kavi_manju.mcf',
    name: 'MCF',
    url: 'https://mcf.arminfo.in/',
    icon: Icons.corporate_fare_outlined,
    color: Color(0xFFB91C1C),
  ),
  PortalLink(
    key: 'kavi_manju.mis',
    name: 'MIS',
    url: 'http://mis.arminfo.in/',
    icon: Icons.dashboard_outlined,
    color: Color(0xFF334155),
  ),

  // Vetri Portal links
  PortalLink(
    key: 'vetri.veyon_stationery',
    name: 'Veyon Stationery Management',
    url: 'https://veyon.arminfo.in/',
    icon: Icons.inventory_2_outlined,
    color: Color(0xFF0284C7),
  ),
  PortalLink(
    key: 'vetri.trust',
    name: 'Trust',
    url: 'https://trust.arminfo.in/',
    icon: Icons.account_balance_outlined,
    color: Color(0xFFF97316),
  ),

  // Dinesh Portal links
  PortalLink(
    key: 'dinesh.payroll',
    name: 'Payroll',
    url: 'http://103.156.171.71/payroll/public/index.php',
    icon: Icons.payments_outlined,
    color: Color(0xFF15803D),
  ),
];

/// Known category labels for all portal links across tabs.
const Map<String, String> kPortalCategoryMap = {
  'abi.trust': 'Finance & Lending',
  'abi.overall_accounts': 'Finance & Lending',
  'abi.mfi': 'Finance & Lending',
  'abi.hanniji': 'Trading & Enterprises',
  'abi.aura': 'Trading & Enterprises',
  'abi.employment': 'Trading & Enterprises',
  'abi.ornaments': 'Trading & Enterprises',
  'abi.enterprises': 'Trading & Enterprises',
  'abi.veyon_agency': 'Trading & Enterprises',
  'abi.veyon_global': 'Trading & Enterprises',
  'abi.hardware': 'Technology',
  'kavi_manju.karumandapam': 'Finance & Lending',
  'kavi_manju.neyveli': 'Finance & Lending',
  'kavi_manju.karaikudi': 'Finance & Lending',
  'kavi_manju.nidhi_rd': 'Finance & Lending',
  'kavi_manju.smb_matriculation': 'Education',
  'kavi_manju.smb_nursery': 'Education',
  'kavi_manju.infotech': 'Technology',
  'kavi_manju.mahesan_gl': 'Group Companies',
  'kavi_manju.armss_gl': 'Group Companies',
  'kavi_manju.mcf': 'Group Companies',
  'kavi_manju.mis': 'Operations',
  'vetri.veyon_stationery': 'Management',
  'vetri.trust': 'Finance',
  'dinesh.payroll': 'Payroll',
};

/// Checks whether a label represents an internal portal ownership / creator tab
/// (such as "Abi Portal", "Kavi Manju Portal", "Vetri Portal", "Dinesh Portal")
/// rather than a business functional category.
bool isPortalOwnershipLabel(String? label) {
  if (label == null || label.trim().isEmpty) return true;
  final lower = label.trim().toLowerCase();
  return lower == 'portal' ||
      lower == 'open in browser' ||
      lower.contains('abi') ||
      lower.contains('kavi') ||
      lower.contains('manju') ||
      lower.contains('vetri') ||
      lower.contains('dinesh') ||
      lower.contains('other portal') ||
      lower.endsWith(' portal') ||
      lower.startsWith('portal ');
}

/// Resolves the category or group label for a given portal link,
/// stripping out internal ownership labels.
String? resolvePortalCategory(PortalLink link, [String? explicitCategory]) {
  if (explicitCategory != null &&
      explicitCategory.trim().isNotEmpty &&
      !isPortalOwnershipLabel(explicitCategory)) {
    return explicitCategory.trim();
  }
  if (link.tabName != null &&
      link.tabName!.trim().isNotEmpty &&
      !isPortalOwnershipLabel(link.tabName)) {
    return link.tabName!.trim();
  }
  final mapped = kPortalCategoryMap[link.key];
  if (mapped != null && mapped.trim().isNotEmpty && !isPortalOwnershipLabel(mapped)) {
    return mapped.trim();
  }
  return null;
}

