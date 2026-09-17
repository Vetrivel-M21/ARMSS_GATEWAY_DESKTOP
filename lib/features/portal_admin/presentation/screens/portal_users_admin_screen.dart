import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/portal_links/portal_link_catalog_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared_widgets/change_password_dialog.dart';
import '../../../../shared_widgets/gradient_filled_button.dart';
import '../../../../shared_widgets/page_header.dart';
import '../../data/portal_admin_repository_impl.dart';
import '../../domain/entities/admin_activation_request.dart';
import '../../domain/entities/admin_audit_log.dart';
import '../../domain/entities/admin_device.dart';
import '../../domain/entities/admin_portal_user.dart';
import '../../domain/entities/admin_portal_link.dart';
import '../../domain/entities/portal_link_catalog.dart';
import '../../domain/repositories/portal_admin_repository.dart';
import '../../../portal_auth/presentation/controllers/portal_auth_controllers.dart';
import 'portal_link_form_dialog.dart';

final portalAdminRepositoryProvider = Provider<PortalAdminRepository>(
  (ref) => PortalAdminRepositoryImpl(),
);

/// Admin-only: list every self-registered portal user, approve/revoke their
/// account, view/change their password, grant/revoke per-link access,
/// manage per-device tokens and revocations, and process activation requests.
class PortalUsersAdminScreen extends ConsumerStatefulWidget {
  const PortalUsersAdminScreen({super.key});

  @override
  ConsumerState<PortalUsersAdminScreen> createState() =>
      _PortalUsersAdminScreenState();
}

