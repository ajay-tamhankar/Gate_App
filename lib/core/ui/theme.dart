import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vistar Premium design tokens — exact color values from the brand spec.
class VistarTokens {
  // Brand ribbon stops
  static const purple = Color(0xFF7A1FB0);
  static const violet = Color(0xFF9B30C9);
  static const magenta = Color(0xFFC018C0);
  static const pink = Color(0xFFE0218A);
  static const red = Color(0xFFC8102E);
  static const orangeRed = Color(0xFFF0480C);
  static const orange = Color(0xFFF06000);
  static const amber = Color(0xFFF0C000);
  static const yellow = Color(0xFFF0E060);
  static const cream = Color(0xFFFFF6CC);

  // Status semantics
  static const ok = Color(0xFF34D399);
  static const warn = Color(0xFFFBBF24);
  static const bad = Color(0xFFFB6F84);
  static const info = Color(0xFF5BA8FF);

  // Dark surface scale
  static const darkBg = Color(0xFF070611);
  static const darkBg2 = Color(0xFF0B0A18);
  static const darkSurface = Color(0xFF110F1E);
  static const darkSurface2 = Color(0xFF16142A);
  static const darkSurface3 = Color(0xFF1D1A33);
  static const darkLine = Color(0x14FFFFFF); // rgba(255,255,255,.08)
  static const darkLine2 = Color(0x21FFFFFF); // rgba(255,255,255,.13)
  static const darkTxt = Color(0xFFF2EEFB);
  static const darkTxt2 = Color(0xFFB9B2D6);
  static const darkTxt3 = Color(0xFF7E769B);

  // Light surface scale (premium near-white, ribbon-friendly)
  static const lightBg = Color(0xFFF6F4FB);
  static const lightBg2 = Color(0xFFFAF8FE);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurface2 = Color(0xFFF1EEF8);
  static const lightSurface3 = Color(0xFFE9E4F3);
  static const lightLine = Color(0x14000000);
  static const lightLine2 = Color(0x21000000);
  static const lightTxt = Color(0xFF15121F);
  static const lightTxt2 = Color(0xFF4A4561);
  static const lightTxt3 = Color(0xFF8A839E);

  static const radius = 16.0;
  static const radiusSm = 11.0;
  static const radiusLg = 22.0;

  /// The signature 115deg rainbow ribbon. Use sparingly.
  static const ribbon = LinearGradient(
    begin: Alignment(-0.85, -0.35),
    end: Alignment(0.85, 0.35),
    stops: [0.0, 0.22, 0.40, 0.56, 0.70, 0.80, 0.92, 1.0],
    colors: [
      Color(0xFF7A1FB0),
      Color(0xFFB81FB8),
      Color(0xFFE0218A),
      Color(0xFFD11630),
      Color(0xFFF0480C),
      Color(0xFFF06000),
      Color(0xFFF0C000),
      Color(0xFFF7EE9A),
    ],
  );

  /// Softer ribbon for subtle accents.
  static const ribbonSoft = LinearGradient(
    begin: Alignment(-0.85, -0.35),
    end: Alignment(0.85, 0.35),
    colors: [
      Color(0xE69B30C9),
      Color(0xE6E0218A),
      Color(0xE6F0480C),
      Color(0xE6F0C000),
    ],
  );

  // Shadows / glows
  static List<BoxShadow> elevatedShadow(bool isDark) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.55)
              : Colors.black.withValues(alpha: 0.10),
          blurRadius: 60,
          spreadRadius: -28,
          offset: const Offset(0, 24),
        ),
      ];

  static List<BoxShadow> glow(bool isDark) => [
        BoxShadow(
          color: Colors.white
              .withValues(alpha: isDark ? 0.05 : 0.04),
          spreadRadius: 1,
        ),
        BoxShadow(
          color: const Color(0xFFC018C0).withValues(alpha: isDark ? 0.40 : 0.20),
          blurRadius: 50,
          spreadRadius: -22,
          offset: const Offset(0, 18),
        ),
      ];
}

