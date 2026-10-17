import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared_widgets/page_header.dart';
import '../../data/portal_admin_repository_impl.dart';
import '../../domain/entities/admin_audit_log.dart';
import '../../domain/entities/admin_portal_user.dart';
import '../../domain/repositories/portal_admin_repository.dart';

final _auditLogRepositoryProvider = Provider<PortalAdminRepository>(
  (ref) => PortalAdminRepositoryImpl(),
);

class AdminAuditLogsScreen extends ConsumerStatefulWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  ConsumerState<AdminAuditLogsScreen> createState() =>
      _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends ConsumerState<AdminAuditLogsScreen> {
  List<AdminAuditLog>? _allLogs;
  List<AdminPortalUser>? _users;
  String? _errorMessage;
  bool _isLoading = false;

  String _searchQuery = '';
  String _selectedCategory = 'all';
  int? _selectedUserId;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _surfacePanel => _isDark ? AppColors.darkSurfacePanel : AppColors.surfacePanel;
  Color get _surfaceSunken => _isDark ? AppColors.darkSurfaceSunken : AppColors.surfaceSunken;
  Color get _lineBorder => _isDark ? AppColors.darkLineHairline : AppColors.lineHairline;
  Color get _primaryInk => _isDark ? AppColors.darkInkPrimary : AppColors.inkPrimary;
  Color get _secondaryInk => _isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary;
  Color get _mutedInk => _isDark ? AppColors.darkInkMuted : AppColors.inkMuted;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = ref.read(_auditLogRepositoryProvider);
    final result = await repo.listAuditLogs(limit: 200);
    final logResult = await repo.listAuditLogs(limit: 200);
    final userResult = await repo.listUsers();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _allLogs = result.valueOrNull;
      _errorMessage = result.errorOrNull?.message;
      _allLogs = logResult.valueOrNull;
      _users = userResult.valueOrNull;
      _errorMessage = logResult.errorOrNull?.message;
    });
  }

  List<AdminAuditLog> get _filteredLogs {
    final logs = _allLogs ?? [];
    return logs.where((log) {
      if (_selectedUserId != null && log.userId != _selectedUserId) {
        return false;
      }
      final ev = log.eventType.toLowerCase();
      if (_selectedCategory == 'revoked' && !ev.contains('revoked')) {
        return false;
      }
      if (_selectedCategory == 'approved' && !ev.contains('approved')) {
        return false;
      }
      if (_selectedCategory == 'rejected' && !ev.contains('rejected')) {
        return false;
      }
      if (_selectedCategory == 'requested' && !ev.contains('requested')) {
        return false;
      }
      if (_selectedCategory == 'registered' &&
          !(ev.contains('registered') || ev.contains('issued'))) {
        return false;
      }
      if (_selectedCategory == 'otp' && !ev.contains('otp')) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchEvent = log.eventType.toLowerCase().contains(q);
        final matchActor = log.actor.toLowerCase().contains(q);
        final matchDevice = (log.deviceId ?? '').toLowerCase().contains(q);
        final matchUser = (log.userId?.toString() ?? '').contains(q);
        final matchMeta = log.metadata.toLowerCase().contains(q);
        if (!matchEvent &&
            !matchActor &&
            !matchDevice &&
            !matchUser &&
            !matchMeta) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(appRefreshSignalProvider, (prev, next) {
      _fetchLogs();
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Security & Access Audit Logs',
          icon: Icons.history_outlined,
          accentColor: const Color(0xFF0F172A),
          actions: [
            IconButton(
              tooltip: 'Refresh logs',
              onPressed: _isLoading ? null : _fetchLogs,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        _buildFilterBar(),
        const Divider(height: 1),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: _surfacePanel,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(fontSize: 13, color: _primaryInk),
                  decoration: InputDecoration(
                    hintText:
                        'Search by actor, event, device ID, or user ID...',
                    hintStyle: TextStyle(fontSize: 13, color: _mutedInk),
                    prefixIcon: Icon(Icons.search, size: 20, color: _secondaryInk),
                    isDense: true,
                    filled: true,
                    fillColor: _surfaceSunken,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: _lineBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: _lineBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.accentIndigo,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                ),
              ),
              const SizedBox(width: 12),
              // User Filter Dropdown
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: _surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _lineBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: _selectedUserId,
                    dropdownColor: _surfacePanel,
                    isDense: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: _secondaryInk,
                    ),
                    hint: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: _secondaryInk,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'All Users',
                          style: TextStyle(
                            fontSize: 13,
                            color: _primaryInk,
                          ),
                        ),
                      ],
                    ),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 16,
                              color: _secondaryInk,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'All Users',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _primaryInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_users != null)
                        ..._users!.map((u) {
                          return DropdownMenuItem<int?>(
                            value: u.id,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: _secondaryInk,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${u.fullName} (@${u.username})',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _primaryInk,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedUserId = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (_allLogs != null)
                Text(
                  '${_filteredLogs.length} of ${_allLogs!.length} records',
                  style: TextStyle(
                    fontSize: 12,
                    color: _secondaryInk,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('all', 'All Events'),
                const SizedBox(width: 8),
                _filterChip('revoked', 'Revocations'),
                const SizedBox(width: 8),
                _filterChip('approved', 'Approvals'),
                const SizedBox(width: 8),
                _filterChip('rejected', 'Rejections'),
                const SizedBox(width: 8),
                _filterChip('requested', 'Requests'),
                const SizedBox(width: 8),
                _filterChip('registered', 'Registration & Tokens'),
                const SizedBox(width: 8),
                _filterChip('otp', 'Monthly OTP'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String category, String label) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Colors.white : _primaryInk,
        ),
      ),
      backgroundColor: _surfaceSunken,
      selectedColor: _isDark ? const Color(0xFF6366F1) : AppColors.accentIndigo,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      onSelected: (_) => setState(() => _selectedCategory = category),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _allLogs == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: AppColors.signalError,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.signalError),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _fetchLogs,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredLogs;
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No audit records found matching your filters.',
              style: TextStyle(color: _secondaryInk, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, AppSpacing.scrollBottomPad),
          child: Container(
            decoration: BoxDecoration(
              color: _surfacePanel,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _lineBorder),
              boxShadow: _isDark ? null : AppColors.softShadow(),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth - 40,
                ),
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(
                    _surfaceSunken,
                  ),
                  headingTextStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _primaryInk,
                    letterSpacing: 0.4,
                  ),
                  dataRowMinHeight: 50,
                  dataRowMaxHeight: 58,
                  horizontalMargin: 16,
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('TIMESTAMP')),
                    DataColumn(label: Text('EVENT TYPE')),
                    DataColumn(label: Text('ACTOR')),
                    DataColumn(label: Text('USER ID')),
                    DataColumn(label: Text('DEVICE ID')),
                    DataColumn(label: Text('DETAILS / REASON')),
                    DataColumn(label: Text('ACTION')),
                  ],
                  rows: filtered.map((log) {
                    final summary = _formatMetadataSummary(log.metadata);
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            dateFormat.format(log.createdAt.toLocal()),
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'IBM Plex Mono',
                              color: _primaryInk,
                            ),
                          ),
                        ),
                        DataCell(_buildBadge(log.eventType)),
                        DataCell(
                          Text(
                            log.actor,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _primaryInk,
                            ),
                          ),
                        ),
                        DataCell(
                          log.userId != null
                              ? () {
                                  final u = _users
                                      ?.cast<AdminPortalUser?>()
                                      .firstWhere(
                                        (user) => user?.id == log.userId,
                                        orElse: () => null,
                                      );
                                  return Tooltip(
                                    message: u != null
                                        ? '${u.fullName} (@${u.username})'
                                        : 'User #${log.userId}',
                                    child: Text(
                                      u != null
                                          ? '${u.fullName}\n(#${log.userId})'
                                          : '#${log.userId}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _primaryInk,
                                      ),
                                    ),
                                  );
                                }()
                              : Text(
                                  '—',
                                  style: TextStyle(color: _mutedInk),
                                ),
                        ),
                        DataCell(
                          (log.deviceId != null && log.deviceId!.isNotEmpty)
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 140,
                                      ),
                                      child: Text(
                                        log.deviceId!,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'IBM Plex Mono',
                                          color: _primaryInk,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: Icon(Icons.copy, size: 14, color: _secondaryInk),
                                      tooltip: 'Copy Device ID',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(text: log.deviceId!),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Device ID copied to clipboard',
                                            ),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : Text(
                                  '—',
                                  style: TextStyle(color: _mutedInk),
                                ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 260),
                            child: Text(
                              summary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: _secondaryInk,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primaryInk,
                              side: BorderSide(color: _lineBorder),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: Icon(
                              Icons.visibility_outlined,
                              size: 14,
                              color: _primaryInk,
                            ),
                            label: Text(
                              'View',
                              style: TextStyle(fontSize: 11, color: _primaryInk),
                            ),
                            onPressed: () => _showLogDetails(log),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String eventType) {
    final ev = eventType.toLowerCase();
    Color badgeBg = _isDark ? const Color(0xFF1E293B) : Colors.grey.shade100;
    Color badgeBorder = _isDark ? const Color(0xFF475569) : Colors.grey.shade300;
    Color badgeText = _isDark ? const Color(0xFFE2E8F0) : Colors.grey.shade800;
    IconData badgeIcon = Icons.info_outline;

    if (ev.contains('revoked') || ev.contains('rejected')) {
      badgeBg = _isDark ? const Color(0xFF450A0A) : Colors.red.shade50;
      badgeBorder = _isDark ? const Color(0xFF991B1B) : Colors.red.shade200;
      badgeText = _isDark ? const Color(0xFFFCA5A5) : Colors.red.shade800;
      badgeIcon = Icons.block_rounded;
    } else if (ev.contains('approved')) {
      badgeBg = _isDark ? const Color(0xFF052E16) : Colors.green.shade50;
      badgeBorder = _isDark ? const Color(0xFF166534) : Colors.green.shade200;
      badgeText = _isDark ? const Color(0xFF86EFAC) : Colors.green.shade800;
      badgeIcon = Icons.check_circle_outline;
    } else if (ev.contains('registered') || ev.contains('issued')) {
      badgeBg = _isDark ? const Color(0xFF172554) : Colors.blue.shade50;
      badgeBorder = _isDark ? const Color(0xFF1E40AF) : Colors.blue.shade200;
      badgeText = _isDark ? const Color(0xFF93C5FD) : Colors.blue.shade800;
      badgeIcon = Icons.vpn_key_outlined;
    } else if (ev.contains('otp')) {
      badgeBg = _isDark ? const Color(0xFF042F2E) : Colors.teal.shade50;
      badgeBorder = _isDark ? const Color(0xFF115E59) : Colors.teal.shade200;
      badgeText = _isDark ? const Color(0xFF5EEAD4) : Colors.teal.shade800;
      badgeIcon = Icons.verified_user_outlined;
    } else if (ev.contains('requested')) {
      badgeBg = _isDark ? const Color(0xFF451A03) : Colors.amber.shade50;
      badgeBorder = _isDark ? const Color(0xFF92400E) : Colors.amber.shade200;
      badgeText = _isDark ? const Color(0xFFFCD34D) : Colors.amber.shade900;
      badgeIcon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeText),
          const SizedBox(width: 6),
          Text(
            eventType.toUpperCase().replaceAll('_', ' '),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: badgeText,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMetadataSummary(String metadata) {
    if (metadata.isEmpty) return '—';
    try {
      final decoded = jsonDecode(metadata);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('reason') && decoded['reason'] != null) {
          return 'Reason: ${decoded['reason']}';
        }
        if (decoded.containsKey('rejection_reason') &&
            decoded['rejection_reason'] != null) {
          return 'Reason: ${decoded['rejection_reason']}';
        }
        if (decoded.containsKey('domain') && decoded['domain'] != null) {
          return 'Domain: ${decoded['domain']}';
        }
        final parts = <String>[];
        decoded.forEach((k, v) {
          parts.add('$k: $v');
        });
        return parts.join(' · ');
      }
    } catch (_) {}
    return metadata;
  }

  void _showLogDetails(AdminAuditLog log) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surfacePanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _lineBorder),
        ),
        title: Row(
          children: [
            Icon(Icons.history_outlined, size: 22, color: _primaryInk),
            const SizedBox(width: 8),
            Text(
              'Audit Log Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _primaryInk,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Log ID', '#${log.id}'),
                _detailRow(
                  'Event Type',
                  log.eventType.toUpperCase().replaceAll('_', ' '),
                ),
                _detailRow(
                  'Timestamp',
                  dateFormat.format(log.createdAt.toLocal()),
                ),
                _detailRow('Actor', log.actor),
                if (log.userId != null) _detailRow('User ID', '#${log.userId}'),
                if (log.deviceId != null && log.deviceId!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          'Device ID:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: _secondaryInk,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SelectableText(
                          log.deviceId!,
                          style: TextStyle(
                            fontFamily: 'IBM Plex Mono',
                            fontSize: 12,
                            color: _primaryInk,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, size: 16, color: _secondaryInk),
                        tooltip: 'Copy Device ID',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: log.deviceId!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Device ID copied to clipboard'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                Text(
                  'Metadata / Payload:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: _secondaryInk,
                  ),
                ),
                const SizedBox(height: 6),
                _buildMetadataWidget(log.metadata),
              ],
            ),
          ),
        ),
        actions: [
          if (log.metadata.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy Metadata'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: log.metadata));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Metadata copied to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: _secondaryInk,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: _primaryInk),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataWidget(String metadata) {
    if (metadata.isEmpty) {
      return Text(
        'No additional metadata recorded.',
        style: TextStyle(fontSize: 12, color: _mutedInk),
      );
    }
    try {
      final decoded = jsonDecode(metadata);
      if (decoded is Map<String, dynamic>) {
        final entries = decoded.entries.toList();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _surfaceSunken,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _lineBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final e in entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ${e.key}: ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _primaryInk,
                        ),
                      ),
                      Expanded(
                        child: SelectableText(
                          '${e.value}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _secondaryInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }
    } catch (_) {}

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceSunken,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineBorder),
      ),
      child: SelectableText(
        metadata,
        style: TextStyle(fontSize: 12, color: _primaryInk),
      ),
    );
  }
}
