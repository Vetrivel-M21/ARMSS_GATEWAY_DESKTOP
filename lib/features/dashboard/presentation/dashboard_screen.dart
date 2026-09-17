import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/permission_keys.dart';
import '../../../core/rbac/current_user_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared_widgets/page_header.dart';
import '../../backup/presentation/controllers/backup_controllers.dart';

class DashboardCard {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const DashboardCard({required this.key, required this.label, required this.icon, required this.color});
}

/// Permission-gated card grid — the equivalent of the old app's welcome.php,
/// including its "contact administrator" empty state when a user has zero
/// accessible features. Rounded, softly-shadowed cards with a colored icon
/// badge each — the one screen in the app that's deliberately more visually
/// rich, since it's a launcher rather than a data table.
class DashboardScreen extends ConsumerWidget {
  final void Function(String key)? onSelectCard;

  const DashboardScreen({super.key, this.onSelectCard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider)!;

    final cards = <DashboardCard>[
      if (user.has(PermissionCode.titlesView))
        const DashboardCard(key: 'titles', label: 'Titles & Sub-Titles', icon: Icons.account_tree_outlined, color: Color(0xFF6366F1)),
      if (user.has(PermissionCode.balanceEntryView))
        const DashboardCard(key: 'balance_entry', label: 'Transaction Entry', icon: Icons.edit_note_outlined, color: Color(0xFF0EA5E9)),
      if (user.has(PermissionCode.balanceReportView))
        const DashboardCard(key: 'balance_report', label: 'Balance Report', icon: Icons.summarize_outlined, color: Color(0xFF16A34A)),
      if (user.isAdminOrSuper) ...[
        const DashboardCard(key: 'departments', label: 'Departments', icon: Icons.apartment_outlined, color: Color(0xFFD97706)),
        const DashboardCard(key: 'users', label: 'Users', icon: Icons.people_outline, color: Color(0xFFEC4899)),
        const DashboardCard(key: 'permissions', label: 'Permissions', icon: Icons.lock_outline, color: Color(0xFF8B5CF6)),
        const DashboardCard(key: 'audit', label: 'Audit Log', icon: Icons.history, color: Color(0xFF64748B)),
        const DashboardCard(key: 'backup', label: 'Backup & Restore', icon: Icons.backup_outlined, color: Color(0xFF0D9488)),
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Welcome, ${user.fullName}'),
        if (user.isAdminOrSuper) _BackupReminderBanner(onSelectCard: onSelectCard),
        Expanded(
          child: cards.isEmpty
              ? const Center(child: Text('You do not have access to any features. Please contact an administrator.'))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: AppSpacing.lg,
                    crossAxisSpacing: AppSpacing.lg,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return _DashboardCardTile(card: card, onTap: onSelectCard == null ? null : () => onSelectCard!(card.key));
                  },
                ),
        ),
      ],
    );
  }
}

/// Nudges an admin toward the Backup screen once it's been a while — shown
/// only to admins since only they can act on it, and only when a backup is
/// actually overdue or has never happened.
class _BackupReminderBanner extends ConsumerWidget {
  final void Function(String key)? onSelectCard;
  const _BackupReminderBanner({required this.onSelectCard});

  static const _staleAfter = Duration(days: 14);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastBackupAsync = ref.watch(lastBackupAtProvider);
    final lastBackupAt = lastBackupAsync.valueOrNull;
    final isStale = lastBackupAsync.hasValue && (lastBackupAt == null || DateTime.now().difference(lastBackupAt) > _staleAfter);
    if (!isStale) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(10),
        border: const Border(top: BorderSide(color: AppColors.signalAmber, width: 2)),
        boxShadow: AppColors.softShadow(),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.signalAmber, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              lastBackupAt == null
                  ? 'No backup has been made yet. Back up your data in case this machine is lost or reset.'
                  : 'Your last backup was over ${_staleAfter.inDays} days ago.',
              style: const TextStyle(fontSize: 13, color: AppColors.inkPrimary),
            ),
          ),
          TextButton(
            onPressed: onSelectCard == null ? null : () => onSelectCard!('backup'),
            child: const Text('Back up now'),
          ),
        ],
      ),
    );
  }
}

class _DashboardCardTile extends StatelessWidget {
  final DashboardCard card;
  final VoidCallback? onTap;
  const _DashboardCardTile({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfacePanel,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: card.color.withValues(alpha: 0.06),
        child: Container(
          decoration: BoxDecoration(boxShadow: AppColors.softShadow()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 4, color: card.color),
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
                        decoration: BoxDecoration(color: card.color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(12)),
                        child: Icon(card.icon, color: card.color, size: 22),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(card.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.inkPrimary)),
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
