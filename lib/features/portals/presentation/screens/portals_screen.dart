import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/device_auth/gated_link_launcher.dart';
import '../../../../core/portal_links/pinned_portals_provider.dart';
import '../../../../core/portal_links/portal_link_registry.dart';
import '../../../../core/portal_links/portal_link_catalog_repository.dart';
import '../../../../core/rbac/current_user_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared_widgets/portal_link_grid.dart';
import '../../../device_activation/presentation/controllers/device_access_controller.dart';
import '../../../portal_auth/presentation/controllers/portal_auth_controllers.dart';

/// Unified Portals screen for portal users with:
/// - Instant Quick Search bar
/// - Grid View vs. List View toggle
/// - Pinned / Favorites section
/// - Tactile card and list-row interactions
class PortalsScreen extends ConsumerStatefulWidget {
  const PortalsScreen({super.key});

  @override
  ConsumerState<PortalsScreen> createState() => _PortalsScreenState();
}

class _PortalsScreenState extends ConsumerState<PortalsScreen> {
  List<PortalLink>? _catalog;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _viewMode = 'grid'; // 'grid' | 'list'
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
    _loadViewMode();
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  Future<void> _loadCatalog() async {
    try {
      final links = await PortalLinkCatalogRepository().listActive();
      if (mounted) setState(() => _catalog = links);
    } catch (_) {
      if (mounted) setState(() => _catalog = kAllPortalLinks);
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      ref.invalidate(portalSessionControllerProvider);
      await _loadCatalog();
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
    List<PortalLink> links,
    Set<String> pinnedKeys,
  ) {
    if (_viewMode == 'list') {
      return Column(
        children: [
          for (final link in links)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: PortalListTile(
                name: link.name,
                url: link.url,
                icon: link.icon,
                color: link.color,
                tabName: resolvePortalCategory(link),
                imageUrl: link.imageUrl,
                isPinned: pinnedKeys.contains(link.key),
                onTogglePin: () => ref
                    .read(pinnedPortalsProvider.notifier)
                    .togglePin(link.key),
                onTap: () => launchGatedPortalLink(context, link),
              ),
            ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.lg;
        final availableWidth = constraints.maxWidth;
        // Calculate columns adaptively so cards fill the row from edge to edge
        final cols = (availableWidth / 210.0).floor().clamp(1, 8);
        final itemWidth = (availableWidth - (cols - 1) * spacing) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final link in links)
              SizedBox(
                width: itemWidth,
                height: 184,
                child: PortalCardTile(
                  name: link.name,
                  icon: link.icon,
                  color: link.color,
                  categoryLabel: resolvePortalCategory(link),
                  imageUrl: link.imageUrl,
                  isPinned: pinnedKeys.contains(link.key),
                  onTogglePin: () => ref
                      .read(pinnedPortalsProvider.notifier)
                      .togglePin(link.key),
                  onTap: () => launchGatedPortalLink(context, link),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(portalSessionControllerProvider).valueOrNull;
    final isAdmin = session?.isAdmin ?? false;
    final grantedKeys = session?.grantedLinkKeys.toSet() ?? const <String>{};

    final catalog = _catalog ?? kAllPortalLinks;
    final visibleLinks = isAdmin
        ? catalog
        : catalog.where((link) => grantedKeys.contains(link.key)).toList();

    final pinnedKeys = ref.watch(pinnedPortalsProvider);

    // Apply live search filtering
    final query = _searchQuery.trim().toLowerCase();
    final filteredLinks = query.isEmpty
        ? visibleLinks
        : visibleLinks.where((link) {
            final nameMatch = link.name.toLowerCase().contains(query);
            final tabMatch = link.tabName?.toLowerCase().contains(query) ?? false;
            return nameMatch || tabMatch;
          }).toList();

    final pinnedLinks = filteredLinks
        .where((link) => pinnedKeys.contains(link.key))
        .toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryInk = isDark ? AppColors.darkInkPrimary : AppColors.inkPrimary;
    final secondaryInk = isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary;
    final surfacePanel = isDark ? AppColors.darkSurfacePanel : AppColors.surfacePanel;
    final surfaceSunken = isDark ? AppColors.darkSurfaceSunken : AppColors.surfaceSunken;
    final lineBorder = isDark ? AppColors.darkLineHairline : AppColors.lineHairline;

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

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting Header (Phase B)
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${_getGreeting()}, $rawName',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: primaryInk,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Launch and manage your company portals and services',
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
                tooltip: 'Refresh Portal Permissions',
                onPressed: _isRefreshing ? null : _refreshData,
              ),
            ],
          ),
        ),

        // Large Centered Quick Search Bar Strip & View Mode Switcher
        if (visibleLinks.isNotEmpty)
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
                            ? '${filteredLinks.length} of ${visibleLinks.length} portals'
                            : '${visibleLinks.length} total portals${pinnedKeys.isNotEmpty ? ' • ${pinnedLinks.length} pinned' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: secondaryInk,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // View Mode Toggle (Grid / List)
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
                          _ViewModeIconButton(
                            icon: Icons.grid_view_rounded,
                            tooltip: 'Grid View',
                            isSelected: _viewMode == 'grid',
                            onTap: () => _updateViewMode('grid'),
                          ),
                          const SizedBox(width: 2),
                          _ViewModeIconButton(
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

        // Content Area
        Expanded(
          child: visibleLinks.isEmpty
              ? _NoPortalsEmptyState(onRefresh: _refreshData)
              : filteredLinks.isEmpty
                  ? _NoSearchResultsEmptyState(
                      query: _searchQuery,
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, AppSpacing.scrollBottomPad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Pinned Portals Section (if any pinned and not currently searching)
                          if (query.isEmpty && pinnedLinks.isNotEmpty) ...[
                            _SectionHeader(
                              icon: Icons.star_rounded,
                              iconColor: AppColors.signalAmber,
                              title: 'Pinned Portals',
                              count: pinnedLinks.length,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildPortalsCollection(pinnedLinks, pinnedKeys),
                            const SizedBox(height: AppSpacing.xl),
                            _SectionHeader(
                              icon: _viewMode == 'grid'
                                  ? Icons.grid_view_rounded
                                  : Icons.view_list_rounded,
                              iconColor: secondaryInk,
                              title: 'All Portals',
                              count: filteredLinks.length,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],

                          // 2. Main Portals Grid (Pinned portals still appear in the main grid)
                          _buildPortalsCollection(
                            filteredLinks,
                            pinnedKeys,
                          ),
                        ],
                      ),
                    ),
        ),
      ],
    );

    return content;
  }
}

