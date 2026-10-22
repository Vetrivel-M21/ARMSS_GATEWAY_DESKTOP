import 'package:flutter/material.dart';

/// Centralized design tokens for colors.
/// UI accent color is Indigo (#4F46E5).
/// Portal individual brand colors remain for portal card stripes.
class AppColors {
  AppColors._();

  // Light theme surfaces
  static const surfaceCanvas = Color(0xFFF5F6FA);
  static const surfacePanel = Color(0xFFFFFFFF);
  static const surfaceSunken = Color(0xFFF1F3F9);
  static const inkPrimary = Color(0xFF111827);
  static const inkSecondary = Color(0xFF6B7280);
  static const inkMuted = Color(0xFF9CA3AF);
  static const lineHairline = Color(0xFFE5E7EB);

  // Dark theme surfaces
  static const darkSurfaceCanvas = Color(0xFF0F172A); // slate-900
  static const darkSurfacePanel = Color(0xFF1E293B);  // slate-800
  static const darkSurfaceSunken = Color(0xFF0B1322); // deep slate
  static const darkInkPrimary = Color(0xFFF8FAFC);
  static const darkInkSecondary = Color(0xFF94A3B8);
  static const darkInkMuted = Color(0xFF64748B);
  static const darkLineHairline = Color(0xFF334155);
  static const darkNavRail = Color(0xFF0B1120);

  // Single UI accent color: Indigo (#4F46E5)
  static const accentIndigo = Color(0xFF4F46E5);
  static const accentIndigoHover = Color(0xFF4338CA);
  static const accentIndigoTint = Color(0xFFEEF2FF);
  static const accentIndigoDarkTint = Color(0xFF1E1B4B);

  // Backward compatibility aliases
  static const accentLedger = accentIndigo;
  static const accentLedgerTint = accentIndigoTint;
  static const accentLedgerLight = Color(0xFF6366F1);

  static const signalDebit = Color(0xFFDC2626);
  static const signalCredit = Color(0xFF16A34A);
  static const signalError = Color(0xFFDC2626);
  static const signalAmber = Color(0xFFD97706);

  // Nav rail dark navy
  static const navRailDark = Color(0xFF1E1B4B);
  static const navRailDarkText = Color(0xFFC7C5E8);

  // Fixed chart-of-accounts identity colors
  static const categoryAssets = Color(0xFF6366F1);
  static const categoryLiability = Color(0xFF0EA5E9);
  static const categoryIncome = Color(0xFF16A34A);
  static const categoryExpense = Color(0xFFD97706);

  /// Helper to dynamically resolve panel color based on context theme
  static Color panelOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurfacePanel
        : surfacePanel;
  }

  /// Helper to dynamically resolve canvas color based on context theme
  static Color canvasOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurfaceCanvas
        : surfaceCanvas;
  }

  /// Helper to dynamically resolve sunken surface color based on context theme
  static Color sunkenOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurfaceSunken
        : surfaceSunken;
  }

  /// Helper to dynamically resolve primary ink color based on context theme
  static Color inkPrimaryOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkInkPrimary
        : inkPrimary;
  }

  /// Helper to dynamically resolve secondary ink color based on context theme
  static Color inkSecondaryOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkInkSecondary
        : inkSecondary;
  }

  /// Helper to dynamically resolve hairline border color based on context theme
  static Color borderOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkLineHairline
        : lineHairline;
  }

  /// Soft shadow used on cards/panels/dialogs
  static List<BoxShadow> softShadow({double opacity = 0.06}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ];
}

/// Centralized corner radius tokens
class AppRadii {
  AppRadii._();

  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double pill = 999.0;

  static final roundedSm = BorderRadius.circular(sm);
  static final roundedMd = BorderRadius.circular(md);
  static final roundedLg = BorderRadius.circular(lg);
  static final roundedXl = BorderRadius.circular(xl);
  static final roundedPill = BorderRadius.circular(pill);
}

/// Centralized shadow tokens
class AppShadows {
  AppShadows._();

  static List<BoxShadow> soft({double opacity = 0.06}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ];

