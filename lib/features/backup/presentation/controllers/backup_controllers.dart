import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/rbac/current_user_provider.dart';
import '../../data/backup_repository_impl.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/use_cases/create_backup_use_case.dart';
import '../../domain/use_cases/restore_backup_use_case.dart';

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepositoryImpl(ref.watch(appDatabaseProvider));
});

final createBackupUseCaseProvider = Provider((ref) => CreateBackupUseCase(ref.watch(backupRepositoryProvider)));
final restoreBackupUseCaseProvider = Provider((ref) => RestoreBackupUseCase(ref.watch(backupRepositoryProvider)));

/// Shared by the Backup screen and the Dashboard's staleness reminder, so a
/// successful backup refreshes both at once via `ref.invalidate`.
final lastBackupAtProvider = FutureProvider<DateTime?>((ref) {
  return ref.watch(backupRepositoryProvider).lastBackupAt();
});

class BackupActionsController extends Notifier<AppException?> {
  @override
  AppException? build() => null;

  Future<String?> backupNow(String folderPath) async {
    final actor = ref.read(currentUserProvider)!;
    final result = await ref.read(createBackupUseCaseProvider).call(actor: actor, folderPath: folderPath);
    state = result.errorOrNull;
    if (result.isSuccess) ref.invalidate(lastBackupAtProvider);
    return result.valueOrNull;
  }

  Future<bool> restore(String filePath) async {
    final actor = ref.read(currentUserProvider)!;
    final result = await ref.read(restoreBackupUseCaseProvider).call(actor: actor, filePath: filePath);
    state = result.errorOrNull;
    return result.isSuccess;
  }
}

final backupActionsControllerProvider =
    NotifierProvider<BackupActionsController, AppException?>(BackupActionsController.new);
