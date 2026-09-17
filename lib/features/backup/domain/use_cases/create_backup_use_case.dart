import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/backup_repository.dart';

class CreateBackupUseCase {
  final BackupRepository _repository;
  CreateBackupUseCase(this._repository);

  Future<Result<String>> call({required AppUser actor, required String folderPath}) async {
    if (!actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can create backups.'));
    }
    return _repository.backupTo(folderPath, actorUserId: actor.id);
  }
}
