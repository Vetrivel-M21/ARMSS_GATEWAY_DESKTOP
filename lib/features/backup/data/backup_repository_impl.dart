import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/result.dart';
import '../domain/repositories/backup_repository.dart';

const _lastBackupAtKey = 'last_backup_at';
const _pendingRestoreMarkerFileName = 'pending_restore_audit.json';

class BackupRepositoryImpl implements BackupRepository {
  final AppDatabase db;
  BackupRepositoryImpl(this.db);

  @override
  Future<Result<String>> backupTo(String folderPath, {required int actorUserId}) async {
    try {
      final timestamp = DateTime.now();
      final destinationPath = p.join(folderPath, 'mis_desktop_backup_${_fileTimestamp(timestamp)}.sqlite');
      await db.vacuumInto(destinationPath);
      await db.auditDao.log(userId: actorUserId, action: 'BACKUP', entityTable: 'database', newValue: destinationPath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastBackupAtKey, timestamp.toIso8601String());

      return Success(destinationPath);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<Result<void>> restoreFrom(String filePath, {required int actorUserId, required String actorUsername}) async {
    try {
      final sourceFile = File(filePath);
      final header = await _readHeader(sourceFile);
      if (header == null || !header.startsWith('SQLite format 3')) {
        return const Failure(ValidationException('That file is not a valid SQLite database.'));
      }

      final liveFile = await resolveDatabaseFile();
      final timestamp = DateTime.now();

      // The OS holds a lock on the live file while this connection is open —
      // it must be released before the file underneath it can be replaced.
      await db.close();

      if (await liveFile.exists()) {
        await liveFile.copy('${liveFile.path}.before_restore_${_fileTimestamp(timestamp)}.bak');
      }
      for (final suffix in ['-wal', '-shm', '-journal']) {
        final strayFile = File('${liveFile.path}$suffix');
        if (await strayFile.exists()) await strayFile.delete();
      }
      await sourceFile.copy(liveFile.path);

      final marker = await _pendingRestoreMarkerFile();
      await marker.writeAsString(jsonEncode({
        'restoredAt': timestamp.toIso8601String(),
        'sourceFile': filePath,
        'actorUserId': actorUserId,
        'actorUsername': actorUsername,
      }));

      return const Success(null);
    } catch (e) {
      return Failure(mapToAppException(e));
    }
  }

  @override
  Future<DateTime?> lastBackupAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastBackupAtKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<String?> _readHeader(File file) async {
    if (!await file.exists()) return null;
    final raf = await file.open();
    try {
      final bytes = await raf.read(16);
      return String.fromCharCodes(bytes);
    } finally {
      await raf.close();
    }
  }

  String _fileTimestamp(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}${two(dt.month)}${two(dt.day)}_${two(dt.hour)}${two(dt.minute)}${two(dt.second)}';
  }

  static Future<File> _pendingRestoreMarkerFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _pendingRestoreMarkerFileName));
  }
}

/// Checked once at startup (`app/di/providers.dart`): if a restore just
/// happened, the RESTORE audit entry is written here, into the *new*
/// database that now exists, rather than during the restore itself — an
/// entry written into the outgoing database would just be discarded along
/// with the rest of it the moment the file underneath is replaced.
Future<void> applyPendingRestoreAuditLogIfAny(AppDatabase db) async {
  final marker = await BackupRepositoryImpl._pendingRestoreMarkerFile();
  if (!await marker.exists()) return;

  final data = jsonDecode(await marker.readAsString()) as Map<String, dynamic>;
  await db.auditDao.log(
    userId: data['actorUserId'] as int,
    action: 'RESTORE',
    entityTable: 'database',
    newValue: 'Restored from ${data['sourceFile']} by ${data['actorUsername']} at ${data['restoredAt']}',
  );
  await marker.delete();
}
