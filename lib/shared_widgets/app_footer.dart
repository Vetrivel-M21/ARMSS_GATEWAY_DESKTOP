import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/updates/app_update_service.dart';

/// Standardized ARMSS INFO TECH footer shown at the bottom of every screen.
/// Displays application version and brand credits.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkLineHairline : AppColors.lineHairline,
            width: 1,
          ),
        ),
        color: isDark ? AppColors.darkSurfacePanel : const Color(0xFFFAFAFC),
      ),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? AppColors.darkInkMuted : const Color(0xFF6B7280),
          ),
          children: [
            TextSpan(
              text: 'ARMSS Gateway v$currentAppVersion  •  ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkInkSecondary : const Color(0xFF4B5563),
              ),
            ),
            const TextSpan(text: 'Software designed and developed by '),
            TextSpan(
              text: 'ARMSS INFO TECH',
              style: const TextStyle(
                color: Color(0xFF0284C7),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
