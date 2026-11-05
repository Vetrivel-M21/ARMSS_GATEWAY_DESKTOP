import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/di/providers.dart';
import '../core/device_auth/gated_link_launcher.dart';
import '../core/portal_links/pinned_portals_provider.dart';
import '../core/portal_links/portal_link_registry.dart';
import '../core/rbac/current_user_provider.dart';
import '../core/theme/app_theme.dart';
import '../features/device_activation/presentation/controllers/device_access_controller.dart';
import '../features/portal_auth/presentation/controllers/portal_auth_controllers.dart';

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

/// Renders every app across categories with:
/// - Optional portal title & dynamic local-time greeting header
/// - Live search filtering with `Ctrl+K` hint badge
/// - Count pill badge
/// - Grid View vs. List View switcher (persisted)
/// - Pinned / Favorites section
class PortalCategoryListView extends ConsumerStatefulWidget {
  final List<PortalCategory> categories;
  final List<Widget> extraTiles;
  final String? portalTitle;
  final VoidCallback? onRefresh;

  const PortalCategoryListView({
    super.key,
    required this.categories,
    this.extraTiles = const [],
    this.portalTitle,
    this.onRefresh,
  });

  @override
  ConsumerState<PortalCategoryListView> createState() => _PortalCategoryListViewState();
}

