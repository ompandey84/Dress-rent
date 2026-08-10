import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized theme + design tokens for the Dress app.
///
/// All colors, text styles, and component themes live here so the rest of
/// the app doesn't have to hardcode values.
class AppTheme {
  // === Brand Colors ===
  static const Color primaryLime = Color(0xFFE8F87B);
  static const Color darkTeal = Color(0xFF0F1E29);
  static const Color backgroundLight = Color(0xFFF7F9FB);
  static const Color darkBackground = Color(0xFF1C222B);
  static const Color surfaceWhite = Colors.white;
  static const Color textDark = Color(0xFF1E2022);
  static const Color textLight = Color(0xFF8C959D);
  static const Color textMuted = Color(0xFFB6BCC2);
  static const Color border = Color(0xFFE5E7EA);
  static const Color surfaceMuted = Color(0xFFF1F4F6);
  static const Color iconColorDark = Color(0xFF1E2022);

  // === Status Colors ===
  static const Color success = Color(0xFF2E8A5F);
  static const Color warning = Color(0xFFE6A23C);
  static const Color danger = Color(0xFFD9534F);
  static const Color info = Color(0xFF2E8A99);

  // === Spacing scale (multiples of 4) ===
  static const double sp4 = 4;
  static const double sp8 = 8;
  static const double sp12 = 12;
  static const double sp16 = 16;
  static const double sp20 = 20;
  static const double sp24 = 24;
  static const double sp32 = 32;
  static const double sp40 = 40;

  // === Radii ===
  static const double r8 = 8;
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;
  static const double rPill = 100;

  /// Use this to build Inter text styles with a consistent scale.
  /// The default `textTheme` below is set to small (13/12/11) so screens that
  /// fall back to body* styles look tight; explicit `fontSize` calls still
  /// override.
  static TextStyle t({
    required double size,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color ?? textDark,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // === Convenience TextStyles (smaller than before) ===
  static TextStyle get h1 => t(size: 22, weight: FontWeight.w900, letterSpacing: -0.5);
  static TextStyle get h2 => t(size: 18, weight: FontWeight.w800, letterSpacing: -0.3);
  static TextStyle get h3 => t(size: 15, weight: FontWeight.w800);
  static TextStyle get h4 => t(size: 14, weight: FontWeight.w800);
  static TextStyle get title => t(size: 13, weight: FontWeight.w700);
  static TextStyle get body => t(size: 13);
  static TextStyle get bodyMuted => t(size: 13, color: textLight, weight: FontWeight.w500);
  static TextStyle get small => t(size: 11, color: textLight, weight: FontWeight.w600);
  static TextStyle get micro => t(size: 10, color: textLight, weight: FontWeight.w600, letterSpacing: 0.5);
  static TextStyle get button => t(size: 14, weight: FontWeight.w800, letterSpacing: 0.3);
  static TextStyle get label => t(size: 11, weight: FontWeight.w800, letterSpacing: 0.6, color: textLight);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryLime,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.light(
        primary: primaryLime,
        secondary: darkBackground,
        surface: surfaceWhite,
        onPrimary: textDark,
        onSecondary: Colors.white,
        onSurface: textDark,
        error: danger,
      ),
      dividerColor: border,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        // Override defaults to keep the app tight.
        displayLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.5),
        displayMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.4),
        displaySmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: textDark),
        headlineLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: textDark),
        headlineMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: textDark),
        headlineSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textDark),
        titleLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: textDark),
        titleMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: textDark),
        titleSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: textDark),
        bodyLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textDark, height: 1.4),
        bodyMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textDark, height: 1.4),
        bodySmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textLight, height: 1.3),
        labelLarge: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: textDark, letterSpacing: 0.4),
        labelMedium: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: textLight, letterSpacing: 0.5),
        labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: textLight, letterSpacing: 0.6),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: t(size: 13, weight: FontWeight.w800, letterSpacing: 0.8, color: textDark),
        iconTheme: const IconThemeData(color: textDark, size: 22),
      ),
      iconTheme: const IconThemeData(color: textDark, size: 22),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLime,
          foregroundColor: textDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rPill)),
          textStyle: t(size: 13, weight: FontWeight.w800, letterSpacing: 0.4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textDark,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rPill)),
          textStyle: t(size: 13, weight: FontWeight.w800, letterSpacing: 0.4),
          side: const BorderSide(color: border),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textDark,
          textStyle: t(size: 12, weight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        hintStyle: t(size: 13, color: textLight),
        labelStyle: t(size: 11, weight: FontWeight.w800, color: textLight, letterSpacing: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r12),
          borderSide: const BorderSide(color: textDark, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r16)),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: textLight),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        selectedColor: textDark,
        labelStyle: t(size: 12, weight: FontWeight.w700),
        secondaryLabelStyle: t(size: 12, weight: FontWeight.w700, color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rPill)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textDark,
        contentTextStyle: t(size: 13, color: Colors.white, weight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r12)),
      ),
    );
  }
}