class _PortalUsersAdminScreenState extends ConsumerState<PortalUsersAdminScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  List<AdminPortalUser>? _users;
  List<AdminDevice>? _devices;
  List<AdminActivationRequest>? _requests;
  List<AdminAuditLog>? _auditLogs;
  List<AdminPortalLink>? _links;

  String? _userError;
  String? _deviceError;
  String? _requestError;
  String? _auditLogError;
  String? _linkError;

  bool _loadingDevices = false;
  bool _loadingRequests = false;
  bool _loadingAuditLogs = false;
  int? _selectedAuditUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabController.index == 1 && _devices == null) _loadDevices();
      if (_tabController.index == 2 && _requests == null) _loadRequests();
      if (_tabController.index == 3 && _auditLogs == null) _loadAuditLogs();
      if (_tabController.index == 3) {
        if (_auditLogs == null) _loadAuditLogs();
        if (_users == null) _loadUsers();
      }
      if (_tabController.index == 4 && _links == null) _loadLinks();
    });
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final result = await ref.read(portalAdminRepositoryProvider).listUsers();
    if (!mounted) return;
    setState(() {
      _users = result.valueOrNull;
      _userError = result.errorOrNull?.message;
    });
  }

  Future<void> _loadDevices() async {
    setState(() => _loadingDevices = true);
    final result = await ref.read(portalAdminRepositoryProvider).listDevices();
    if (!mounted) return;
    setState(() {
      _loadingDevices = false;
      _devices = result.valueOrNull;
      _deviceError = result.errorOrNull?.message;
    });
  }

  Future<void> _loadRequests() async {
    setState(() => _loadingRequests = true);
    final result = await ref
        .read(portalAdminRepositoryProvider)
        .listActivationRequests();
    if (!mounted) return;
    setState(() {
      _loadingRequests = false;
      _requests = result.valueOrNull;
      _requestError = result.errorOrNull?.message;
    });
  }

  Future<void> _loadAuditLogs() async {
    setState(() => _loadingAuditLogs = true);
    final result = await ref
        .read(portalAdminRepositoryProvider)
        .listAuditLogs(limit: 100);
    if (!mounted) return;
    setState(() {
      _loadingAuditLogs = false;
      _auditLogs = result.valueOrNull;
      _auditLogError = result.errorOrNull?.message;
    });
  }

  void _reloadCurrent() {
    switch (_tabController.index) {
      case 0:
        _loadUsers();
        break;
      case 1:
        _loadDevices();
        break;
      case 2:
        _loadRequests();
        break;
      case 3:
        _loadAuditLogs();
        if (_users == null) _loadUsers();
        break;
      case 4:
        _loadLinks();
        break;
    }
  }

  Future<void> _loadLinks() async {
    final result = await ref.read(portalAdminRepositoryProvider).listLinks();
    if (!mounted) return;
    setState(() {
      _links = result.valueOrNull;
      _linkError = result.errorOrNull?.message;
    });
  }

  Future<void> _editLink([AdminPortalLink? link]) async {
    final value = await showDialog<LinkFormValue>(
      context: context,
      builder: (_) => PortalLinkFormDialog(link: link),
    );
    if (value == null || !mounted) return;
    final result = await ref.read(portalAdminRepositoryProvider).saveLink(
          key: link?.key,
          tabName: value.tabName,
          name: value.name,
          url: value.url,
          sortOrder: value.sortOrder,
          isActive: value.isActive,
        );
    if (!mounted) return;
    if (result.isSuccess) {
      if (value.image != null) {
        await ref.read(portalAdminRepositoryProvider).uploadLinkImage(
              key: result.valueOrNull!.key,
              image: value.image!,
            );
      }
      ref.invalidate(portalCatalogLinksProvider);
      ref.read(appRefreshSignalProvider.notifier).update((v) => v + 1);
      _loadLinks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.errorOrNull?.message ?? 'Unable to save portal link.')));
    }
  }

  Future<void> _deleteLink(AdminPortalLink link) async {
    final result = await ref.read(portalAdminRepositoryProvider).deleteLink(link.key);
    if (!mounted) return;
    if (result.isSuccess) {
      ref.invalidate(portalCatalogLinksProvider);
      ref.read(appRefreshSignalProvider.notifier).update((v) => v + 1);
      _loadLinks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.errorOrNull?.message ?? 'Unable to deactivate portal link.')));
    }
  }

  Future<void> _setActive(AdminPortalUser user, bool isActive) async {
    final result = await ref
        .read(portalAdminRepositoryProvider)
        .setActive(userId: user.id, isActive: isActive);
    if (!mounted) return;
    if (result.isSuccess) {
      _loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorOrNull?.message ?? 'Failed to update account status.',
          ),
        ),
      );
    }
  }

  Future<void> _viewPassword(AdminPortalUser user) async {
    final result = await ref
        .read(portalAdminRepositoryProvider)
        .revealPassword(user.id);
    if (!mounted) return;
    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorOrNull?.message ?? 'Failed to load password.',
          ),
        ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Password — ${user.fullName}'),
        content: SelectableText(
          result.valueOrNull!,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(AdminPortalUser user) async {
    final newPassword = await showDialog<String>(
      context: context,
      builder: (_) => _ChangePasswordDialog(user: user),
    );
    if (newPassword == null || newPassword.isEmpty || !mounted) return;

    final result = await ref
        .read(portalAdminRepositoryProvider)
        .setPassword(userId: user.id, newPassword: newPassword);
    if (!mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password updated.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorOrNull?.message ?? 'Failed to update password.',
          ),
        ),
      );
    }
  }

  Future<void> _editGrants(AdminPortalUser user) async {
    final selected = await showDialog<Set<String>>(
      context: context,
      builder: (_) => _GrantsDialog(user: user),
    );
    if (selected == null || !mounted) return;

    final result = await ref
        .read(portalAdminRepositoryProvider)
        .setGrants(userId: user.id, linkKeys: selected.toList());
    if (!mounted) return;
    if (result.isSuccess) {
      _loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorOrNull?.message ?? 'Failed to save grants.',
          ),
        ),
      );
    }
  }

  Future<void> _deleteUser(AdminPortalUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text(
          'Are you sure you want to permanently delete user "${user.fullName}" (@${user.username})?\n\nThis will remove their account, portal grants, registered devices, and token access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.signalError),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete User'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await ref
        .read(portalAdminRepositoryProvider)
        .deleteUser(user.id);
    if (!mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User "${user.fullName}" deleted successfully.'),
        ),
      );
      _loadUsers();
      _devices = null;
      _requests = null;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorOrNull?.message ?? 'Failed to delete user.',
          ),
        ),
      );
    }
  }

  Future<void> _changeRole(AdminPortalUser user) async {
    final isCurrentAdmin = user.isAdmin;
    final targetRole = isCurrentAdmin ? 'user' : 'admin';
    final actionTitle = isCurrentAdmin
        ? 'Demote to Regular User'
        : 'Promote to Administrator';
    final actionDescription = isCurrentAdmin
        ? 'Are you sure you want to demote "${user.fullName}" (@${user.username}) to a regular user?\n\nThey will lose administrative privileges and will only access portals granted to them.'
        : 'Are you sure you want to promote "${user.fullName}" (@${user.username}) to Administrator?\n\nThey will receive full administrative access to manage users, devices, portal links, and settings.';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(actionTitle),
        content: Text(actionDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(actionTitle),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await ref
        .read(portalAdminRepositoryProvider)
        .setRole(userId: user.id, role: targetRole);
    if (!mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Role for "${user.fullName}" updated to ${targetRole.toUpperCase()}.',
          ),
        ),
      );
      _loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorOrNull?.message ?? 'Failed to update user role.',
          ),
        ),
      );
    }
  }

  Future<void> _revokeDevice(AdminDevice device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Revoke Device Token?'),
        content: Text(
          'Are you sure you want to revoke access for device "${device.deviceId}" belonging to ${device.fullName}? The user will be blocked immediately until an activation request is approved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.signalError),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Revoke Token'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await ref
        .read(portalAdminRepositoryProvider)
        .revokeDevice(device.deviceId);
    if (!mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Device token revoked.')));
      _loadDevices();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorOrNull?.message ?? 'Failed to revoke token.',
          ),
        ),
      );
    }
  }

  Future<void> _assignDeviceUser(AdminDevice device) async {
    final users = _users;
    if (users == null || users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No users available to assign.')),
      );
      return;
    }

    int? selectedUserId = device.userId > 0 ? device.userId : users.first.id;

    final assigned = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Assign User to Device'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select which user account should be assigned to this device (${device.machineFingerprint.isNotEmpty ? device.machineFingerprint : device.deviceId}):',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: users.any((u) => u.id == selectedUserId)
                        ? selectedUserId
                        : users.first.id,
                    decoration: const InputDecoration(
                      labelText: 'Assigned User',
                      border: OutlineInputBorder(),
                    ),
                    items: users.map((u) {
                      return DropdownMenuItem<int>(
                        value: u.id,
                        child: Text('${u.fullName} (@${u.username})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedUserId = val);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(selectedUserId),
                  child: const Text('Assign User'),
                ),
              ],
            );
          },
        );
      },
    );

    if (assigned == null || !mounted) return;

    final result = await ref
        .read(portalAdminRepositoryProvider)
        .assignDeviceUser(
          deviceId: device.deviceId,
          userId: assigned,
          machineFingerprint: device.machineFingerprint,
        );

    if (!mounted) return;
    if (result.isSuccess) {
      final assignedUser = users.firstWhere(
        (u) => u.id == assigned,
        orElse: () => users.first,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Device successfully assigned to "${assignedUser.fullName}".',
          ),
        ),
      );
      _loadDevices();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorOrNull?.message ?? 'Failed to assign user.',
          ),
        ),
      );
    }
  }

  Future<void> _approveRequest(AdminActivationRequest req) async {
    final result = await ref
        .read(portalAdminRepositoryProvider)
        .approveActivationRequest(req.requestId);
    if (!mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activation request approved!')),
      );
      _loadRequests();
      _loadDevices();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorOrNull?.message ?? 'Failed to approve request.',
          ),
        ),
      );
    }
  }

  Future<void> _rejectRequest(AdminActivationRequest req) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Reject Activation Request'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Rejection Reason (optional)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.signalError,
              ),
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    if (reason == null || !mounted) return;

    final result = await ref
        .read(portalAdminRepositoryProvider)
        .rejectActivationRequest(req.requestId, reason: reason);
    if (!mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activation request rejected.')),
      );
      _loadRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorOrNull?.message ?? 'Failed to reject request.',
          ),
        ),
      );
    }
  }

  Future<void> _showInstallerPasswordDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _InstallerPasswordDialog(),
    );
  }

  Future<void> _showTokenRestrictionDialog() async {
    final repository = ref.read(portalAdminRepositoryProvider);
    final result = await repository.getTokenRestrictionEnabled();
    if (!mounted) return;
    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorOrNull?.message ?? 'Unable to load token restriction.',
          ),
        ),
      );
      return;
    }
    var enabled = result.valueOrNull ?? true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Gateway Token Restriction'),
          content: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              enabled ? 'Restriction enabled' : 'Restriction disabled',
            ),
            subtitle: Text(
              enabled
                  ? 'Device ID and token are required.'
                  : 'Token validation accepts every request.',
            ),
            value: enabled,
            onChanged: (value) async {
              final saveResult = await repository.setTokenRestrictionEnabled(
                value,
              );
              if (!saveResult.isSuccess || !dialogContext.mounted) return;
              setDialogState(() => enabled = value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(appRefreshSignalProvider, (prev, next) {
      _reloadCurrent();
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Portal & Device Administration',
          icon: Icons.admin_panel_settings_outlined,
          accentColor: const Color(0xFF334155),
          actions: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentLedger,
                backgroundColor: AppColors.accentLedgerTint,
                side: const BorderSide(
                  color: AppColors.accentLedger,
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(
                Icons.key_rounded,
                size: 16,
                color: AppColors.accentLedger,
              ),
              label: const Text(
                'Installer Password',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.accentLedger,
                ),
              ),
              onPressed: _showInstallerPasswordDialog,
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentLedger,
                backgroundColor: AppColors.accentLedgerTint,
                side: const BorderSide(
                  color: AppColors.accentLedger,
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(
                Icons.lock_reset_rounded,
                size: 16,
                color: AppColors.accentLedger,
              ),
              label: const Text(
                'Admin Password',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.accentLedger,
                ),
              ),
              onPressed: () => showChangePasswordDialog(context),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.security_outlined, size: 16),
              label: const Text('Token Restriction'),
              onPressed: _showTokenRestrictionDialog,
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _reloadCurrent,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        Container(
          color: AppColors.surfacePanel,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.accentLedger,
            unselectedLabelColor: AppColors.inkSecondary,
            indicatorColor: AppColors.accentLedger,
            tabs: const [
              Tab(
                icon: Icon(Icons.people_outline, size: 18),
                text: 'Users & Grants',
              ),
              Tab(
                icon: Icon(Icons.devices_outlined, size: 18),
                text: 'Devices & Tokens',
              ),
              Tab(
                icon: Icon(Icons.vpn_key_outlined, size: 18),
                text: 'Activation Requests',
              ),
              Tab(
                icon: Icon(Icons.history_outlined, size: 18),
                text: 'Audit Logs',
              ),
              Tab(
                icon: Icon(Icons.language_outlined, size: 18),
                text: 'Web Apps',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUsersTab(),
              _buildDevicesTab(),
              _buildRequestsTab(),
              _buildAuditLogsTab(),
              _buildLinksTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab() {
    if (_userError != null) return Center(child: Text(_userError!));
    final users = _users;
    if (users == null) return const Center(child: CircularProgressIndicator());
    if (users.isEmpty) {
      return const Center(child: Text('No portal users have registered yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = users[index];
        final isAdmin = user.isAdmin;
        return ListTile(
          title: Row(
            children: [
              Text(
                user.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isAdmin
                      ? AppColors.accentLedger.withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAdmin
                        ? AppColors.accentLedger.withValues(alpha: 0.4)
                        : Colors.grey.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAdmin
                          ? Icons.admin_panel_settings_rounded
                          : Icons.person_rounded,
                      size: 13,
                      color: isAdmin ? AppColors.accentLedger : Colors.grey[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAdmin ? 'ADMIN' : 'USER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isAdmin ? AppColors.accentLedger : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Text(
            '${user.username} · ${user.email} · ${user.department} · ${user.branch}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.isActive ? 'Approved' : 'Pending',
                style: TextStyle(
                  color: user.isActive
                      ? AppColors.signalCredit
                      : AppColors.signalAmber,
                ),
              ),
              Switch(
                value: user.isActive,
                onChanged: (v) => _setActive(user, v),
              ),
              const SizedBox(width: 8),
              Text('${user.grantedLinkKeys.length} granted'),
              PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'view_password') _viewPassword(user);
                  if (action == 'change_password') _changePassword(user);
                  if (action == 'change_role') _changeRole(user);
                  if (action == 'delete_user') _deleteUser(user);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view_password',
                    child: Text('View Password'),
                  ),
                  const PopupMenuItem(
                    value: 'change_password',
                    child: Text('Change Password'),
                  ),
                  PopupMenuItem(
                    value: 'change_role',
                    child: Row(
                      children: [
                        Icon(
                          isAdmin
                              ? Icons.person_outline
                              : Icons.admin_panel_settings_outlined,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isAdmin
                              ? 'Demote to User'
                              : 'Promote to Admin',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete_user',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.signalError,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Delete User',
                          style: TextStyle(color: AppColors.signalError),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.signalError,
                  size: 20,
                ),
                tooltip: 'Delete User',
                onPressed: () => _deleteUser(user),
              ),
            ],
          ),
          onTap: () => _editGrants(user),
        );
      },
    );
  }

  Widget _buildLinksTab() {
    if (_linkError != null) return Center(child: Text(_linkError!));
    final links = _links;
    if (links == null) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: FilledButton.icon(
              onPressed: () => _editLink(),
              icon: const Icon(Icons.add),
              label: const Text('Add Web App'),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: links.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final link = links[index];
              return ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(link.name),
                subtitle: Text('${link.tabName} · ${link.url}'),
                trailing: Wrap(
                  children: [
                    IconButton(onPressed: () => _editLink(link), icon: const Icon(Icons.edit_outlined)),
                    IconButton(onPressed: () => _deleteLink(link), icon: const Icon(Icons.delete_outline)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDevicesTab() {
    if (_deviceError != null) return Center(child: Text(_deviceError!));
    if (_loadingDevices) {
      return const Center(child: CircularProgressIndicator());
    }
    final devices = _devices;
    if (devices == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentSession = ref
        .watch(portalSessionControllerProvider)
        .valueOrNull;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        if (currentSession != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.accentLedger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.accentLedger.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_circle,
                  color: AppColors.accentLedger,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Active Session: ${currentSession.fullName} (@${currentSession.username})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Logged-in Email: ${currentSession.email}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkSecondary,
                        ),
                      ),
                      Text(
                        'Department: ${currentSession.department}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkSecondary,
                        ),
                      ),
                      Text(
                        'Branch: ${currentSession.branch}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        if (devices.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('No devices registered yet.'),
            ),
          )
        else
          ...devices.map((device) {
            final isActive = device.tokenStatus == 'active';
            final displayName = device.fullName.isNotEmpty
                ? device.fullName
                : (device.username.isNotEmpty
                      ? device.username
                      : 'User #${device.userId}');

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.lineHairline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.signalCredit.withValues(alpha: 0.12)
                            : AppColors.signalError.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.computer,
                        color: isActive
                            ? AppColors.signalCredit
                            : AppColors.signalError,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isActive
                                        ? Colors.green.shade200
                                        : Colors.red.shade200,
                                  ),
                                ),
                                child: Text(
                                  device.tokenStatus.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Token v${device.tokenVersion}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 16,
                            runSpacing: 4,
                            children: [
                              Text(
                                'Login User: ${device.username.isNotEmpty ? device.username : "admin"} (ID: #${device.userId})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.inkPrimary,
                                ),
                              ),
                              if (device.email.isNotEmpty)
                                Text(
                                  'Email: ${device.email}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.inkSecondary,
                                  ),
                                ),
                              Text(
                                'Machine: ${device.machineFingerprint.isNotEmpty ? device.machineFingerprint : "Windows PC"}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.inkSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Device ID: ${device.deviceId}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'IBM Plex Mono',
                              color: AppColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                device.isOtpExpired
                                    ? Icons.warning_amber_rounded
                                    : Icons.verified_user_outlined,
                                size: 14,
                                color: device.isOtpExpired
                                    ? AppColors.signalAmber
                                    : AppColors.signalCredit,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Monthly OTP: ${device.isOtpExpired ? "EXPIRED" : "Valid"} (Last: ${dateFormat.format(device.lastOtpVerifiedAt.toLocal())})',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: device.isOtpExpired
                                      ? AppColors.signalAmber
                                      : AppColors.inkSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Registered: ${dateFormat.format(device.createdAt.toLocal())}',
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
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.inkPrimary,
                        side: const BorderSide(color: AppColors.lineHairline),
                      ),
                      onPressed: () => _assignDeviceUser(device),
                      icon: const Icon(Icons.person_pin_outlined, size: 16),
                      label: const Text('Assign User'),
                    ),
                    const SizedBox(width: 8),
                    if (isActive)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.signalError,
                          side: const BorderSide(color: AppColors.signalError),
                        ),
                        onPressed: () => _revokeDevice(device),
                        icon: const Icon(Icons.block, size: 16),
                        label: const Text('Revoke'),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Revoked',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildRequestsTab() {
    if (_requestError != null) return Center(child: Text(_requestError!));
    if (_loadingRequests) {
      return const Center(child: CircularProgressIndicator());
    }
    final requests = _requests;
    if (requests == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (requests.isEmpty) {
      return const Center(child: Text('No activation requests found.'));
    }

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final req = requests[index];
        final isPending = req.status == 'pending';
        final isApproved = req.status == 'approved';

        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPending
                  ? Colors.amber.shade100
                  : (isApproved ? Colors.green.shade100 : Colors.red.shade100),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPending
                  ? Icons.pending_actions
                  : (isApproved ? Icons.check_circle : Icons.cancel),
              color: isPending
                  ? Colors.amber.shade900
                  : (isApproved ? Colors.green.shade800 : Colors.red.shade800),
              size: 22,
            ),
          ),
          title: Row(
            children: [
              Text(
                req.fullName.isNotEmpty ? req.fullName : req.username,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPending
                      ? Colors.amber.shade50
                      : (isApproved
                            ? Colors.green.shade50
                            : Colors.red.shade50),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  req.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPending
                        ? Colors.amber.shade800
                        : (isApproved
                              ? Colors.green.shade800
                              : Colors.red.shade800),
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  if (req.username.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: AppColors.inkSecondary,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Username: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        Text(
                          req.username,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkPrimary,
                          ),
                        ),
                      ],
                    ),
                  if (req.email.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: AppColors.accentLedger,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Email: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        SelectableText(
                          req.email,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentLedger,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Domain: ${req.domainRequested}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: AppColors.inkPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Device: ${req.deviceId} · Requested: ${dateFormat.format(req.requestedAt.toLocal())}',
                style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
              ),
              if (req.rejectionReason != null &&
                  req.rejectionReason!.isNotEmpty)
                   ...[
                const SizedBox(height: 2),
                Text(
                  'Reason: ${req.rejectionReason}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.signalError,
                  ),
                ),
              ],
            ],
          ),
          trailing: isPending
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.signalError,
                      ),
                      onPressed: () => _rejectRequest(req),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 8),
                    GradientFilledButton(
                      onPressed: () => _approveRequest(req),
                      child: const Text('Approve'),
                    ),
                  ],
                )
              : (isApproved
                    ? const Text(
                        'Approved',
                        style: TextStyle(
                          color: AppColors.signalCredit,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Text(
                        'Rejected',
                        style: TextStyle(color: AppColors.signalError),
                      )),
        );
      },
    );
  }

  Widget _buildAuditLogsTab() {
    if (_auditLogError != null) return Center(child: Text(_auditLogError!));
    if (_loadingAuditLogs) {
      return const Center(child: CircularProgressIndicator());
    }
    final logs = _auditLogs;
    if (logs == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (logs.isEmpty) {
      return const Center(child: Text('No audit log entries recorded yet.'));
    }

    final filteredLogs = _selectedAuditUserId == null
        ? logs
        : logs.where((l) => l.userId == _selectedAuditUserId).toList();

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: AppColors.surfacePanel,
          child: Row(
            children: [
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lineHairline),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: _selectedAuditUserId,
                    isDense: true,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: AppColors.inkSecondary,
                    ),
                    hint: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: AppColors.inkSecondary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'All Users',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.inkPrimary,
                          ),
                        ),
                      ],
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 16,
                              color: AppColors.inkSecondary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'All Users',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
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
                                const Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: AppColors.inkSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${u.fullName} (@${u.username})',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedAuditUserId = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${filteredLogs.length} of ${logs.length} entries',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.inkSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: 'Refresh logs',
                onPressed: () {
                  _loadAuditLogs();
                  if (_users == null) _loadUsers();
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: filteredLogs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No audit log entries found for this user.',
                        style: TextStyle(
                          color: AppColors.inkSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  itemCount: filteredLogs.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    final event = log.eventType.toLowerCase();
                    final isError =
                        event.contains('revoked') || event.contains('rejected');
                    final isSuccess =
                        event.contains('approved') ||
                        event.contains('issued') ||
                        event.contains('registered');
                    final isOtp = event.contains('otp');
                    final badgeBg = isError
                        ? Colors.red.shade50
                        : isSuccess
                        ? Colors.green.shade50
                        : isOtp
                        ? Colors.blue.shade50
                        : event.contains('requested')
                        ? Colors.amber.shade50
                        : Colors.grey.shade100;
                    final badgeColor = isError
                        ? Colors.red.shade800
                        : isSuccess
                        ? Colors.green.shade800
                        : isOtp
                        ? Colors.blue.shade800
                        : event.contains('requested')
                        ? Colors.amber.shade900
                        : Colors.grey.shade800;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: badgeBg,
                        child: Icon(
                          isError
                              ? Icons.block
                              : isSuccess
                              ? Icons.check_circle_outline
                              : isOtp
                              ? Icons.security
                              : Icons.info_outline,
                          color: badgeColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        '${log.eventType.toUpperCase().replaceAll('_', ' ')} • ${log.actor}',
                      ),
                      subtitle: Text(
                        [
                          if (log.userId != null) ...[
                            () {
                              final u = _users
                                  ?.cast<AdminPortalUser?>()
                                  .firstWhere(
                                    (u) => u?.id == log.userId,
                                    orElse: () => null,
                                  );
                              return u != null
                                  ? 'User: ${u.fullName} (@${u.username} · #${log.userId})'
                                  : 'User ID: #${log.userId}';
                            }(),
                          ],
                          if (log.deviceId?.isNotEmpty == true)
                            'Device: ${log.deviceId}',
                          if (log.metadata.isNotEmpty)
                            'Details: ${log.metadata}',
                          dateFormat.format(log.createdAt.toLocal()),
                        ].join('\n'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _GrantsDialog extends StatefulWidget {
  final AdminPortalUser user;
  const _GrantsDialog({required this.user});

  @override
  State<_GrantsDialog> createState() => _GrantsDialogState();
}

class _GrantsDialogState extends State<_GrantsDialog> {
  late final Set<String> _selected = widget.user.grantedLinkKeys.toSet();

  @override
  Widget build(BuildContext context) {
    final byTab = <String, List<PortalCatalogEntry>>{};
    for (final entry in kPortalLinkCatalog) {
      byTab.putIfAbsent(entry.tabName, () => []).add(entry);
    }

    return AlertDialog(
      title: Text('Grant Access — ${widget.user.fullName}'),
      content: SizedBox(
        width: 720,
        height: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final tab in byTab.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    tab.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    for (final entry in tab.value)
                      SizedBox(
                        width: 210,
                        child: CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            entry.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: _selected.contains(entry.key),
                          onChanged: (checked) => setState(() {
                            if (checked == true) {
                              _selected.add(entry.key);
                            } else {
                              _selected.remove(entry.key);
                            }
                          }),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        GradientFilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final AdminPortalUser user;
  const _ChangePasswordDialog({required this.user});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change Password — ${widget.user.fullName}'),
      content: SizedBox(
        width: 320,
        child: TextField(
          controller: _controller,
          obscureText: _obscure,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'New Password',
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        GradientFilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _InstallerPasswordDialog extends ConsumerStatefulWidget {
  const _InstallerPasswordDialog();

  @override
  ConsumerState<_InstallerPasswordDialog> createState() =>
      _InstallerPasswordDialogState();
}

class _InstallerPasswordDialogState
    extends ConsumerState<_InstallerPasswordDialog> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoadingCurrent = true;
  String? _currentPassword;
  String? _loadError;
  bool _revealCurrent = false;
  bool _revealNew = false;
  bool _isSaving = false;
  String? _saveError;
  Map<String, dynamic>? _activeOtp;
  bool _isLoadingOtp = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentPassword();
    _fetchActiveOtp();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentPassword() async {
    setState(() {
      _isLoadingCurrent = true;
      _loadError = null;
    });
    final res = await ref
        .read(portalAdminRepositoryProvider)
        .getInstallerPassword();
    if (!mounted) return;
    setState(() {
      _isLoadingCurrent = false;
      _currentPassword = res.valueOrNull;
      _loadError = res.errorOrNull?.message;
    });
  }

  Future<void> _fetchActiveOtp() async {
    setState(() => _isLoadingOtp = true);
    final res = await ref
        .read(portalAdminRepositoryProvider)
        .getActiveInstallerOtp();
    if (!mounted) return;
    setState(() {
      _isLoadingOtp = false;
      _activeOtp = res.valueOrNull;
    });
  }

  Future<void> _updatePassword() async {
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.isEmpty) {
      setState(() => _saveError = 'Please enter a new installer password.');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _saveError = 'Password must be at least 6 characters.');
      return;
    }
    if (newPass != confirmPass) {
      setState(
        () => _saveError = 'New password and confirmation do not match.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    final res = await ref
        .read(portalAdminRepositoryProvider)
        .setInstallerPassword(newPass);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res.isSuccess) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Installation password updated successfully.'),
          backgroundColor: AppColors.signalCredit,
        ),
      );
    } else {
      setState(() {
        _saveError =
            res.errorOrNull?.message ?? 'Failed to update installer password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.key_rounded, color: AppColors.accentLedger, size: 22),
          SizedBox(width: 10),
          Text('Windows Installer Password'),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.amber.shade900,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This password is required during Step 2 of the ARMSS Gateway setup wizard (ARMSS_Gateway_Setup.exe). Changing it takes effect immediately for all new installations.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_activeOtp != null &&
                  _activeOtp!['has_active_otp'] == true) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mark_email_read_outlined,
                        size: 28,
                        color: Colors.blue.shade800,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LIVE SETUP OTP (STEP 1)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _activeOtp!['otp_code'] as String? ?? '',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Mono',
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 4,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: 'Copy OTP',
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: _activeOtp!['otp_code'] as String? ?? '',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('OTP copied to clipboard!'),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: _isLoadingOtp
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh, size: 18),
                        tooltip: 'Refresh OTP',
                        onPressed: _fetchActiveOtp,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Current Installer Password:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lineHairline),
                ),
                child: Row(
                  children: [
                    if (_isLoadingCurrent)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (_loadError != null)
                      Expanded(
                        child: Text(
                          _loadError!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.signalError,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Text(
                          _revealCurrent
                              ? (_currentPassword ?? 'Not configured')
                              : '••••••••••••••••',
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Mono',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        _revealCurrent
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 18,
                        color: AppColors.inkSecondary,
                      ),
                      tooltip: _revealCurrent
                          ? 'Hide password'
                          : 'Show password',
                      onPressed: () =>
                          setState(() => _revealCurrent = !_revealCurrent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),
              const Text(
                'Set New Installer Password:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _newPasswordController,
                obscureText: !_revealNew,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _revealNew ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _revealNew = !_revealNew),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_revealNew,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              if (_saveError != null) ...[
                const SizedBox(height: 10),
                Text(
                  _saveError!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.signalError,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        GradientFilledButton(
          onPressed: _isSaving ? null : _updatePassword,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Update Password'),
        ),
      ],
    );
  }
}
