import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global ValueNotifier untuk tema — bisa diakses dari mana saja
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

class ThemeHelper {
  static const _key = 'theme_mode';

  /// Muat preferensi tema yang tersimpan
  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? true; // default: dark
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Toggle tema dan simpan preferensi
  static Future<void> toggleTheme() async {
    final isDark = themeNotifier.value == ThemeMode.dark;
    themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, !isDark);
  }

  static bool get isDark => themeNotifier.value == ThemeMode.dark;

  // ─────────────────── DARK THEME ───────────────────
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF6C63FF),
    scaffoldBackgroundColor: const Color(0xFF1E1E2C),
    colorScheme: const ColorScheme.dark(
      primary:    Color(0xFF6C63FF),
      secondary:  Color(0xFF00E5FF),
      surface:    Color(0xFF2A2D3E),
      onPrimary:  Colors.white,
      onSecondary: Colors.white,
      onSurface:  Colors.white,
    ),
    cardColor: const Color(0xFF2A2D3E),
    dividerColor: Colors.white12,
    iconTheme: const IconThemeData(color: Colors.white70),
    textTheme: const TextTheme(
      displayLarge:  TextStyle(color: Colors.white,   fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: Colors.white,   fontSize: 26, fontWeight: FontWeight.bold),
      titleLarge:    TextStyle(color: Colors.white,   fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium:   TextStyle(color: Colors.white,   fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall:    TextStyle(color: Colors.white70, fontSize: 14),
      bodyLarge:     TextStyle(color: Colors.white,   fontSize: 16, height: 1.5),
      bodyMedium:    TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
      bodySmall:     TextStyle(color: Colors.white54, fontSize: 12),
      labelLarge:    TextStyle(color: Colors.white,   fontSize: 14, fontWeight: FontWeight.w600),
      labelSmall:    TextStyle(color: Colors.white54, fontSize: 11),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2A2D3E),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF1E1E2C),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Colors.white,
      iconColor: Colors.white70,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      labelStyle: const TextStyle(color: Colors.white54),
      hintStyle: const TextStyle(color: Colors.white30),
      prefixIconColor: Colors.white54,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00E5FF)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF00E5FF)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? const Color(0xFF6C63FF) : Colors.white54),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? const Color(0xFF6C63FF).withValues(alpha: 0.4) : Colors.white24),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6C63FF),
      foregroundColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2A2D3E),
      labelStyle: const TextStyle(color: Colors.white70),
      side: const BorderSide(color: Colors.white12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  // ─────────────────── LIGHT THEME ───────────────────
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF5A52E0),
    scaffoldBackgroundColor: const Color(0xFFF0F0FA),
    colorScheme: const ColorScheme.light(
      primary:    Color(0xFF5A52E0),
      secondary:  Color(0xFF0097A7),
      surface:    Colors.white,
      onPrimary:  Colors.white,
      onSecondary: Colors.white,
      onSurface:  Color(0xFF1A1A2E),
    ),
    cardColor: Colors.white,
    dividerColor: Colors.black12,
    iconTheme: const IconThemeData(color: Color(0xFF3A3A5C)),
    textTheme: const TextTheme(
      displayLarge:  TextStyle(color: Color(0xFF1A1A2E), fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: Color(0xFF1A1A2E), fontSize: 26, fontWeight: FontWeight.bold),
      titleLarge:    TextStyle(color: Color(0xFF1A1A2E), fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium:   TextStyle(color: Color(0xFF2D2D4E), fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall:    TextStyle(color: Color(0xFF4A4A6A), fontSize: 14),
      bodyLarge:     TextStyle(color: Color(0xFF1A1A2E), fontSize: 16, height: 1.5),
      bodyMedium:    TextStyle(color: Color(0xFF3A3A5C), fontSize: 14, height: 1.5),
      bodySmall:     TextStyle(color: Color(0xFF6A6A8A), fontSize: 12),
      labelLarge:    TextStyle(color: Color(0xFF1A1A2E), fontSize: 14, fontWeight: FontWeight.w600),
      labelSmall:    TextStyle(color: Color(0xFF6A6A8A), fontSize: 11),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF5A52E0),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Color(0xFF1A1A2E),
      iconColor: Color(0xFF5A52E0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5FF),
      labelStyle: const TextStyle(color: Color(0xFF5A52E0)),
      hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
      prefixIconColor: const Color(0xFF5A52E0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5A52E0), width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5A52E0),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF5A52E0)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? const Color(0xFF5A52E0) : Colors.grey.shade400),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? const Color(0xFF5A52E0).withValues(alpha: 0.4) : Colors.grey.shade300),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF5A52E0),
      foregroundColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFEEEEFF),
      labelStyle: const TextStyle(color: Color(0xFF3A3A5C)),
      side: const BorderSide(color: Color(0xFFCCCCEE)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
