import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_theme.dart';

class AppNavRailItem {
  final IconData icon;
  final String label;
  final String section;
  const AppNavRailItem({
    required this.icon,
    required this.label,
    this.section = 'WORKSPACE',
  });
}

/// Redesigned admin navigation sidebar:
/// - Single "WORKSPACE" and "ADMINISTRATION" section labels with comfortable spacing
/// - One thin divider between groups only
/// - 28px circular avatar chips with distinct soft tints for per-person portals (A, K, V, D)
/// - Retains existing icons for Portal Users and Audit Logs
/// - Active (indigo bg, 3px white left indicator bar, bold text), Hover, and Focus states
/// - Bottom-pinned collapse toggle with 180° animated chevron rotation and saved preference
/// - Centered logo header with comfortable padding and no "Welcome, admin" pill
/// - LayoutBuilder-driven responsive layout ensuring zero flex overflows and zero assertion crashes
class AppNavRail extends StatefulWidget {
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
  State<AppNavRail> createState() => _AppNavRailState();
}

class _AppNavRailState extends State<AppNavRail> {
  static const _kCollapsedPrefKey = 'sidebar_collapsed';
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _loadCollapsedState();
  }

  Future<void> _loadCollapsedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getBool(_kCollapsedPrefKey);
      if (val != null && mounted) {
        setState(() => _isCollapsed = val);
      }
    } catch (_) {}
  }

  Future<void> _toggleCollapsed() async {
    final next = !_isCollapsed;
    setState(() => _isCollapsed = next);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kCollapsedPrefKey, next);
    } catch (_) {}
  }

  List<Widget> _buildGroupedNavList(bool isExpanded) {
    final List<Widget> children = [];
    String? currentSection;

    for (var i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];

      // Detect section transition
      if (currentSection != item.section) {
        // Only one thin divider between the two groups (when transitioning from group 1 to group 2)
        if (i > 0) {
          children.add(
            Padding(
              key: const ValueKey('group_divider'),
              padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 14 : 10,
                vertical: 10,
              ),
              child: Divider(
                color: Colors.white.withValues(alpha: 0.12),
                height: 1,
                thickness: 1,
              ),
            ),
          );
        }

        // Section label (hidden in collapsed mode)
        if (isExpanded) {
          children.add(
            Padding(
              key: ValueKey('sec_header_${item.section}'),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                item.section.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.88, // ~0.08em
                  color: Color(0xFFC7D2FE), // Noticeably lighter muted lavender with high contrast on navy
                ),
              ),
            ),
          );
        }

        currentSection = item.section;
      }

      // Nav item tile with 4px gap between items (2px top + 2px bottom padding)
      children.add(
        Padding(
          key: ValueKey('nav_tile_${item.label}'),
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: _NavRailTile(
            key: ValueKey('tile_${item.label}'),
            item: item,
            index: i,
            selected: i == widget.selectedIndex,
            isExpanded: isExpanded,
            isCollapsed: _isCollapsed,
            onTap: () => widget.onSelect(i),
          ),
        ),
      );
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: _isCollapsed ? 64 : 210,
      color: AppColors.navRailDark,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isExpanded = constraints.maxWidth > 140;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Area: Logo with comfortable padding (no "Welcome, admin" pill)
              SizedBox(
                height: 64,
                child: isExpanded
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/app_logo_mark.png',
                              height: 28,
                              width: 28,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'ARMSS Gateway',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Image.asset(
                          'assets/images/app_logo_mark.png',
                          height: 28,
                          width: 28,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),

              Divider(
                color: Colors.white.withValues(alpha: 0.08),
                height: 1,
                thickness: 1,
              ),

              // Nav Items List grouped by WORKSPACE and ADMINISTRATION
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildGroupedNavList(isExpanded),
                  ),
                ),
              ),

              // Bottom-pinned Collapse / Expand Toggle Button with rotating chevron
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Tooltip(
                    message: _isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
                    child: InkWell(
                      onTap: _toggleCollapsed,
                      hoverColor: Colors.white.withValues(alpha: 0.08),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          horizontal: isExpanded ? 16 : 0,
                        ),
                        child: isExpanded
                            ? Row(
                                children: [
                                  AnimatedRotation(
                                    turns: _isCollapsed ? 0.5 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    child: const Icon(
                                      Icons.chevron_left_rounded,
                                      size: 20,
                                      color: Color(0xFFC7D2FE),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Collapse sidebar',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFC7D2FE),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : AnimatedRotation(
                                turns: _isCollapsed ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                child: const Icon(
                                  Icons.chevron_left_rounded,
                                  size: 20,
                                  color: Color(0xFFC7D2FE),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavRailTile extends StatefulWidget {
  final AppNavRailItem item;
  final int index;
  final bool selected;
  final bool isExpanded;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _NavRailTile({
    super.key,
    required this.item,
    required this.index,
    required this.selected,
    required this.isExpanded,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_NavRailTile> createState() => _NavRailTileState();
}

class _NavRailTileState extends State<_NavRailTile> {
  bool _isHovered = false;
  bool _isFocused = false;

  bool get _isPortalItem {
    return widget.item.section == 'WORKSPACE' &&
        widget.item.label.toLowerCase().contains('portal');
  }

  Color _getAvatarBg() {
    final l = widget.item.label.toLowerCase();
    if (l.startsWith('a')) return const Color(0xFF3730A3); // Soft Indigo
    if (l.startsWith('k')) return const Color(0xFF0F766E); // Soft Teal
    if (l.startsWith('v')) return const Color(0xFF9A3412); // Soft Amber
    if (l.startsWith('d')) return const Color(0xFF9D174D); // Soft Pink
    const tints = [
      Color(0xFF3730A3),
      Color(0xFF0F766E),
      Color(0xFF9A3412),
      Color(0xFF9D174D),
    ];
    return tints[widget.index % tints.length];
  }

  Color _getAvatarFg() {
    final l = widget.item.label.toLowerCase();
    if (l.startsWith('a')) return const Color(0xFFC7D2FE);
    if (l.startsWith('k')) return const Color(0xFF99F6E4);
    if (l.startsWith('v')) return const Color(0xFFFED7AA);
    if (l.startsWith('d')) return const Color(0xFFFBCFE8);
    return Colors.white;
  }

  Widget _buildIconOrAvatar() {
    if (_isPortalItem) {
      final initial = widget.item.label.isNotEmpty ? widget.item.label[0].toUpperCase() : 'P';
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: _getAvatarBg(),
          shape: BoxShape.circle,
          border: Border.all(
            color: _getAvatarFg().withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: _getAvatarFg(),
          ),
        ),
      );
    }

    return Icon(
      widget.item.icon,
      size: 19,
      color: widget.selected ? Colors.white : const Color(0xFFC7D2FE).withValues(alpha: 0.85),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    if (widget.selected) {
      bgColor = const Color(0xFF4338CA); // Active Indigo
    } else if (_isHovered) {
      bgColor = Colors.white.withValues(alpha: 0.08); // Subtle lighter navy on hover
    }

    final tile = FocusableActionDetector(
      onShowFocusHighlight: (v) => setState(() => _isFocused = v),
      onShowHoverHighlight: (v) => setState(() => _isHovered = v),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: _isFocused
                  ? Border.all(color: const Color(0xFF818CF8), width: 1.5)
                  : (widget.selected
                      ? const Border(
                          left: BorderSide(color: Colors.white, width: 3),
                        )
                      : null),
              boxShadow: widget.selected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4338CA).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: widget.isExpanded
                ? Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 40,
                        child: Center(
                          child: _buildIconOrAvatar(),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.selected ? Colors.white : const Color(0xFFE0E7FF),
                            fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  )
                : Center(
                    child: _buildIconOrAvatar(),
                  ),
          ),
        ),
      ),
    );

    if (widget.isCollapsed) {
      return Tooltip(
        message: widget.item.label,
        waitDuration: const Duration(milliseconds: 250),
        child: tile,
      );
    }

    return tile;
  }
}
