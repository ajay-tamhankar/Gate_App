import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Logistics Color Palette
  static const primaryBlue = Color(0xFF1E40AF);
  static const accentOrange = Color(0xFFF97316);
  static const successGreen = Color(0xFF16A34A);
  static const warningAmber = Color(0xFFF59E0B);
  static const dangerRed = Color(0xFFDC2626);

  static const desktopBg = Color(0xFFF3F4F6);
  static const cardWhite = Colors.white;

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      secondary: accentOrange,
      surface: cardWhite,
      error: dangerRed,
      // We map the desktop background to the scaffold
      surfaceContainerHighest: desktopBg,
    );

    return _buildTheme(base, colorScheme);
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: const Color(0xFF3B82F6), // slightly lighter blue for dark mode
      primary: const Color(0xFF3B82F6),
      secondary: accentOrange,
      surface: const Color(0xFF1F2937),
      error: const Color(0xFFF87171),
      surfaceContainerHighest: const Color(0xFF111827),
    );

    return _buildTheme(base, colorScheme);
  }

  static ThemeData _buildTheme(ThemeData base, ColorScheme colorScheme) {
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surfaceContainerHighest,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          textStyle: base.textTheme.displayLarge
              ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -1.0),
        ),
        displayMedium: GoogleFonts.outfit(
          textStyle: base.textTheme.displayMedium
              ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        headlineLarge: GoogleFonts.outfit(
          textStyle: base.textTheme.headlineLarge
              ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        headlineMedium: GoogleFonts.outfit(
          textStyle: base.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        titleLarge: GoogleFonts.outfit(
          textStyle: base.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.25),
        ),
        titleMedium: GoogleFonts.inter(
          textStyle:
              base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        centerTitle: false,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: GoogleFonts.outfit(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return null;
        }),
        headingTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
    );
  }
}
