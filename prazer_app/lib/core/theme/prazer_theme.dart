import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'prazer_colors.dart';

/// App theme system adhering strictly to prazer_design_prompt.md
class PrazerTheme {
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: PrazerColors.alabasterGrey,
      colorScheme: const ColorScheme.light(
        primary: PrazerColors.coolHorizon,
        secondary: PrazerColors.grapefruitPink,
        surface: PrazerColors.surfaceWhite,
        onSurface: PrazerColors.onyx,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      textTheme: TextTheme(
        // Display / score numbers: 800 (ExtraBold)
        displayLarge: GoogleFonts.montserrat(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: PrazerColors.onyx,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: PrazerColors.onyx,
        ),
        // Headings: 700 (Bold)
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: PrazerColors.onyx,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: PrazerColors.onyx,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: PrazerColors.onyx,
        ),
        // Subheadings / buttons: 600 (SemiBold)
        titleLarge: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: PrazerColors.onyx,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: PrazerColors.onyx,
        ),
        // Body emphasis: 500 (Medium)
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: PrazerColors.onyx,
        ),
        // Body / labels: 400 (Regular)
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: PrazerColors.blueSlate,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: PrazerColors.blueSlate,
        ),
        labelLarge: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PrazerColors.coolHorizon,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      cardTheme: CardThemeData(
        color: PrazerColors.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: PrazerColors.borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PrazerColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PrazerColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PrazerColors.coolHorizon, width: 1.5),
        ),
        hintStyle: GoogleFonts.montserrat(
          fontSize: 13,
          color: PrazerColors.blueSlate.withOpacity(0.7),
        ),
      ),
    );
  }

  /// Radial gradient hero background used ONLY on Splash and Login screens
  static const RadialGradient heroGradient = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.4,
    colors: [
      PrazerColors.onyx,
      PrazerColors.blueSlate,
      PrazerColors.alabasterGrey,
    ],
    stops: [0.0, 0.5, 1.0],
  );
}
