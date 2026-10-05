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

class _NavRailVersionFooter extends StatefulWidget {
  const _NavRailVersionFooter();

  @override
  State<_NavRailVersionFooter> createState() => _NavRailVersionFooterState();
}

class _NavRailVersionFooterState extends State<_NavRailVersionFooter> {
  bool _isChecking = false;

  Future<void> _checkUpdate(BuildContext context, String currentVer) async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      final update = await AppUpdateService().check();
      if (!context.mounted) return;
      if (update != null) {
        await showDesktopUpdateDialog(
          context,
          updateInfo: update,
          currentVersion: currentVer,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('ARMSS Gateway is up to date (v$currentVer)'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update check failed: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

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
            horizontal: AppSpacing.md,
            vertical: 10,
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
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppColors.navRailDarkText.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'v$version',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    color: AppColors.navRailDarkText.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Tooltip(
                message: 'Check for Updates',
                child: InkWell(
                  onTap: _isChecking ? null : () => _checkUpdate(context, version),
                  borderRadius: BorderRadius.circular(6),
                  hoverColor: Colors.white.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: _isChecking
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            size: 15,
                            color: AppColors.navRailDarkText.withValues(alpha: 0.8),
                          ),
                  ),
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
