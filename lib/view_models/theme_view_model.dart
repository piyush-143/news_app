import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the application's theme state (Light vs Dark) and persists user preference.
class ThemeViewModel extends ChangeNotifier {
  static const String _prefThemeKey = "is_dark_mode";

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeViewModel() {
    _loadTheme();
  }

  /// Loads the saved theme preference from local storage on app startup.
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Default to Light Mode (false) if the user hasn't set a preference yet.
      final isDark = prefs.getBool(_prefThemeKey) ?? false;

      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      // Fail gracefully: default to light mode if storage is inaccessible.
      debugPrint("ThemeViewModel Error loading theme: $e");
    }
  }

  /// Toggles the theme and saves the preference to local storage.
  Future<void> toggleTheme(bool isDark) async {
    // Avoid rebuilding the UI if the requested mode is already active.
    if (isDark == isDarkMode) return;

    // Optimistic Update: Change the UI state immediately so the switch feels instant,
    // then save to storage in the background.
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
