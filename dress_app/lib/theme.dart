import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors based on the UI
  static const Color primaryLime = Color(0xFFE8F87B);
  static const Color darkTeal = Color(0xFF0F1E29);
  static const Color backgroundLight = Color(0xFFF7F9FB); // Or a very light blue #EAF2F6 as seen in some backgrounds
  static const Color darkBackground = Color(0xFF1C222B);
  static const Color surfaceWhite = Colors.white;
  static const Color textDark = Color(0xFF1E2022);
  static const Color textLight = Color(0xFF8C959D);
  static const Color iconColorDark = Color(0xFF1E2022);
  
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryLime,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.light(
        primary: primaryLime,
        secondary: darkBackground,
        surface: surfaceWhite,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w800, color: textDark),
        displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w800, color: textDark),
        headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w800, color: textDark),
        headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, color: textDark),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: textDark),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, color: textDark),
        bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400, color: textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLime,
          foregroundColor: textDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}