class _ViewModeIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewModeIconButton({
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

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryInk = isDark ? AppColors.darkInkPrimary : AppColors.inkPrimary;
    final secondaryInk = isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary;
    final surfaceSunken = isDark ? AppColors.darkSurfaceSunken : AppColors.surfaceSunken;

    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Text(
          title,
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
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: secondaryInk,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoSearchResultsEmptyState extends StatelessWidget {
  final String query;
  final VoidCallback onClear;

  const _NoSearchResultsEmptyState({
    required this.query,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfacePanel = isDark ? AppColors.darkSurfacePanel : AppColors.surfacePanel;
    final surfaceSunken = isDark ? AppColors.darkSurfaceSunken : AppColors.surfaceSunken;
    final lineBorder = isDark ? AppColors.darkLineHairline : AppColors.lineHairline;
    final primaryInk = isDark ? AppColors.darkInkPrimary : AppColors.inkPrimary;
    final secondaryInk = isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary;

    return Center(
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
                'No portals matched "$query". Check for typos or clear your search query.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryInk,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.clear_rounded, size: 16),
                label: const Text('Clear Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentIndigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onClear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoPortalsEmptyState extends StatefulWidget {
  final Future<void> Function() onRefresh;

  const _NoPortalsEmptyState({required this.onRefresh});

  @override
  State<_NoPortalsEmptyState> createState() => _NoPortalsEmptyStateState();
}

class _NoPortalsEmptyStateState extends State<_NoPortalsEmptyState> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfacePanel = isDark ? AppColors.darkSurfacePanel : AppColors.surfacePanel;
    final lineBorder = isDark ? AppColors.darkLineHairline : AppColors.lineHairline;
    final primaryInk = isDark ? AppColors.darkInkPrimary : AppColors.inkPrimary;
    final secondaryInk = isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.vpn_lock_outlined,
                  size: 32,
                  color: Color(0xFF0284C7),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Portals Assigned',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primaryInk,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'No sites are provided to your account. Please contact your system administrator to grant access to the required portals.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryInk,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh Permissions'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isRefreshing
                    ? null
                    : () async {
                        setState(() => _isRefreshing = true);
                        try {
                          await widget.onRefresh();
                        } finally {
                          if (mounted) setState(() => _isRefreshing = false);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
