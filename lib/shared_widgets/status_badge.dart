import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Fully-rounded pill: soft tinted background + colored dot/symbol + label.
/// Symbol and text always travel together so meaning never rests on color
/// alone.
class StatusBadge extends StatelessWidget {
  final String symbol;
  final String label;
  final Color color;
  final Color background;

  const StatusBadge({super.key, required this.symbol, required this.label, required this.color, required this.background});

  factory StatusBadge.open() =>
      StatusBadge(symbol: '●', label: 'OPEN', color: AppColors.signalCredit, background: AppColors.signalCredit.withValues(alpha: 0.12));

  factory StatusBadge.closed() =>
      const StatusBadge(symbol: '○', label: 'CLOSED', color: AppColors.inkSecondary, background: AppColors.surfaceSunken);

  factory StatusBadge.match() =>
      StatusBadge(symbol: '●', label: 'MATCH', color: AppColors.signalCredit, background: AppColors.signalCredit.withValues(alpha: 0.12));

  factory StatusBadge.mismatch() =>
      StatusBadge(symbol: '▲', label: 'MISMATCH', color: AppColors.signalAmber, background: AppColors.signalAmber.withValues(alpha: 0.12));

  factory StatusBadge.active() =>
      StatusBadge(symbol: '●', label: 'Active', color: AppColors.signalCredit, background: AppColors.signalCredit.withValues(alpha: 0.12));

  factory StatusBadge.inactive() =>
      const StatusBadge(symbol: '○', label: 'Inactive', color: AppColors.inkSecondary, background: AppColors.surfaceSunken);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        '$symbol $label',
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.1),
      ),
    );
  }
}
