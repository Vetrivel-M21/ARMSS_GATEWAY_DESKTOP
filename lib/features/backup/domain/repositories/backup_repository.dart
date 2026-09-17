import '../../../../core/errors/result.dart';

abstract class BackupRepository {
  /// Writes a timestamped snapshot into [folderPath]. Returns the full path
  /// of the file that was written.
  Future<Result<String>> backupTo(String folderPath, {required int actorUserId});

  /// Replaces the live database with [filePath]'s contents. The caller must
  /// fully restart the app afterwards — the connection this repository was
  /// built on is closed as part of this call and cannot be reused.
  Future<Result<void>> restoreFrom(String filePath, {required int actorUserId, required String actorUsername});

  Future<DateTime?> lastBackupAt();
}