class AppTheme {
  // ─── Brand alias kept for any legacy reference ─────────────────────
  static const primaryBlue = VistarTokens.pink;
  static const accentOrange = VistarTokens.orange;
  static const successGreen = VistarTokens.ok;
  static const warningAmber = VistarTokens.warn;
  static const dangerRed = VistarTokens.bad;

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: VistarTokens.pink,
      onPrimary: Colors.white,
      primaryContainer: VistarTokens.pink.withValues(alpha: 0.10),
      onPrimaryContainer: VistarTokens.purple,
      secondary: VistarTokens.violet,
      onSecondary: Colors.white,
      secondaryContainer: VistarTokens.violet.withValues(alpha: 0.10),
      onSecondaryContainer: VistarTokens.purple,
      tertiary: VistarTokens.orange,
      onTertiary: Colors.white,
      tertiaryContainer: VistarTokens.orange.withValues(alpha: 0.10),
      onTertiaryContainer: VistarTokens.orangeRed,
      error: VistarTokens.bad,
      onError: Colors.white,
      errorContainer: VistarTokens.bad.withValues(alpha: 0.12),
      onErrorContainer: VistarTokens.red,
      surface: VistarTokens.lightSurface,
      onSurface: VistarTokens.lightTxt,
      surfaceContainerHighest: VistarTokens.lightBg,
      onSurfaceVariant: VistarTokens.lightTxt2,
      outline: VistarTokens.lightLine2,
      outlineVariant: VistarTokens.lightLine,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: VistarTokens.darkSurface,
      onInverseSurface: VistarTokens.darkTxt,
      inversePrimary: VistarTokens.violet,
    );
    return _buildTheme(base, colorScheme, isDark: false);
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: VistarTokens.pink,
      onPrimary: Colors.white,
      primaryContainer: VistarTokens.pink.withValues(alpha: 0.16),
      onPrimaryContainer: VistarTokens.cream,
      secondary: VistarTokens.violet,
      onSecondary: Colors.white,
      secondaryContainer: VistarTokens.violet.withValues(alpha: 0.18),
      onSecondaryContainer: VistarTokens.darkTxt,
      tertiary: VistarTokens.orange,
      onTertiary: Colors.white,
      tertiaryContainer: VistarTokens.orange.withValues(alpha: 0.16),
      onTertiaryContainer: VistarTokens.cream,
      error: VistarTokens.bad,
      onError: Colors.white,
      errorContainer: VistarTokens.bad.withValues(alpha: 0.14),
      onErrorContainer: VistarTokens.bad,
      surface: VistarTokens.darkSurface,
      onSurface: VistarTokens.darkTxt,
      surfaceContainerHighest: VistarTokens.darkBg,
      onSurfaceVariant: VistarTokens.darkTxt2,
      outline: VistarTokens.darkLine2,
      outlineVariant: VistarTokens.darkLine,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: VistarTokens.lightSurface,
      onInverseSurface: VistarTokens.lightTxt,
      inversePrimary: VistarTokens.pink,
    );
    return _buildTheme(base, colorScheme, isDark: true);
  }

  static ThemeData _buildTheme(
    ThemeData base,
    ColorScheme colorScheme, {
    required bool isDark,
  }) {
    final baseTextTheme = isDark
        ? GoogleFonts.manropeTextTheme(base.textTheme).apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          )
        : GoogleFonts.manropeTextTheme(base.textTheme).apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          );

    final display = GoogleFonts.bricolageGrotesqueTextTheme(base.textTheme).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    final textTheme = baseTextTheme.copyWith(
      displayLarge: display.displayLarge
          ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6),
      displayMedium: display.displayMedium
          ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6),
      displaySmall: display.displaySmall
          ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
      headlineLarge: display.headlineLarge
          ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
      headlineMedium: display.headlineMedium
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.4),
      headlineSmall: display.headlineSmall
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleLarge: display.titleLarge
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleMedium: baseTextTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.1),
      titleSmall: baseTextTheme.titleSmall
          ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.1),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(letterSpacing: 0.1),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(letterSpacing: 0.1),
      bodySmall: baseTextTheme.bodySmall?.copyWith(letterSpacing: 0.1),
      labelLarge: baseTextTheme.labelLarge
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.2),
      labelMedium: baseTextTheme.labelMedium
          ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.3),
      labelSmall: baseTextTheme.labelSmall
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.6),
    );

    final scaffoldBg = isDark ? VistarTokens.darkBg : VistarTokens.lightBg;
    final surface = colorScheme.surface;

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      canvasColor: surface,
      dividerColor: colorScheme.outlineVariant,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: false,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: GoogleFonts.bricolageGrotesque(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        shape: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VistarTokens.radius),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VistarTokens.radius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(VistarTokens.radiusLg),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: VistarTokens.pink.withValues(alpha: 0.16),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? VistarTokens.pink : colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? VistarTokens.pink : colorScheme.onSurfaceVariant,
            size: 24,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? VistarTokens.darkSurface
            : VistarTokens.lightSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        hintStyle: GoogleFonts.manrope(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.manrope(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        floatingLabelStyle: GoogleFonts.manrope(
          color: VistarTokens.pink,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VistarTokens.radiusSm),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VistarTokens.radiusSm),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VistarTokens.radiusSm),
          borderSide: BorderSide(
            color: VistarTokens.pink.withValues(alpha: 0.6),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VistarTokens.radiusSm),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VistarTokens.radiusSm),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: VistarTokens.pink,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              colorScheme.onSurface.withValues(alpha: 0.08),
          disabledForegroundColor:
              colorScheme.onSurface.withValues(alpha: 0.38),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VistarTokens.radiusSm),
          ),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: VistarTokens.pink,
          foregroundColor: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VistarTokens.radiusSm),
          ),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VistarTokens.radiusSm),
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: VistarTokens.pink,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: VistarTokens.pink,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VistarTokens.radius),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: colorScheme.outline, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return VistarTokens.pink;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return VistarTokens.pink;
          return colorScheme.outline;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return VistarTokens.pink;
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return VistarTokens.pink.withValues(alpha: 0.35);
          }
          return colorScheme.outlineVariant;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: VistarTokens.pink,
        linearTrackColor: Color(0x1AE0218A),
        circularTrackColor: Color(0x1AE0218A),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: VistarTokens.pink,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: VistarTokens.pink, width: 2.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor:
            colorScheme.onSurface.withValues(alpha: isDark ? 0.06 : 0.04),
        selectedColor: VistarTokens.pink.withValues(alpha: 0.16),
        labelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
          color: colorScheme.onSurface,
        ),
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? VistarTokens.darkSurface2
            : VistarTokens.lightTxt,
        contentTextStyle: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VistarTokens.radiusSm),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(
          isDark ? VistarTokens.darkSurface2 : VistarTokens.lightSurface2,
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return VistarTokens.pink.withValues(alpha: 0.10);
          }
          if (states.contains(WidgetState.hovered)) {
            return colorScheme.onSurface.withValues(alpha: 0.03);
          }
          return null;
        }),
        headingTextStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
          fontSize: 11,
          letterSpacing: 0.6,
        ),
        dataTextStyle: GoogleFonts.manrope(
          color: colorScheme.onSurface,
          fontSize: 13,
        ),
        dividerThickness: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? VistarTokens.darkSurface3 : VistarTokens.lightTxt,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return VistarTokens.pink.withValues(alpha: 0.55);
          }
          return VistarTokens.violet.withValues(alpha: 0.30);
        }),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),
    );
  }
}
