import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared_widgets/gradient_filled_button.dart';
import '../../../../shared_widgets/page_header.dart';
import '../../data/portal_admin_repository_impl.dart';
import '../../domain/entities/admin_monthly_request.dart';
import '../../domain/repositories/portal_admin_repository.dart';
import 'portal_users_admin_screen.dart';

class MonthlyOtpVerificationScreen extends ConsumerStatefulWidget {
  const MonthlyOtpVerificationScreen({super.key});

  @override
  ConsumerState<MonthlyOtpVerificationScreen> createState() =>
      _MonthlyOtpVerificationScreenState();
}

class _MonthlyOtpVerificationScreenState
    extends ConsumerState<MonthlyOtpVerificationScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<AdminMonthlyRequest>? _requests;
  String? _errorMessage;
  bool _isLoading = false;
  String _selectedStatus = 'all'; // 'all', 'pending_approval', 'approved', 'rejected'
  String _searchQuery = '';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _surfacePanel =>
      _isDark ? AppColors.darkSurfacePanel : AppColors.surfacePanel;
  Color get _surfaceSunken =>
      _isDark ? AppColors.darkSurfaceSunken : AppColors.surfaceSunken;
  Color get _lineBorder =>
      _isDark ? AppColors.darkLineHairline : AppColors.lineHairline;
  Color get _primaryInk =>
      _isDark ? AppColors.darkInkPrimary : AppColors.inkPrimary;
  Color get _secondaryInk =>
      _isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary;
  Color get _mutedInk =>
      _isDark ? AppColors.darkInkMuted : AppColors.inkMuted;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = ref.read(portalAdminRepositoryProvider);
    final result = await repo.listMonthlyRequests();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      setState(() {
        _requests = result.valueOrNull ?? [];
      });
    } else {
      setState(() {
        _errorMessage =
            result.errorOrNull?.message ?? 'Failed to load requests.';
      });
    }
  }

  Future<void> _approveRequest(AdminMonthlyRequest req) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Approve Monthly Verification'),
        content: Text(
          'Approve 30-day security re-verification for ${req.fullName.isNotEmpty ? req.fullName : req.username}?\n\nThis will restore web portal access for workstation ${req.machineFingerprint.isNotEmpty ? req.machineFingerprint : req.deviceId}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          GradientFilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Approve Access'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final repo = ref.read(portalAdminRepositoryProvider);
    final result = await repo.approveMonthlyRequest(req.id);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Monthly verification approved for ${req.username}.'),
          backgroundColor: AppColors.signalSuccess,
        ),
      );
      _loadRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorOrNull?.message ?? 'Approval failed.'),
          backgroundColor: AppColors.signalError,
        ),
      );
    }
  }

  Future<void> _rejectRequest(AdminMonthlyRequest req) async {
    final reasonCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Reject Verification Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reject monthly verification request for ${req.fullName.isNotEmpty ? req.fullName : req.username}?',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason for Rejection (Optional)',
                border: OutlineInputBorder(),
                hintText: 'e.g. Device not authorized / security concern',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.signalError),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reject Request'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final repo = ref.read(portalAdminRepositoryProvider);
    final result = await repo.rejectMonthlyRequest(
      req.id,
      reason: reasonCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Monthly verification rejected for ${req.username}.'),
          backgroundColor: AppColors.signalAmber,
        ),
      );
      _loadRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorOrNull?.message ?? 'Rejection failed.'),
          backgroundColor: AppColors.signalError,
        ),
      );
    }
  }

  List<AdminMonthlyRequest> _filteredRequests() {
    if (_requests == null) return [];
    return _requests!.where((r) {
      // Status filter
      if (_selectedStatus != 'all') {
        if (_selectedStatus == 'pending_approval') {
          if (r.status != 'pending_approval' && r.status != 'pending_otp') {
            return false;
          }
        } else if (r.status != _selectedStatus) {
          return false;
        }
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = r.username.toLowerCase().contains(q) ||
            r.fullName.toLowerCase().contains(q) ||
            r.email.toLowerCase().contains(q) ||
            r.department.toLowerCase().contains(q) ||
            r.branch.toLowerCase().contains(q) ||
            r.deviceId.toLowerCase().contains(q) ||
            r.machineFingerprint.toLowerCase().contains(q);
        if (!match) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRequests();
    final allRequests = _requests ?? [];
    final pendingCount = allRequests
        .where((r) => r.status == 'pending_approval' || r.status == 'pending_otp')
        .length;
    final approvedCount =
        allRequests.where((r) => r.status == 'approved').length;
    final rejectedCount =
        allRequests.where((r) => r.status == 'rejected').length;

    return Scaffold(
      backgroundColor: _isDark ? AppColors.darkSurfaceCanvas : AppColors.surfaceCanvas,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Bar ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: _surfacePanel,
              border: Border(bottom: BorderSide(color: _lineBorder)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentLedger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.accentLedger,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly OTP Verification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryInk,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Review and approve monthly 30-day security re-verification requests',
                        style: TextStyle(fontSize: 12, color: _mutedInk),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _loadRequests,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),

          // ── Stat Summary Cards ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              0,
            ),
            child: Row(
              children: [
                _buildStatCard(
                  title: 'Pending Approval',
                  count: pendingCount,
                  color: AppColors.signalAmber,
                  icon: Icons.hourglass_top_rounded,
                  isSelected: _selectedStatus == 'pending_approval',
                  onTap: () => setState(() => _selectedStatus =
                      _selectedStatus == 'pending_approval' ? 'all' : 'pending_approval'),
                ),
                const SizedBox(width: AppSpacing.md),
                _buildStatCard(
                  title: 'Approved',
                  count: approvedCount,
                  color: AppColors.signalSuccess,
                  icon: Icons.check_circle_outline,
                  isSelected: _selectedStatus == 'approved',
                  onTap: () => setState(() => _selectedStatus =
                      _selectedStatus == 'approved' ? 'all' : 'approved'),
                ),
                const SizedBox(width: AppSpacing.md),
                _buildStatCard(
                  title: 'Rejected',
                  count: rejectedCount,
                  color: AppColors.signalError,
                  icon: Icons.cancel_outlined,
                  isSelected: _selectedStatus == 'rejected',
                  onTap: () => setState(() => _selectedStatus =
                      _selectedStatus == 'rejected' ? 'all' : 'rejected'),
                ),
                const SizedBox(width: AppSpacing.md),
                _buildStatCard(
                  title: 'Total Requests',
                  count: allRequests.length,
                  color: AppColors.accentLedger,
                  icon: Icons.list_alt_rounded,
                  isSelected: _selectedStatus == 'all',
                  onTap: () => setState(() => _selectedStatus = 'all'),
                ),
              ],
            ),
          ),

          // ── Filter & Search Row ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                    decoration: InputDecoration(
                      hintText:
                          'Search by user name, email, department, device ID, or machine...',
                      hintStyle: TextStyle(fontSize: 13, color: _mutedInk),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: _surfacePanel,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _lineBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _lineBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All')),
                    ButtonSegment(
                      value: 'pending_approval',
                      label: Text('Pending'),
                    ),
                    ButtonSegment(value: 'approved', label: Text('Approved')),
                    ButtonSegment(value: 'rejected', label: Text('Rejected')),
                  ],
                  selected: {_selectedStatus},
                  onSelectionChanged: (val) {
                    setState(() => _selectedStatus = val.first);
                  },
                ),
              ],
            ),
          ),

          // ── Main Content Area ───────────────────────────────────────────
          Expanded(
            child: _isLoading && _requests == null
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.signalError,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: _primaryInk),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _loadRequests,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_outlined,
                                  size: 48,
                                  color: _mutedInk.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _requests?.isEmpty == true
                                      ? 'No monthly verification requests found.'
                                      : 'No requests match your search or filter.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _secondaryInk,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.md,
                            ),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final req = filtered[index];
                              return _buildRequestRow(req);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: _surfacePanel,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : _lineBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 12, color: _mutedInk),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryInk,
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
  }

  Widget _buildRequestRow(AdminMonthlyRequest req) {
    final isPending =
        req.status == 'pending_approval' || req.status == 'pending_otp';
    final isApproved = req.status == 'approved';
    final isRejected = req.status == 'rejected';

    final Color statusColor = isApproved
        ? AppColors.signalSuccess
        : isPending
            ? AppColors.signalAmber
            : AppColors.signalError;

    final String statusLabel = isApproved
        ? 'Approved'
        : isPending
            ? 'Pending Approval'
            : 'Rejected';

    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(req.requestedAt);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _surfacePanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending
              ? AppColors.signalAmber.withValues(alpha: 0.5)
              : _lineBorder,
          width: isPending ? 1.5 : 1,
        ),
        boxShadow: isPending ? AppColors.softShadow(opacity: 0.04) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isApproved
                  ? Icons.check_circle_outline
                  : isPending
                      ? Icons.hourglass_top_rounded
                      : Icons.cancel_outlined,
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // User info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      req.fullName.isNotEmpty ? req.fullName : req.username,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _primaryInk,
                      ),
                    ),
                    if (req.fullName.isNotEmpty && req.username.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(@${req.username})',
                        style: TextStyle(fontSize: 12, color: _mutedInk),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 14, color: _mutedInk),
                    const SizedBox(width: 4),
                    Text(
                      req.email,
                      style: TextStyle(fontSize: 12, color: _secondaryInk),
                    ),
                    if (req.department.isNotEmpty || req.branch.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: _mutedInk)),
                      const SizedBox(width: 8),
                      Icon(Icons.business_outlined, size: 14, color: _mutedInk),
                      const SizedBox(width: 4),
                      Text(
                        [
                          if (req.department.isNotEmpty) req.department,
                          if (req.branch.isNotEmpty) req.branch,
                        ].join(', '),
                        style: TextStyle(fontSize: 12, color: _mutedInk),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Device & Verification details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.computer_outlined, size: 14, color: _mutedInk),
                    const SizedBox(width: 4),
                    Text(
                      req.machineFingerprint.isNotEmpty
                          ? req.machineFingerprint
                          : 'Workstation',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _primaryInk,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: req.deviceId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Device ID copied to clipboard.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Text(
                        'ID: ${req.deviceId.length > 12 ? "${req.deviceId.substring(0, 12)}..." : req.deviceId}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: AppColors.accentLedger,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: req.otpVerified
                            ? AppColors.signalSuccess.withValues(alpha: 0.12)
                            : AppColors.signalAmber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        req.otpVerified ? 'OTP Verified' : 'OTP Pending',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: req.otpVerified
                              ? AppColors.signalSuccess
                              : AppColors.signalAmber,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.schedule, size: 13, color: _mutedInk),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 11, color: _mutedInk),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status & Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (isPending)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.signalError,
                        side: const BorderSide(color: AppColors.signalError),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: _isLoading ? null : () => _rejectRequest(req),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.signalSuccess,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.check, size: 14),
                      label: const Text('Approve'),
                      onPressed: _isLoading ? null : () => _approveRequest(req),
                    ),
                  ],
                )
              else if (isApproved && req.approvedAt != null)
                Text(
                  'Approved ${DateFormat("dd MMM, hh:mm a").format(req.approvedAt!)}${req.approverName != null ? " by ${req.approverName}" : ""}',
                  style: TextStyle(fontSize: 11, color: _mutedInk),
                )
              else if (isRejected && req.rejectionReason != null)
                Text(
                  'Reason: ${req.rejectionReason}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.signalError,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

