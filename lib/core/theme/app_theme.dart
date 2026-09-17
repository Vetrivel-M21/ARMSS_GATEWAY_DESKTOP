import 'package:flutter/material.dart';

/// Modern/vibrant design tokens. Field names are kept from the earlier
/// muted-ledger palette this replaced (`accentLedger`, `signalDebit`, etc.)
/// even though the values are no longer ledger-green — renaming would touch
/// every screen for no visual benefit, since only the hex values matter for
/// what actually renders. Light mode only; dark mode deferred.
class AppColors {
  AppColors._();

  static const surfaceCanvas = Color(0xFFF5F6FA);
  static const surfacePanel = Color(0xFFFFFFFF);
  static const surfaceSunken = Color(0xFFF1F3F9);
  static const inkPrimary = Color(0xFF111827);
  static const inkSecondary = Color(0xFF6B7280);
  static const inkMuted = Color(0xFF9CA3AF);
  static const lineHairline = Color(0xFFE5E7EB);

  /// Primary vibrant accent (indigo) — active nav, primary buttons, links.
  static const accentLedger = Color(0xFF4F46E5);
  static const accentLedgerTint = Color(0xFFEEF2FF);
  static const accentLedgerLight = Color(0xFF6D5EF0);

  static const signalDebit = Color(0xFFDC2626);
  static const signalCredit = Color(0xFF16A34A);
  static const signalError = Color(0xFFDC2626);
  static const signalAmber = Color(0xFFD97706);

  /// Dark navy for the nav rail — deliberately the one dark surface in an
  /// otherwise light app, for strong contrast against the white top bar and
  /// light content area (the "framed" admin-dashboard layout).
  static const navRailDark = Color(0xFF1E1B4B);
  static const navRailDarkText = Color(0xFFC7C5E8);

  /// The 4 fixed chart-of-accounts categories each get their own identity
  /// color, reused consistently between the Dashboard cards and Transaction
  /// Entry's category sections.
  static const categoryAssets = Color(0xFF6366F1);
  static const categoryLiability = Color(0xFF0EA5E9);
  static const categoryIncome = Color(0xFF16A34A);
  static const categoryExpense = Color(0xFFD97706);

  /// Soft shadow used on cards/panels/dialogs in place of a flat border.
  static List<BoxShadow> softShadow({double opacity = 0.06}) => [
        BoxShadow(color: Colors.black.withValues(alpha: opacity), blurRadius: 12, offset: const Offset(0, 3)),
      ];
}

/// Consistent spacing scale used across the app (padding, gaps).
class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// The one place amount/date/id text gets its monospace treatment — deliberate
/// and explicit per call site, not a blanket app-wide font, since body text
/// stays IBM Plex Sans.
class AppTextStyles {
  AppTextStyles._();

  static const mono = TextStyle(fontFamily: 'IBM Plex Mono', fontFeatures: [FontFeature.tabularFigures()]);

  static TextStyle monoWith({double? fontSize, FontWeight? fontWeight, Color? color}) {
    return mono.copyWith(fontSize: fontSize, fontWeight: fontWeight, color: color);
  }
}

class AppTheme {
  AppTheme._();

  static const _panelRadius = 10.0;
  static const _controlRadius = 8.0;

  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.accentLedger,
      onPrimary: Colors.white,
      secondary: AppColors.accentLedger,
      onSecondary: Colors.white,
      error: AppColors.signalError,
      onError: Colors.white,
      surface: AppColors.surfacePanel,
      onSurface: AppColors.inkPrimary,
    );

    final controlShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(_controlRadius));
    final panelShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(_panelRadius));

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surfaceCanvas,
      fontFamily: 'IBM Plex Sans',
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.inkPrimary),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.inkPrimary),
        bodyMedium: TextStyle(fontSize: 13, color: AppColors.inkPrimary),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: AppColors.inkSecondary),
      ),
      dividerColor: AppColors.lineHairline,
      dividerTheme: const DividerThemeData(color: AppColors.lineHairline, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: AppColors.surfacePanel,
        elevation: 0,
        shape: panelShape,
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfacePanel,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        shape: panelShape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentLedger,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: AppColors.accentLedger.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: controlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.inkPrimary,
          backgroundColor: AppColors.surfacePanel,
          side: const BorderSide(color: AppColors.lineHairline),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accentLedger, shape: controlShape),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSunken,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(_controlRadius), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_controlRadius), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_controlRadius), borderSide: const BorderSide(color: AppColors.accentLedger, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_controlRadius), borderSide: const BorderSide(color: AppColors.signalError)),
        errorStyle: const TextStyle(color: AppColors.signalError, fontSize: 12),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.inkSecondary,
          focusColor: AppColors.accentLedgerTint,
          side: BorderSide.none,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused) || states.contains(WidgetState.hovered)) {
              return AppColors.accentLedgerTint;
            }
            return null;
          }),
        ),
      ),
      focusColor: AppColors.accentLedgerTint,
    );
  }
}
