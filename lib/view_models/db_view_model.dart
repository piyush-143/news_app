import 'dart:io';

import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/db_service.dart';

class DbViewModel with ChangeNotifier {
  // Accessing the singleton instance
  final DbService _dbService = DbService.getInstance;

  // Constants
  static const String _prefUserEmailKey = 'current_user_email';

  // --- State ---
  bool _isLoggedIn = false;
  String? _currentUserEmail;
  bool _isLoading = false;

  // --- UI State: Password Visibility ---
  bool _isLoginPasswordVisible = false;
  bool _isSignupPasswordVisible = false;
  bool _isForgotPasswordVisible = false;
  bool _isForgotConfirmPasswordVisible = false;

  // --- Getters ---
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUserEmail;
  bool get isLoading => _isLoading;

  bool get isLoginPasswordVisible => _isLoginPasswordVisible;
  bool get isSignupPasswordVisible => _isSignupPasswordVisible;
  bool get isForgotPasswordVisible => _isForgotPasswordVisible;
  bool get isForgotConfirmPasswordVisible => _isForgotConfirmPasswordVisible;

  /// Helper to set loading state
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // --- Password Visibility Toggles ---

  void toggleLoginPasswordVisibility() {
    _isLoginPasswordVisible = !_isLoginPasswordVisible;
    notifyListeners();
  }

  void toggleSignupPasswordVisibility() {
    _isSignupPasswordVisible = !_isSignupPasswordVisible;
    notifyListeners();
  }

  void toggleForgotPasswordVisibility() {
    _isForgotPasswordVisible = !_isForgotPasswordVisible;
    notifyListeners();
  }

  void toggleForgotConfirmPasswordVisibility() {
    _isForgotConfirmPasswordVisible = !_isForgotConfirmPasswordVisible;
    notifyListeners();
  }

  // --- Authentication Logic ---

  /// Sign Up Logic
  Future<bool> signup(String email, String password, String name) async {
    setLoading(true);
    // OPTIMIZATION: Removed artificial delays. Let the DB speed dictate UI.

    final success = await _dbService.saveDetails(
      email: email,
      pass: password,
      name: name,
      darkMode: false,
    );

    if (success) {
      await _setSession(email);
    }
    setLoading(false);
    return success;
  }

  /// Login Logic
  Future<bool> login(String email, String password) async {
    setLoading(true);

    final exists = await _dbService.loginUser(email: email, pass: password);
    if (exists) {
      await _setSession(email);
    }
    setLoading(false);
    return exists;
  }

  /// Check if Email Exists (For Forgot Password)
  Future<bool> checkEmailExists(String email) async {
    setLoading(true);
    final user = await _dbService.getUserDetails(email);
    setLoading(false);
    return user != null;
  }

  /// Reset Password Logic
  Future<bool> resetPassword(String email, String newPassword) async {
    setLoading(true);
    final success = await _dbService.updatePassword(email, newPassword);
    setLoading(false);
    return success;
  }

  // --- Profile Management ---

  /// Update Profile Logic
  Future<bool> updateProfile(String newName, String newEmail) async {
    if (_currentUserEmail == null) return false;

    setLoading(true);

    final success = await _dbService.updateUserProfile(
      oldEmail: _currentUserEmail!,
      newEmail: newEmail,
      newName: newName,
    );

    if (success) {
      // If email changed, we need to update the session which triggers notifyListeners
      if (_currentUserEmail != newEmail) {
        await _setSession(newEmail);
      } else {
        // If only name changed, we manually notify
        notifyListeners();
      }
    }
    setLoading(false);
    return success;
  }

  /// Update Profile Picture Logic
  Future<bool> updateProfilePicture() async {
    if (_currentUserEmail == null) return false;

    try {
      final ImagePicker picker = ImagePicker();
      // OPTIMIZATION: added imageQuality to reduce storage usage and load times
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return false; // User canceled

      setLoading(true);

      final directory = await getApplicationDocumentsDirectory();

      // Use a timestamp to ensure uniqueness and prevent caching issues
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final String newPath = path.join(directory.path, fileName);

      // Copy image to app directory
      await File(image.path).copy(newPath);

      // Update DB with new path
      final success = await _dbService.updateProfileImage(
        _currentUserEmail!,
        newPath,
      );

      if (success) {
        notifyListeners(); // Refresh UI
      }

      setLoading(false);
      return success;
    } catch (e) {
      debugPrint("Error updating profile picture: $e");
      setLoading(false);
      return false;
    }
  }

  // --- Session Management ---

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefUserEmailKey);

    _isLoggedIn = false;
    _currentUserEmail = null;
    notifyListeners();
  }

  /// Check Session on App Start
  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_prefUserEmailKey);

    if (email != null && email.isNotEmpty) {
      _currentUserEmail = email;
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  // Private helper to save session
  Future<void> _setSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserEmailKey, email);

    _currentUserEmail = email;
    _isLoggedIn = true;
    notifyListeners();
  }
}
