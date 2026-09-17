import 'package:intl/intl.dart';

/// Positive = "Dr", negative = "Cr" — matches the old app's sign convention
/// for the Closing = Opening + Credit - Debit rule. Whole numbers, no
/// decimals — matches the old app's `number_format(x, 0)` exactly.
class CurrencyFormatter {
  static final _format = NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0);

  static String format(double amount) => _format.format(amount.abs());

  static String formatWithDrCr(double amount) {
    final formatted = _format.format(amount.abs());
    if (amount == 0) return formatted;
    return amount > 0 ? '$formatted Dr' : '$formatted Cr';
  }
}
