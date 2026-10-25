import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from design/DESIGN.md (palette P16 lemon pop, Plus Jakarta Sans / Unbounded).
class AppColors {
  static const background = Color(0xFFFCFAF4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF6F2E4);
  static const lemon = Color(0xFFFFD60A);
  static const lemonPressed = Color(0xFFE6C000);
  static const lemonTint = Color(0xFFFFF6C7);
  static const accentFill = Color(0xFF826D05);
  static const sky = Color(0xFF7DB8FF);
  static const skyStrong = Color(0xFF4194FF);
  static const ink = Color(0xFF1F1C0C);
  static const ink2 = Color(0xFF2E2A14);
  static const textSecondary = Color(0xFF575238);
  static const textTertiary = Color(0xFF6B6650);
  static const hairline = Color(0xFFECE6D2);
  static const controlBorder = Color(0xFF9B9556);

  static const success = Color(0xFF0E7C3A);
  static const successTint = Color(0xFFE3F4E9);
  static const warning = Color(0xFFA75906);
  static const warningTint = Color(0xFFFAEFE1);
  static const danger = Color(0xFFCE2020);
  static const dangerTint = Color(0xFFFBE5E5);
  static const info = Color(0xFF1F4F8A);
  static const infoTint = Color(0xFFE3F0FF);
  static const scheduledText = Color(0xFF5E4F00);

  /// Ink hero card. White text sits on this, never on lemon.
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ink, ink2],
  );
}

class AppRadius {
  static const card = 20.0;
  static const control = 14.0;
  static const input = 12.0;
}

class AppShadows {
  static const card = [
    BoxShadow(color: Color(0x0A1F1C0C), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F1F1C0C), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

class AppText {
  static TextStyle display({double size = 32, Color color = AppColors.ink}) => GoogleFonts.unbounded(
      fontSize: size, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.02 * size, height: 1.15);
  static TextStyle headline({double size = 20, Color color = AppColors.ink}) =>
      GoogleFonts.unbounded(fontSize: size, fontWeight: FontWeight.w600, color: color, letterSpacing: -0.3, height: 1.2);
  static TextStyle title({Color color = AppColors.ink, double size = 16}) =>
      GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: FontWeight.w700, color: color, height: 1.3);
  static TextStyle body({Color color = AppColors.ink, double size = 15}) =>
      GoogleFonts.plusJakartaSans(fontSize: size, color: color, height: 1.45);
  static TextStyle label({Color color = AppColors.ink, FontWeight weight = FontWeight.w600, double size = 14}) =>
      GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: weight, color: color);
  static TextStyle caption({Color color = AppColors.textSecondary, FontWeight weight = FontWeight.w500}) =>
      GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: weight, color: color, height: 1.35);
  static TextStyle overline({Color color = AppColors.textSecondary}) => GoogleFonts.plusJakartaSans(
      fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 1.0);
  static TextStyle numerals({double size = 16, Color color = AppColors.ink, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.plusJakartaSans(
          fontSize: size, fontWeight: weight, color: color, fontFeatures: const [FontFeature.tabularFigures()]);
}

/// Fetches every weight up front so the first frame never renders with a fallback font.
/// Fonts ship in assets/google_fonts (static instances), so no network fetch is needed.
Future<void> preloadFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;
  return GoogleFonts.pendingFonts([
      GoogleFonts.unbounded(fontWeight: FontWeight.w600),
      GoogleFonts.unbounded(fontWeight: FontWeight.w700),
      for (final w in [FontWeight.w400, FontWeight.w500, FontWeight.w600, FontWeight.w700])
        GoogleFonts.plusJakartaSans(fontWeight: w),
    ]);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.lemon,
        primary: AppColors.ink,
        secondary: AppColors.lemon,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );
    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
          .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.ink : AppColors.surface),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.lemon : AppColors.hairline),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: AppColors.controlBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: AppColors.lemon, width: 2)),
      ),
    );
  }
}
