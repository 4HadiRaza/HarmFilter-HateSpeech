import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HFTheme {
  static const Color bg = Color(0xFF090909);
  static const Color surface = Color(0xFF111111);
  static const Color elevated = Color(0xFF1C1C1C);
  static const Color border = Color(0xFF2A2A2A);
  static Color _accent = const Color(0xFFE8001D);
  static Color get accent => _accent;
  static void setAccent(Color value) => _accent = value;
  static const Color text = Color(0xFFF5F5F5);
  static const Color muted = Color(0xFF8A8A8A);

  static TextStyle syneTitle(BuildContext context, {double size = 24}) {
    return GoogleFonts.inter(
      textStyle: Theme.of(context).textTheme.titleLarge,
      fontWeight: FontWeight.w800,
      fontSize: size,
      color: Theme.of(context).textTheme.titleLarge?.color,
      letterSpacing: -0.4,
    );
  }

  static TextStyle monoLabel(BuildContext context, {double size = 11}) {
    return GoogleFonts.inter(
      textStyle: Theme.of(context).textTheme.labelSmall,
      fontWeight: FontWeight.w400,
      fontSize: size,
      color: Theme.of(context).brightness == Brightness.dark
          ? muted
          : const Color(0xFF6B7280),
      letterSpacing: 0.8,
    );
  }

  static TextStyle body(BuildContext context, {double size = 16}) {
    return GoogleFonts.inter(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      fontSize: size,
      color: Theme.of(context).textTheme.bodyMedium?.color,
      height: 1.5,
    );
  }

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color primaryTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark(context) ? text : const Color(0xFF0D0D0D));
  }

  static Color secondaryTextColor(BuildContext context) {
    return isDark(context) ? muted : const Color(0xFF6B7280);
  }

  static Color subtleTextColor(BuildContext context) {
    return isDark(context) ? const Color(0xFF555555) : const Color(0xFF9CA3AF);
  }

  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  static Color elevatedColor(BuildContext context) {
    return isDark(context) ? elevated : const Color(0xFFF3F4F6);
  }

  static Color borderColor(BuildContext context) {
    return Theme.of(context).dividerColor;
  }

  static Color inputFillColor(BuildContext context) {
    return isDark(context) ? bg : const Color(0xFFFFFFFF);
  }

  /// Light theme matching HarmFilter design tokens.
  static ThemeData lightTheme({Color? accentColor}) {
    final accent = accentColor ?? _accent;
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF2F4F7),
      primaryColor: accent,
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        secondary: accent,
        surface: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF0D0D0D),
        brightness: Brightness.light,
      ),
      cardColor: const Color(0xFFFFFFFF),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        elevation: 0,
        shadowColor: const Color(0x0D000000),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF0D0D0D),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF374151)),
        titleTextStyle: TextStyle(
          color: Color(0xFF0D0D0D),
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFFFFFFFF),
        selectedItemColor: accent,
        unselectedItemColor: const Color(0xFF9CA3AF),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      dividerColor: const Color(0xFFE5E7EB),
      shadowColor: const Color(0x0D000000),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFF0D0D0D),
        displayColor: const Color(0xFF0D0D0D),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF374151)),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return accent;
          return const Color(0xFFFFFFFF);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accent.withOpacity(0.35);
          }
          return const Color(0xFFD1D5DB);
        }),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  /// Dark theme with fully explicit neutral surfaces.
  static ThemeData darkTheme({Color? accentColor}) {
    final accent = accentColor ?? _accent;
    final base = ThemeData.dark();
    const scaffold = Color(0xFF121212);
    const surface = Color(0xFF1E1E1E);
    const surfaceVariant = Color(0xFF242424);

    return base.copyWith(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffold,
      cardColor: surface,
      dialogBackgroundColor: surface,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: accent,
        secondary: accent,
        surface: surface,
        surfaceContainerHighest: surfaceVariant,
        onSurface: Colors.white,
        onPrimary: Colors.white,
      ),
      canvasColor: scaffold,
      dividerColor: border,
      shadowColor: Colors.black,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: text,
        displayColor: text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: muted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: scaffold,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: border),
        ),
      ),
    );
  }
}
