import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDarkModeKey = 'healup_dark_mode';

// ─── Notifier ─────────────────────────────────────────────────────────────────
class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_kDarkModeKey) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final current = state.value ?? ThemeMode.light;
    final next =
        current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkModeKey, next == ThemeMode.dark);
    state = AsyncData(next);
  }

  bool get isDark => state.value == ThemeMode.dark;
}

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

// ─── Theme data ───────────────────────────────────────────────────────────────
class AppTheme {
  // ── Brand colours ──────────────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF20A090);
  static const Color primaryLight = Color(0xFFE8F5F3);
  static const Color errorColor = Color(0xFFFF6B6B);

  // ── Light palette ──────────────────────────────────────────────────────────
  static const Color backgroundColor = Color(0xFFF7F9FA);
  static const Color textPrimary = Color(0xFF1B2021);
  static const Color textSecondary = Color(0xFF86928C);
  static const Color cardColor = Colors.white;

  // ── Dark palette ───────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121417);
  static const Color darkSurface = Color(0xFF1E2226);
  static const Color darkCard = Color(0xFF252B30);
  static const Color darkTextPrimary = Color(0xFFF0F4F5);
  static const Color darkTextSecondary = Color(0xFF8A9BA5);
  static const Color darkPrimaryLight = Color(0xFF163530);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF20A090), Color(0xFF007A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Light theme ────────────────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      surface: backgroundColor,
      error: errorColor,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      surface: darkSurface,
      error: errorColor,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: darkTextPrimary,
      displayColor: darkTextPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: darkTextPrimary),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );

  // ── Context-aware helpers ──────────────────────────────────────────────────
  /// Returns the correct surface/card color based on current brightness.
  static Color surface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkCard : cardColor;
  }

  static Color bg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkBackground : backgroundColor;
  }

  static Color text(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkTextPrimary : textPrimary;
  }

  static Color subtext(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkTextSecondary : textSecondary;
  }

  static Color primaryLightAdapted(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkPrimaryLight : primaryLight;
  }
}
