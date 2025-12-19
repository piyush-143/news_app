import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  // Constants
  static const String _prefThemeKey = "is_dark_mode";

  // --- State ---
  ThemeMode _themeMode = ThemeMode.light;

  // --- Getters ---
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeViewModel() {
    _loadTheme();
  }

  /// Load saved theme preference on startup
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Default to Light Mode (false) if no preference is found
      final isDark = prefs.getBool(_prefThemeKey) ?? false;

      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      // If SP fails, default to light mode and don't crash
      debugPrint("ThemeViewModel Error loading theme: $e");
    }
  }

  /// Toggle and save theme preference
  Future<void> toggleTheme(bool isDark) async {
    // OPTIMIZATION: Prevent unnecessary rebuilds if state is identical
    if (isDark == isDarkMode) return;

    // Optimistic Update: Update UI immediately before saving to disk
    // This makes the toggle feel instant.
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefThemeKey, isDark);
    } catch (e) {
      debugPrint("ThemeViewModel Error saving theme: $e");
    }
  }
}
