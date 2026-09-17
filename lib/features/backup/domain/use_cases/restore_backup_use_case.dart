import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/backup_repository.dart';

class RestoreBackupUseCase {
  final BackupRepository _repository;
  RestoreBackupUseCase(this._repository);

  Future<Result<void>> call({required AppUser actor, required String filePath}) async {
    if (!actor.isAdminOrSuper) {
      return const Failure(PermissionDeniedException('Only admins can restore backups.'));
    }
    return _repository.restoreFrom(filePath, actorUserId: actor.id, actorUsername: actor.username);
  }
}
