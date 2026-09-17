import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared_widgets/confirm_dialog.dart';
import '../../../../shared_widgets/filter_bar.dart';
import '../../../../shared_widgets/gradient_filled_button.dart';
import '../../../../shared_widgets/page_header.dart';
import '../controllers/backup_controllers.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  Future<void> _backupNow(BuildContext context, WidgetRef ref) async {
    final folderPath = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Choose a backup destination folder');
    if (folderPath == null) return;
    final savedPath = await ref.read(backupActionsControllerProvider.notifier).backupNow(folderPath);
    if (!context.mounted) return;
    if (savedPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup saved to $savedPath')));
    } else {
      _showError(context, ref);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['sqlite'],
      dialogTitle: 'Choose a backup file to restore',
    );
    final filePath = picked?.files.single.path;
    if (filePath == null) return;
    if (!context.mounted) return;

    final fileName = filePath.split(RegExp(r'[\\/]')).last;
    final confirmed = await showConfirmDialog(
      context,
      title: 'Restore from Backup',
      message: 'This replaces all current data with the contents of "$fileName". '
          'The application will restart automatically afterwards. This cannot be undone.',
      confirmLabel: 'Restore & Restart App',
      destructive: true,
    );
    if (!confirmed) return;

    final ok = await ref.read(backupActionsControllerProvider.notifier).restore(filePath);
    if (!context.mounted) return;
    if (!ok) {
      _showError(context, ref);
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Restore Complete'),
        content: const Text('Data has been restored. The application will now restart.'),
        actions: [
          FilledButton(
            onPressed: () async {
              await Process.start(Platform.resolvedExecutable, [], mode: ProcessStartMode.detached);
              exit(0);
            },
            child: const Text('Restart Now'),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, WidgetRef ref) {
    final error = ref.read(backupActionsControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error?.message ?? 'Something went wrong.')));
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastBackupAsync = ref.watch(lastBackupAtProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(title: 'Backup & Restore', icon: Icons.backup_outlined, accentColor: Color(0xFF0D9488)),
        FilterBar(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Save a full copy of the database', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    lastBackupAsync.when(
                      loading: () => const Text('Last backup: …', style: TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
                      error: (e, _) => const Text('Last backup: unknown', style: TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
                      data: (lastAt) => Text(
                        lastAt == null ? 'Last backup: never' : 'Last backup: ${_relativeTime(lastAt)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              GradientFilledButton(
                onPressed: () => _backupNow(context, ref),
                icon: Icons.backup_outlined,
                child: const Text('Backup Now'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfacePanel,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.signalError.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Restore from a backup file', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.inkPrimary)),
                      SizedBox(height: 4),
                      Text('Overwrites all current data. The app restarts afterwards.', style: TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _restore(context, ref),
                  icon: const Icon(Icons.restore, color: AppColors.signalError),
                  label: const Text('Restore…'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.signalError,
                    side: const BorderSide(color: AppColors.signalError),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