class _PortalCategoryListViewState extends ConsumerState<PortalCategoryListView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _viewMode = 'grid'; // 'grid' | 'list'
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadViewMode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  Future<void> _loadViewMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mode = prefs.getString('portals_view_mode');
      if (mode != null && (mode == 'grid' || mode == 'list')) {
        if (mounted) setState(() => _viewMode = mode);
      }
    } catch (_) {}
  }

  Future<void> _updateViewMode(String mode) async {
    setState(() => _viewMode = mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('portals_view_mode', mode);
    } catch (_) {}
  }

  Future<void> _refreshData() async {
    if (widget.onRefresh != null) {
      widget.onRefresh!();
      return;
    }
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      ref.invalidate(portalSessionControllerProvider);
      await ref.read(deviceAccessControllerProvider.notifier).checkStatus();
      ref.read(appRefreshSignalProvider.notifier).update((v) => v + 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Portal access permissions refreshed.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Widget _buildPortalsCollection(
    List<({PortalLink link, String categoryName})> items,
    Set<String> pinnedKeys, {
    List<Widget> extraTiles = const [],
  }) {
    if (_viewMode == 'list') {
      return Column(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: PortalListTile(
                name: item.link.name,
                url: item.link.url,
                icon: item.link.icon,
                color: item.link.color,
                tabName: resolvePortalCategory(item.link, item.categoryName),
                imageUrl: item.link.imageUrl,
                isPinned: pinnedKeys.contains(item.link.key),
                onTogglePin: () => ref
                    .read(pinnedPortalsProvider.notifier)
                    .togglePin(item.link.key),
                onTap: () => launchGatedPortalLink(context, item.link),
              ),
            ),
          ...extraTiles,
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.lg;
        final availableWidth = constraints.maxWidth;
        final cols = (availableWidth / 210.0).floor().clamp(1, 8);
        final itemWidth = (availableWidth - (cols - 1) * spacing) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                height: 184,
                child: PortalCardTile(
                  name: item.link.name,
                  icon: item.link.icon,
                  color: item.link.color,
                  categoryLabel: resolvePortalCategory(item.link, item.categoryName),
                  imageUrl: item.link.imageUrl,
                  isPinned: pinnedKeys.contains(item.link.key),
                  onTogglePin: () => ref
                      .read(pinnedPortalsProvider.notifier)
                      .togglePin(item.link.key),
                  onTap: () => launchGatedPortalLink(context, item.link),
                ),
              ),
            ...extraTiles,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinnedKeys = ref.watch(pinnedPortalsProvider);
    final allItems = [
      for (final category in widget.categories)
        for (final link in category.links)
          (link: link, categoryName: category.name),
    ];

    final query = _searchQuery.trim().toLowerCase();
    final filteredItems = query.isEmpty
        ? allItems
        : allItems.where((item) {
            final nameMatch = item.link.name.toLowerCase().contains(query);
            final catMatch = item.categoryName.toLowerCase().contains(query);
            final tabMatch = item.link.tabName?.toLowerCase().contains(query) ?? false;
            return nameMatch || catMatch || tabMatch;
          }).toList();

    final pinnedItems = filteredItems
        .where((item) => pinnedKeys.contains(item.link.key))
        .toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryInk = isDark ? AppColors.darkInkPrimary : AppColors.inkPrimary;
    final secondaryInk = isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary;
    final surfacePanel = isDark ? AppColors.darkSurfacePanel : AppColors.surfacePanel;
    final surfaceSunken = isDark ? AppColors.darkSurfaceSunken : AppColors.surfaceSunken;
    final lineBorder = isDark ? AppColors.darkLineHairline : AppColors.lineHairline;

    final session = ref.watch(portalSessionControllerProvider).valueOrNull;
    final localUser = ref.watch(currentUserProvider);
    final rawName = session?.fullName.isNotEmpty == true
        ? session!.fullName
        : (session?.username.isNotEmpty == true
            ? session!.username
            : (localUser?.fullName.isNotEmpty == true
                ? localUser!.fullName
                : (localUser?.username.isNotEmpty == true
                    ? localUser!.username
                    : 'User')));

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          _searchFocusNode.requestFocus();
          _searchController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _searchController.text.length,
          );
        },
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Greeting / Title Header (if portalTitle is provided)
          if (widget.portalTitle != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.portalTitle!,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: primaryInk,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_getGreeting()}, $rawName • Launch and manage portals',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: secondaryInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: _isRefreshing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded, size: 20),
                    tooltip: 'Refresh Permissions',
                    onPressed: _isRefreshing ? null : _refreshData,
                  ),
                ],
              ),
            ),

          // 2. Search Bar & View Mode Switcher
          if (allItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: surfacePanel,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isDark ? null : AppColors.softShadow(opacity: 0.03),
                            border: Border.all(color: lineBorder),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: TextStyle(fontSize: 13.5, color: primaryInk),
                            decoration: InputDecoration(
                              hintText: 'Search portals by name or category...',
                              hintStyle: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
                              prefixIcon: const Icon(Icons.search_rounded, size: 19, color: AppColors.inkMuted),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_searchQuery.isNotEmpty)
                                    IconButton(
                                      icon: Icon(Icons.clear_rounded, size: 16, color: secondaryInk),
                                      tooltip: 'Clear Search',
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    ),
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: surfaceSunken,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: lineBorder),
                                    ),
                                    child: Text(
                                      'Ctrl+K',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: secondaryInk,
                                        fontFamily: AppFonts.mono,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: surfaceSunken,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: lineBorder),
                        ),
                        child: Text(
                          query.isNotEmpty
                              ? '${filteredItems.length} of ${allItems.length} portals'
                              : '${allItems.length} total portals${pinnedItems.isNotEmpty ? ' • ${pinnedItems.length} pinned' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: secondaryInk,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: surfaceSunken,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: lineBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PortalViewModeButton(
                              icon: Icons.grid_view_rounded,
                              tooltip: 'Grid View',
                              isSelected: _viewMode == 'grid',
                              onTap: () => _updateViewMode('grid'),
                            ),
                            const SizedBox(width: 2),
                            _PortalViewModeButton(
                              icon: Icons.view_list_rounded,
                              tooltip: 'List View',
                              isSelected: _viewMode == 'list',
                              onTap: () => _updateViewMode('list'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 3. Content Area
          Expanded(
            child: allItems.isEmpty
                ? Center(
                    child: Text(
                      'No portals configured.',
                      style: TextStyle(color: secondaryInk),
                    ),
                  )
                : filteredItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 420),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                            decoration: BoxDecoration(
                              color: surfacePanel,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isDark ? null : AppColors.softShadow(),
                              border: Border.all(color: lineBorder),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: surfaceSunken,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.search_off_rounded,
                                    size: 28,
                                    color: AppColors.inkMuted,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Portals Found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: primaryInk,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No portals matched "$_searchQuery". Check for typos or clear your search query.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: secondaryInk,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextButton.icon(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  label: const Text('Clear Search Query'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, AppSpacing.scrollBottomPad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pinned Portals Section (if any pinned and not currently searching)
                            if (query.isEmpty && pinnedItems.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 16, color: AppColors.signalAmber),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Pinned Portals',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: primaryInk,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: surfaceSunken,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${pinnedItems.length}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: secondaryInk,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _buildPortalsCollection(pinnedItems, pinnedKeys),
                              const SizedBox(height: AppSpacing.xl),
                              Row(
                                children: [
                                  Icon(
                                    _viewMode == 'grid'
                                        ? Icons.grid_view_rounded
                                        : Icons.view_list_rounded,
                                    size: 16,
                                    color: secondaryInk,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'All Portals',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: primaryInk,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: surfaceSunken,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${filteredItems.length}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: secondaryInk,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                            ],

                            // Main Portals Grid / List
                            _buildPortalsCollection(
                              filteredItems,
                              pinnedKeys,
                              extraTiles: widget.extraTiles,
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _PortalViewModeButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  const _PortalViewModeButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isSelected
            ? (isDark ? AppColors.darkSurfacePanel : AppColors.surfacePanel)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
        elevation: isSelected ? 1 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Icon(
              icon,
              size: 18,
              color: isSelected
                  ? (isDark ? const Color(0xFF818CF8) : AppColors.accentIndigo)
                  : AppColors.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays an expansive full-dialog zoom view for any portal logo, allowing
/// interactive scroll-wheel zooming, panning, and a direct "Open in Browser" button.
void showPortalLogoDialog({
  required BuildContext context,
  required String name,
  required IconData icon,
  required Color color,
  required VoidCallback onOpenInBrowser,
  String? imageUrl,
  String? categoryLabel,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) {
      final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
      final surface = isDark ? AppColors.darkSurfacePanel : Colors.white;
      final primaryInk = isDark ? AppColors.darkInkPrimary : AppColors.inkPrimary;
      final secondaryInk = isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary;
      final lineBorder = isDark ? AppColors.darkLineHairline : AppColors.lineHairline;
      final TransformationController transformController = TransformationController();

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 780, maxHeight: 620),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: lineBorder.withValues(alpha: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.25),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top brand accent stripe
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                  ),
                ),

                // Dialog Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 16, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: primaryInk,
                              ),
                            ),
                            if (categoryLabel != null && categoryLabel.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  categoryLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryInk,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Tooltip(
                        message: 'Minimize / Close (Esc)',
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: secondaryInk,
                          hoverColor: isDark ? Colors.white10 : Colors.black12,
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: lineBorder.withValues(alpha: 0.6)),

                // Interactive Zoom Canvas
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        width: double.infinity,
                        height: double.infinity,
                        child: InteractiveViewer(
                          transformationController: transformController,
                          minScale: 0.5,
                          maxScale: 6.0,
                          boundaryMargin: const EdgeInsets.all(60),
                          child: Center(
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(28.0),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(icon, color: color, size: 100),
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return Center(
                                          child: SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: color,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Icon(icon, color: color, size: 100),
                          ),
                        ),
                      ),

                      // Tooltip hint on bottom-left
                      Positioned(
                        bottom: 12,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: surface.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: lineBorder.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.pinch_rounded, size: 13, color: secondaryInk),
                              const SizedBox(width: 5),
                              Text(
                                'Scroll wheel to zoom, drag to pan',
                                style: TextStyle(fontSize: 11, color: secondaryInk),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Reset zoom button on bottom-right
                      Positioned(
                        bottom: 10,
                        right: 16,
                        child: Tooltip(
                          message: 'Reset zoom level',
                          child: Material(
                            color: surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                            elevation: 1,
                            child: InkWell(
                              onTap: () => transformController.value = Matrix4.identity(),
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.restart_alt_rounded, size: 14, color: secondaryInk),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Reset',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: secondaryInk,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: lineBorder.withValues(alpha: 0.6)),

                // Footer Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: secondaryInk,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          onOpenInBrowser();
                        },
                        icon: const Icon(Icons.open_in_browser_rounded, size: 17),
                        label: const Text('Open in Browser'),
                        style: FilledButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class PortalCardTile extends StatefulWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String caption;
  final String? categoryLabel;
  final String? imageUrl;
  final bool isPinned;
  final VoidCallback? onTogglePin;

  const PortalCardTile({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
    this.caption = 'Open in Browser',
    this.categoryLabel,
    this.imageUrl,
    this.isPinned = false,
    this.onTogglePin,
  });

  @override
  State<PortalCardTile> createState() => _PortalCardTileState();
}

class _PortalCardTileState extends State<PortalCardTile> {
  bool _isHovered = false;
  bool _isFocused = false;

  void _openZoom() {
    showPortalLogoDialog(
      context: context,
      name: widget.name,
      icon: widget.icon,
      color: widget.color,
      onOpenInBrowser: widget.onTap,
      imageUrl: widget.imageUrl,
      categoryLabel: widget.categoryLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfacePanel = isDark ? AppColors.darkSurfacePanel : AppColors.surfacePanel;
    final lineBorder = isDark ? AppColors.darkLineHairline : AppColors.lineHairline;
    final primaryInk = isDark ? AppColors.darkInkPrimary : AppColors.inkPrimary;
    final secondaryInk = isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -3.5 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: surfacePanel,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: isDark ? 0.28 : 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  ...AppColors.softShadow(opacity: isDark ? 0.25 : 0.07),
                ]
              : (_isFocused
                  ? [
                      BoxShadow(
                        color: isDark
                            ? const Color(0xFF818CF8).withValues(alpha: 0.70)
                            : AppColors.accentIndigo.withValues(alpha: 0.45),
                        blurRadius: 0,
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: AppColors.accentIndigo.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : AppColors.softShadow(opacity: isDark ? 0.12 : 0.04)),
          border: Border.all(
            color: _isFocused
                ? (isDark ? const Color(0xFF818CF8) : AppColors.accentIndigo)
                : (_isHovered
                    ? widget.color.withValues(alpha: 0.55)
                    : lineBorder.withValues(alpha: 0.8)),
            width: _isFocused ? 2.0 : (_isHovered ? 1.5 : 1.0),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onFocusChange: (focused) => setState(() => _isFocused = focused),
            hoverColor: Colors.transparent,
            splashColor: widget.color.withValues(alpha: 0.08),
            highlightColor: widget.color.withValues(alpha: 0.04),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top brand accent stripe
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: _isHovered ? 5 : 4,
                      decoration: BoxDecoration(
                        color: widget.color,
                        gradient: LinearGradient(
                          colors: [
                            widget.color,
                            widget.color.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card inner space dedicated to crisp, expansive logo presentation with interactive zoom
                            Expanded(
                              child: MouseRegion(
                                cursor: SystemMouseCursors.zoomIn,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _openZoom,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: double.infinity,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: widget.color.withValues(
                                        alpha: isDark
                                            ? (_isHovered ? 0.22 : 0.12)
                                            : (_isHovered ? 0.14 : 0.06),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: widget.color.withValues(
                                          alpha: _isHovered ? 0.50 : 0.22,
                                        ),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                                              ? Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 14.0,
                                                    vertical: 8.0,
                                                  ),
                                                  child: Image.network(
                                                    widget.imageUrl!,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) =>
                                                        Icon(widget.icon, color: widget.color, size: 38),
                                                    loadingBuilder: (context, child, progress) {
                                                      if (progress == null) return child;
                                                      return Center(
                                                        child: SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: widget.color,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Icon(widget.icon, color: widget.color, size: 38),
                                        ),

                                        // Hover zoom hint icon pill at top-left of the logo tile
                                        Positioned(
                                          top: 6,
                                          left: 6,
                                          child: AnimatedOpacity(
                                            opacity: _isHovered ? 1.0 : 0.0,
                                            duration: const Duration(milliseconds: 150),
                                            child: Tooltip(
                                              message: 'Click to zoom logo',
                                              child: Container(
                                                padding: const EdgeInsets.all(4.0),
                                                decoration: BoxDecoration(
                                                  color: surfacePanel.withValues(alpha: 0.92),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: widget.color.withValues(alpha: 0.35),
                                                    width: 1,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.12),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  Icons.zoom_in_rounded,
                                                  size: 14,
                                                  color: widget.color,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Portal Name at bottom
                            Text(
                              widget.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: _isHovered ? widget.color : primaryInk,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Expand / Zoom button floating in top-left corner
                Positioned(
                  top: 10,
                  left: 10,
                  child: AnimatedOpacity(
                    opacity: (_isHovered || _isFocused) ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Material(
                      color: surfacePanel.withValues(alpha: 0.90),
                      shape: const CircleBorder(),
                      elevation: _isHovered ? 2 : 0,
                      shadowColor: Colors.black26,
                      child: Tooltip(
                        message: 'Expand & zoom logo',
                        child: InkWell(
                          onTap: _openZoom,
                          borderRadius: BorderRadius.circular(999),
                          hoverColor: widget.color.withValues(alpha: 0.15),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.open_in_full_rounded,
                              size: 15,
                              color: secondaryInk,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Star Pin button floating cleanly in the top-right corner
                if (widget.onTogglePin != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: AnimatedOpacity(
                      opacity: (widget.isPinned || _isHovered || _isFocused) ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      child: Material(
                        color: surfacePanel.withValues(alpha: 0.88),
                        shape: const CircleBorder(),
                        elevation: _isHovered ? 2 : 0,
                        shadowColor: Colors.black26,
                        child: Tooltip(
                          message: widget.isPinned ? 'Unpin from favorites' : 'Pin to favorites',
                          child: InkWell(
                            onTap: widget.onTogglePin,
                            borderRadius: BorderRadius.circular(999),
                            hoverColor: AppColors.signalAmber.withValues(alpha: 0.15),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                widget.isPinned
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 18,
                                color: widget.isPinned
                                    ? AppColors.signalAmber
                                    : secondaryInk,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PortalListTile extends StatefulWidget {
  final String name;
  final String url;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tabName;
  final String? imageUrl;
  final bool isPinned;
  final VoidCallback? onTogglePin;

  const PortalListTile({
    super.key,
    required this.name,
    required this.url,
    required this.icon,
    required this.color,
    required this.onTap,
    this.tabName,
    this.imageUrl,
    this.isPinned = false,
    this.onTogglePin,
  });

  @override
  State<PortalListTile> createState() => _PortalListTileState();
}

class _PortalListTileState extends State<PortalListTile> {
  bool _isHovered = false;
  bool _isFocused = false;

  String _getHost() {
    try {
      final uri = Uri.parse(widget.url);
      if (uri.host.isNotEmpty) return uri.host;
    } catch (_) {}
    return 'Web Portal';
  }

  @override
  Widget build(BuildContext context) {
    final host = _getHost();
    final cleanTab = widget.tabName?.trim();
    final showTab = cleanTab != null && cleanTab.isNotEmpty && !isPortalOwnershipLabel(cleanTab);
    final subtitle = showTab ? '$cleanTab • $host' : host;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfacePanel = isDark ? AppColors.darkSurfacePanel : AppColors.surfacePanel;
    final surfaceSunken = isDark ? AppColors.darkSurfaceSunken : AppColors.surfaceSunken;
    final lineBorder = isDark ? AppColors.darkLineHairline : AppColors.lineHairline;
    final primaryInk = isDark ? AppColors.darkInkPrimary : AppColors.inkPrimary;
    final secondaryInk = isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -2.0 : 0.0, 0.0),
        height: 64,
        decoration: BoxDecoration(
          color: surfacePanel,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: isDark ? 0.22 : 0.14),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                  ...AppColors.softShadow(opacity: isDark ? 0.20 : 0.06),
                ]
              : (_isFocused
                  ? [
                      BoxShadow(
                        color: isDark
                            ? const Color(0xFF818CF8).withValues(alpha: 0.70)
                            : AppColors.accentIndigo.withValues(alpha: 0.45),
                        blurRadius: 0,
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: AppColors.accentIndigo.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : AppColors.softShadow(opacity: isDark ? 0.08 : 0.03)),
          border: Border.all(
            color: _isFocused
                ? (isDark ? const Color(0xFF818CF8) : AppColors.accentIndigo)
                : (_isHovered
                    ? widget.color.withValues(alpha: 0.45)
                    : lineBorder.withValues(alpha: 0.8)),
            width: _isFocused ? 2.0 : (_isHovered ? 1.4 : 1.0),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onFocusChange: (focused) => setState(() => _isFocused = focused),
            hoverColor: Colors.transparent,
            splashColor: widget.color.withValues(alpha: 0.08),
            highlightColor: widget.color.withValues(alpha: 0.04),
            child: Row(
              children: [
                // Left brand accent stripe
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _isHovered ? 5 : 4,
                  height: double.infinity,
                  color: widget.color,
                ),
                const SizedBox(width: 14),

                // Icon / image badge (42x42 uniform rounded logo tile with zoom on click)
                Tooltip(
                  message: 'Click to zoom logo',
                  child: MouseRegion(
                    cursor: SystemMouseCursors.zoomIn,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        showPortalLogoDialog(
                          context: context,
                          name: widget.name,
                          icon: widget.icon,
                          color: widget.color,
                          onOpenInBrowser: widget.onTap,
                          imageUrl: widget.imageUrl,
                          categoryLabel: widget.tabName,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 42,
                        height: 42,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: widget.color.withValues(
                            alpha: isDark
                                ? (_isHovered ? 0.24 : 0.14)
                                : (_isHovered ? 0.16 : 0.08),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: widget.color.withValues(
                              alpha: _isHovered ? 0.42 : 0.20,
                            ),
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Image.network(
                                    widget.imageUrl!,
                                    fit: BoxFit.contain,
                                    width: 32,
                                    height: 32,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(widget.icon, color: widget.color, size: 22),
                                  ),
                                )
                              : Icon(widget.icon, color: widget.color, size: 22),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name and subtitle
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: _isHovered ? widget.color : primaryInk,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: secondaryInk,
                        ),
                      ),
                    ],
                  ),
                ),

                // Star Pin Button
                if (widget.onTogglePin != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Tooltip(
                      message: widget.isPinned ? 'Unpin from favorites' : 'Pin to favorites',
                      child: IconButton(
                        icon: Icon(
                          widget.isPinned
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: widget.isPinned
                              ? AppColors.signalAmber
                              : AppColors.inkMuted,
                          size: 20,
                        ),
                        onPressed: widget.onTogglePin,
                      ),
                    ),
                  ),

                // Trailing Action Launch Icon
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? widget.color.withValues(alpha: isDark ? 0.22 : 0.12)
                          : surfaceSunken,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _isHovered
                            ? widget.color.withValues(alpha: 0.35)
                            : lineBorder,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: _isHovered ? widget.color : secondaryInk,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

