class AdminPortalLink {
  final String key;
  final String tabName;
  final String name;
  final String url;
  final String icon;
  final String color;
  final String? imagePath;
  final int sortOrder;
  final bool isActive;

  const AdminPortalLink({
    required this.key,
    required this.tabName,
    required this.name,
    required this.url,
    required this.icon,
    required this.color,
    required this.imagePath,
    required this.sortOrder,
    required this.isActive,
  });
}
