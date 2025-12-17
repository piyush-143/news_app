import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  static const String _themeKey = "is_dark_mode";

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeViewModel() {
    _loadTheme();
  }

  /// Load saved theme preference on startup
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to false (Light Mode) if no preference is saved
    final isDark = prefs.getBool(_themeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Toggle and save theme preference
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Update UI immediately

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark); // Persist to storage
  }
}
