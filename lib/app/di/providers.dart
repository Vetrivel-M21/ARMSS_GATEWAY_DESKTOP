import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../features/backup/data/backup_repository_impl.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  // If the app just relaunched after a restore, the RESTORE audit entry
  // belongs in this (newly restored) database — see the comment on
  // `applyPendingRestoreAuditLogIfAny` for why it can't be written during
  // the restore itself.
  applyPendingRestoreAuditLogIfAny(db);
  return db;
});

/// A global signal bumped whenever an app-wide refresh is triggered.
/// Screens and widgets can listen to or watch this to reload live data.
final appRefreshSignalProvider = StateProvider<int>((ref) => 0);

