import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Raises a screen's standalone filter/selector controls (a department or
/// user picker sitting alone above the main content) onto a white panel
/// with the same shadow treatment `LedgerTable` already gives its rows —
/// without this, those controls float directly on the canvas background,
/// which reads as flat and made the enclosed `LabeledDropdown` nearly
/// invisible (its own fill color is close to the canvas color).
class FilterBar extends StatelessWidget {
  final Widget child;
  const FilterBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppColors.softShadow(),
      ),
      child: child,
    );
  }
}
