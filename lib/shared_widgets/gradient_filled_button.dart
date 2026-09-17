import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// A primary CTA with a subtle two-stop indigo gradient instead of a flat
/// fill — used only for the handful of highest-stakes primary actions (Save
/// & Close, Add Department/User/Title, Export), not a global button-theme
/// override, since forcing every small dialog "Save" button through a
/// gradient is more visual noise than benefit. Flutter's `FilledButton`
/// doesn't support gradients natively, so this wraps one in a
/// gradient-painted container and lets the button itself stay transparent.
class GradientFilledButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;

  const GradientFilledButton({super.key, required this.onPressed, required this.child, this.icon});

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: disabled
            ? null
            : const LinearGradient(
                colors: [AppColors.accentLedger, AppColors.accentLedgerLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: disabled ? AppColors.lineHairline : null,
        boxShadow: disabled ? null : AppColors.softShadow(opacity: 0.25),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: disabled ? AppColors.inkMuted : Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                ],
                DefaultTextStyle.merge(
                  style: TextStyle(color: disabled ? AppColors.inkMuted : Colors.white, fontWeight: FontWeight.w600),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
