import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/updates/app_update_service.dart';

class AppNavRailItem {
  final IconData icon;
  final String label;
  const AppNavRailItem({required this.icon, required this.label});
}

/// Fixed 220px nav rail on a dark navy background — the one deliberately
/// dark surface in the app, for strong contrast against the white top bar
/// and light content area either side of it. The active item is a bright
/// indigo pill.
/// indigo pill. Includes the app version at the bottom.
class AppNavRail extends StatelessWidget {
  final List<AppNavRailItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const AppNavRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.navRailDark,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.lg,
                horizontal: AppSpacing.sm,
              ),
              children: [
                for (var i = 0; i < items.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: _NavRailTile(
                      item: items[i],
                      selected: i == selectedIndex,
                      onTap: () => onSelect(i),
                    ),
                  ),
              ],
            ),
          ),
          const _NavRailVersionFooter(),
        ],
      ),
    );
  }
}

class _NavRailVersionFooter extends StatelessWidget {
  const _NavRailVersionFooter();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getCurrentAppVersion(),
      initialData: currentAppVersion,
      builder: (context, snapshot) {
        final version = snapshot.data ?? currentAppVersion;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppColors.navRailDarkText.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                'v$version',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: AppColors.navRailDarkText.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavRailTile extends StatelessWidget {
  final AppNavRailItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavRailTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.white.withValues(alpha: 0.06),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: selected ? AppColors.accentLedger : null,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected ? AppColors.softShadow(opacity: 0.35) : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: selected ? Colors.white : AppColors.navRailDarkText,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? Colors.white : AppColors.navRailDarkText,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
