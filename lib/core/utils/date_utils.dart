import 'package:intl/intl.dart';

class AppDateUtils {
  static final _dateOnlyFormat = DateFormat('yyyy-MM-dd');

  /// Normalizes a DateTime to a date-only value (midnight, no time
  /// component) so it can be used as a stable key against `entryDate`/
  /// `businessDate`/`checkDate` columns.
  static DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  static String format(DateTime date) => _dateOnlyFormat.format(date);

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static String monthName(int month) => _monthNames[month - 1];

  /// Indian financial year convention (Apr 1 - Mar 31) used for report
  /// filter defaults — matches the old app.
  static ({DateTime start, DateTime end}) financialYearContaining(DateTime date) {
    final fyStartYear = date.month >= 4 ? date.year : date.year - 1;
    return (start: DateTime(fyStartYear, 4, 1), end: DateTime(fyStartYear + 1, 3, 31));
  }
}
