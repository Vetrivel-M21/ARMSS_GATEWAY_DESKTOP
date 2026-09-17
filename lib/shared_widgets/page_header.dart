import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// "Page title [Primary action]" row — every screen under the nav rail
/// starts with this instead of its own `AppBar`, since the persistent top
/// bar (`app_shell.dart`) now owns that role. Optionally shows a small
/// colored icon next to the title (matching that screen's nav-rail icon)
/// and a thin colored underline, tying the section's identity color through
/// from the nav rail into its own content.
class PageHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final IconData? icon;
  final Color? accentColor;

  const PageHeader({super.key, required this.title, this.actions = const [], this.icon, this.accentColor});

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.accentLedger;
    return Container(
      // The bottom margin (as opposed to more bottom padding) is what
      // actually separates the header from whatever a screen stacks next —
      // padding alone would just move the border line down with it, since
      // every screen puts its content directly after this widget in a
      // `Column` with no gap of its own.
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.25), width: 2))),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.inkPrimary)),
          const Spacer(),
          for (final action in actions) Padding(padding: const EdgeInsets.only(left: AppSpacing.sm), child: action),
        ],
      ),
    );
  }
}
