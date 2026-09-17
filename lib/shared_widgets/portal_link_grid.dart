import 'package:flutter/material.dart';

import '../core/device_auth/gated_link_launcher.dart';
import '../core/theme/app_theme.dart';

/// A single external app: opens in the system default browser, no
/// device-token gate, no embedded WebView — shared by every "portal
/// launcher" style tab (Abi Portal, Kavi Manju Portal, ...). `key` is a
/// stable identifier (never shown in the UI) that the ARMSS Gateway backend
/// uses to record per-user access grants — see `filterGrantedCategories`.
class PortalLink {
  final String key;
  final String name;
  final String url;
  final IconData icon;
  final Color color;
  final String? imageUrl;
  final String? tabName;
  const PortalLink({
    required this.key,
    required this.name,
    required this.url,
    required this.icon,
    required this.color,
    this.imageUrl,
    this.tabName,
  });

  PortalLink copyWith({
    String? key,
    String? name,
    String? url,
    IconData? icon,
    Color? color,
    String? imageUrl,
    String? tabName,
  }) {
    return PortalLink(
      key: key ?? this.key,
      name: name ?? this.name,
      url: url ?? this.url,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      tabName: tabName ?? this.tabName,
    );
  }
}

class PortalCategory {
  final String name;
  final IconData icon;
  final List<PortalLink> links;
  const PortalCategory({
    required this.name,
    required this.icon,
    required this.links,
  });
}

/// Keeps only the links whose `key` is in `grantedKeys` — used by every
/// portal-tab screen to show a logged-in portal user just what an admin has
/// granted them, per link, not per tab.
List<PortalCategory> filterGrantedCategories(
  List<PortalCategory> categories,
  List<String> grantedKeys,
) {
  final granted = grantedKeys.toSet();
  return [
    for (final category in categories)
      PortalCategory(
        name: category.name,
        icon: category.icon,
        links: category.links.where((l) => granted.contains(l.key)).toList(),
      ),
  ];
}

/// Renders every app across all categories as one continuous flowing grid —
/// no section headers or dividers between categories, just a single wrap of
/// cards — the shared body for any "portal launcher" screen. `extraTiles`
/// lets a screen mix in one-off cards that don't fit the plain-link pattern
/// (e.g. a card that navigates in-app instead of opening a browser).
class PortalCategoryListView extends StatelessWidget {
  final List<PortalCategory> categories;
  final List<Widget> extraTiles;
  const PortalCategoryListView({
    super.key,
    required this.categories,
    this.extraTiles = const [],
  });

  @override
  Widget build(BuildContext context) {
    final links = [for (final category in categories) ...category.links];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.lg,
        children: [
          for (final link in links)
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
          ...extraTiles,
        ],
      ),
    );
  }
}

class PortalCardTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String caption;
  final String? imageUrl;
  const PortalCardTile({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
    this.caption = 'Open in Browser',
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfacePanel,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: color.withValues(alpha: 0.06),
        child: Container(
          decoration: BoxDecoration(boxShadow: AppColors.softShadow()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 4, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: imageUrl == null
                            ? Icon(icon, color: color, size: 22)
                            : Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(icon, color: color, size: 22),
                              ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.open_in_browser,
                            size: 12,
                            color: AppColors.inkMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            caption,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