  static List<BoxShadow> hover({Color? tint, double opacity = 0.12}) => [
        BoxShadow(
          color: (tint ?? Colors.black).withValues(alpha: opacity),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

/// Festive Diwali design tokens for rich, ambient presentation on the user side.
class DiwaliColors {
  DiwaliColors._();

  static const goldPrimary = Color(0xFFF59E0B);
  static const goldAmber = Color(0xFFD97706);
  static const goldGlow = Color(0xFFFBBF24);
  static const flameWarm = Color(0xFFFDE68A);
  static const marigoldSaffron = Color(0xFFEA580C);
  static const festiveRuby = Color(0xFFE11D48);

  // Dark festive surfaces
  static const darkCanvas = Color(0xFF130B24);
  static const darkPanel = Color(0xFF1D1236);
  static const darkSunken = Color(0xFF0D0619);
  static const darkBorder = Color(0xFF38235C);

  // Light festive surfaces
  static const lightCanvas = Color(0xFFFFFDF8);
  static const lightPanel = Color(0xFFFFFFFF);
  static const lightSunken = Color(0xFFFFF9ED);
  static const lightBorder = Color(0xFFFDE68A);
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
  static const scrollBottomPad = 32.0; // Ensures last card row is fully visible and not hidden behind footer
}

/// Font family constants
class AppFonts {
  AppFonts._();
  static const sans = 'IBM Plex Sans';
  static const mono = 'IBM Plex Mono';
}

/// Monospace typography helpers
class AppTextStyles {
  AppTextStyles._();

  static const mono = TextStyle(
    fontFamily: AppFonts.mono,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static TextStyle monoWith({double? fontSize, FontWeight? fontWeight, Color? color}) {
    return mono.copyWith(fontSize: fontSize, fontWeight: fontWeight, color: color);
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.accentIndigo,
      onPrimary: Colors.white,
      secondary: AppColors.accentIndigo,
      onSecondary: Colors.white,
      error: AppColors.signalError,
      onError: Colors.white,
      surface: AppColors.surfacePanel,
      onSurface: AppColors.inkPrimary,
    );

    final controlShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md));
    final panelShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl));

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surfaceCanvas,
      fontFamily: AppFonts.sans,
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
          backgroundColor: AppColors.accentIndigo,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: AppColors.accentIndigo.withValues(alpha: 0.4),
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
        style: TextButton.styleFrom(foregroundColor: AppColors.accentIndigo, shape: controlShape),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSunken,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.accentIndigo, width: 2),
        ),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md), borderSide: const BorderSide(color: AppColors.signalError)),
        errorStyle: const TextStyle(color: AppColors.signalError, fontSize: 12),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.inkSecondary,
          focusColor: AppColors.accentIndigoTint,
          side: BorderSide.none,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused) || states.contains(WidgetState.hovered)) {
              return AppColors.accentIndigoTint;
            }
            return null;
          }),
        ),
      ),
      focusColor: AppColors.accentIndigoTint,
    );
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.accentIndigo,
      onPrimary: Colors.white,
      secondary: AppColors.accentIndigo,
      onSecondary: Colors.white,
      error: AppColors.signalError,
      onError: Colors.white,
      surface: AppColors.darkSurfacePanel,
      onSurface: AppColors.darkInkPrimary,
    );

    final controlShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md));
    final panelShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl));

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkSurfaceCanvas,
      fontFamily: AppFonts.sans,
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkInkPrimary),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.darkInkPrimary),
        bodyMedium: TextStyle(fontSize: 13, color: AppColors.darkInkPrimary),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.darkInkSecondary),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: AppColors.darkInkSecondary),
      ),
      dividerColor: AppColors.darkLineHairline,
      dividerTheme: const DividerThemeData(color: AppColors.darkLineHairline, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: AppColors.darkSurfacePanel,
        elevation: 0,
        shape: panelShape,
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurfacePanel,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: panelShape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentIndigo,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: AppColors.accentIndigo.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: controlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkInkPrimary,
          backgroundColor: AppColors.darkSurfacePanel,
          side: const BorderSide(color: AppColors.darkLineHairline),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accentIndigo, shape: controlShape),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceSunken,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.darkInkSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.darkLineHairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.accentIndigo, width: 2),
        ),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md), borderSide: const BorderSide(color: AppColors.signalError)),
        errorStyle: const TextStyle(color: AppColors.signalError, fontSize: 12),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.darkInkSecondary,
          focusColor: AppColors.accentIndigoDarkTint,
          side: BorderSide.none,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused) || states.contains(WidgetState.hovered)) {
              return AppColors.accentIndigoDarkTint;
            }
            return null;
          }),
        ),
      ),
      focusColor: AppColors.accentIndigoDarkTint,
    );
  }
}
