import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/currency_formatter.dart';

/// Renders a signed "closing"-style figure: monospace, right-aligned, a
/// leading +/- rather than color alone (color-blind-safe redundancy,
/// required by the design system). Positive = Dr, negative = Cr — the sign
/// convention both old-app screens agree on (they differ only in which
/// arithmetic gets them there: Transaction Entry uses Opening+Credit-Debit,
/// Report uses Opening+Debit-Credit — callers pass in the already-correctly-
/// signed value for their own screen). Dr gets `signalDebit` (brick red), Cr
/// gets `accentLedger` (green), per the design system's debit/credit color
/// mapping — this is about which label the figure carries, not which raw
/// formula produced it.
class AmountText extends StatelessWidget {
  final double amount;
  final double fontSize;
  final FontWeight fontWeight;
  final bool showDrCrSuffix;

  const AmountText(
    this.amount, {
    super.key,
    this.fontSize = 13,
    this.fontWeight = FontWeight.normal,
    this.showDrCrSuffix = false,
  });

  @override
  Widget build(BuildContext context) {
    if (amount == 0) {
      return Text(
        CurrencyFormatter.format(0),
        textAlign: TextAlign.right,
        style: AppTextStyles.monoWith(fontSize: fontSize, fontWeight: fontWeight, color: AppColors.inkMuted),
      );
    }

    final isDr = amount > 0;
    final sign = isDr ? '+' : '−';
    final color = isDr ? AppColors.signalDebit : AppColors.accentLedger;
    final suffix = showDrCrSuffix ? (isDr ? ' Dr' : ' Cr') : '';

    return Text(
      '$sign${CurrencyFormatter.format(amount)}$suffix',
      textAlign: TextAlign.right,
      style: AppTextStyles.monoWith(fontSize: fontSize, fontWeight: fontWeight, color: color),
    );
  }
}

/// A plain (always non-negative) amount rendered in a fixed debit or credit
/// column color — for raw debit_amount/credit_amount cells, where color is
/// tied to which column the figure is in, not to any sign (`AmountText` is
/// for signed closing-style totals instead).
class ColumnAmountText extends StatelessWidget {
  final double amount;
  final bool isDebitColumn;
  final double fontSize;

  const ColumnAmountText(this.amount, {super.key, required this.isDebitColumn, this.fontSize = 13});

  @override
  Widget build(BuildContext context) {
    if (amount == 0) {
      return Text('—', textAlign: TextAlign.right, style: AppTextStyles.monoWith(fontSize: fontSize, color: AppColors.inkMuted));
    }
    return Text(
      CurrencyFormatter.format(amount),
      textAlign: TextAlign.right,
      style: AppTextStyles.monoWith(
        fontSize: fontSize,
        color: isDebitColumn ? AppColors.signalDebit : AppColors.accentLedger,
      ),
    );
  }
}
