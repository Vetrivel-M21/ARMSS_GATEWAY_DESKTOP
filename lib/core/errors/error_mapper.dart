import 'package:sqlite3/sqlite3.dart';

import 'app_exception.dart';

/// Translates raw DB/OS exceptions into an [AppException]. This is the only
/// place that should catch raw exceptions — everything above the DB adapter
/// boundary works with [Result] instead of try/catch.
AppException mapToAppException(Object error) {
  if (error is AppException) return error;

  // DAOs throw StateError for business-rule violations (e.g. "day already
  // closed", "cannot deactivate the last super_admin") rather than a custom
  // type, since they have no dependency on core/errors — translated here.
  if (error is StateError) {
    return BusinessRuleException(error.message);
  }

  if (error is SqliteException) {
    if (error.message.contains('UNIQUE constraint failed')) {
      return ValidationException('A record with this value already exists.');
    }
    if (error.message.contains('FOREIGN KEY constraint failed')) {
      return BusinessRuleException(
        'This action is blocked because other records depend on it.',
      );
    }
    return DatabaseException('Database error: ${error.message}');
  }

  return DatabaseException('Unexpected error: $error');
}
