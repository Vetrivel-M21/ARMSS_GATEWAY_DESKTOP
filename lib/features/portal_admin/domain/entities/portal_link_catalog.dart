/// One entry per grantable portal link, for the admin screen's checkbox UI.
/// This mirrors (but is intentionally separate from) the `PortalLink`
/// entries defined in each portal tab's screen file — those carry url/icon/
/// color for rendering; this only needs the key/tab/label an admin sees.
class PortalCatalogEntry {
  final String key;
  final String tabName;
  final String label;
  const PortalCatalogEntry({
    required this.key,
    required this.tabName,
    required this.label,
  });
}

const kPortalLinkCatalog = <PortalCatalogEntry>[
  PortalCatalogEntry(key: 'abi.trust', tabName: 'Abi Portal', label: 'TRUST'),
  PortalCatalogEntry(
    key: 'abi.overall_accounts',
    tabName: 'Abi Portal',
    label: 'Overall Accounts',
  ),
  PortalCatalogEntry(key: 'abi.mfi', tabName: 'Abi Portal', label: 'MFI'),
  PortalCatalogEntry(
    key: 'abi.hanniji',
    tabName: 'Abi Portal',
    label: 'HANNIJI',
  ),
  PortalCatalogEntry(key: 'abi.aura', tabName: 'Abi Portal', label: 'AURA'),
  PortalCatalogEntry(
    key: 'abi.employment',
    tabName: 'Abi Portal',
    label: 'Employment',
  ),
  PortalCatalogEntry(
    key: 'abi.ornaments',
    tabName: 'Abi Portal',
    label: 'Ornaments',
  ),
  PortalCatalogEntry(
    key: 'abi.enterprises',
    tabName: 'Abi Portal',
    label: 'Enterprises',
  ),
  PortalCatalogEntry(
    key: 'abi.veyon_agency',
    tabName: 'Abi Portal',
    label: 'Veyon Agency',
  ),
  PortalCatalogEntry(
    key: 'abi.veyon_global',
    tabName: 'Abi Portal',
    label: 'Veyon Global',
  ),
  PortalCatalogEntry(
    key: 'abi.hardware',
    tabName: 'Abi Portal',
    label: 'Hardware',
  ),
  PortalCatalogEntry(
    key: 'kavi_manju.karumandapam',
    tabName: 'Kavi Manju Portal',
    label: 'Karumandapam',
  ),
  PortalCatalogEntry(
    key: 'kavi_manju.neyveli',
    tabName: 'Kavi Manju Portal',
    label: 'Neyveli',
  ),
  PortalCatalogEntry(
    key: 'kavi_manju.karaikudi',
    tabName: 'Kavi Manju Portal',
    label: 'Karaikudi',
  ),
  PortalCatalogEntry(
    key: 'kavi_manju.nidhi_rd',
    tabName: 'Kavi Manju Portal',
    label: 'Nidhi RD',
  ),
  PortalCatalogEntry(
    key: 'kavi_manju.smb_matriculation',
    tabName: 'Kavi Manju Portal',
    label: 'SMB Matriculation',
  ),
  PortalCatalogEntry(
    key: 'kavi_manju.smb_nursery',
    tabName: 'Kavi Manju Portal',
    label: 'SMB Nursery',
  ),
  PortalCatalogEntry(
    key: 'kavi_manju.infotech',
    tabName: 'Kavi Manju Portal',
    label: 'Infotech',
  ),
  PortalCatalogEntry(
    key: 'kavi_manju.mahesan_gl',
    tabName: 'Kavi Manju Portal',
    label: 'Mahesan GL',
  ),
  PortalCatalogEntry(
    key: 'kavi_manju.armss_gl',
    tabName: 'Kavi Manju Portal',
    label: 'ARMSS GL',
  ),
  PortalCatalogEntry(
    key: 'kavi_manju.mcf',
    tabName: 'Kavi Manju Portal',
    label: 'MCF',
  ),
  PortalCatalogEntry(
    key: 'kavi_manju.mis',
    tabName: 'Kavi Manju Portal',
    label: 'MIS',
  ),
  PortalCatalogEntry(
    key: 'vetri.veyon_stationery',
    tabName: 'Vetri Portal',
    label: 'Veyon Stationery Management',
  ),
  PortalCatalogEntry(
    key: 'vetri.trust',
    tabName: 'Vetri Portal',
    label: 'Trust',
  ),
  PortalCatalogEntry(
    key: 'dinesh.payroll',
    tabName: 'Dinesh Portal',
    label: 'Payroll',
  ),
];
