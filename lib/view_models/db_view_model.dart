import 'dart:io';

import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/db_service.dart';

/// ViewModel managing User Authentication, Profile Updates, and Session State.
class DbViewModel with ChangeNotifier {
  final DbService _dbService = DbService.getInstance;

  // Key for persisting session data
  static const String _prefUserEmailKey = 'current_user_email';

  // --- State Variables ---
  bool _isLoggedIn = false;
  String? _currentUserEmail;
  bool _isLoading = false;

  // --- UI State: Password Visibility Toggles ---
  bool _isLoginPasswordVisible = false;
  bool _isSignupPasswordVisible = false;
  bool _isForgotPasswordVisible = false;
  bool _isForgotConfirmPasswordVisible = false;

  // --- Public Getters ---
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUserEmail;
  bool get isLoading => _isLoading;

  bool get isLoginPasswordVisible => _isLoginPasswordVisible;
  bool get isSignupPasswordVisible => _isSignupPasswordVisible;
  bool get isForgotPasswordVisible => _isForgotPasswordVisible;
  bool get isForgotConfirmPasswordVisible => _isForgotConfirmPasswordVisible;

  /// Updates loading state and notifies UI listeners.
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // --- UI Logic: Password Toggles ---

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

  /// Registers a new user and automatically logs them in if successful.
  Future<bool> signup(String email, String password, String name) async {
    setLoading(true);

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

  /// Authenticates the user and establishes a session.
  Future<bool> login(String email, String password) async {
    setLoading(true);

    final exists = await _dbService.loginUser(email: email, pass: password);
    if (exists) {
      await _setSession(email);
    }
    setLoading(false);
    return exists;
  }

  /// Verifies if an email exists in the database (used for password recovery).
  Future<bool> checkEmailExists(String email) async {
    setLoading(true);
    final user = await _dbService.getUserDetails(email);
    setLoading(false);
    return user != null;
  }

  /// Updates the user's password in the database.
  Future<bool> resetPassword(String email, String newPassword) async {
    setLoading(true);
    final success = await _dbService.updatePassword(email, newPassword);
    setLoading(false);
    return success;
  }

  // --- Profile Management ---

  /// Updates user profile details.
  /// Handles session updates if the email is changed.
  Future<bool> updateProfile(String newName, String newEmail) async {
    if (_currentUserEmail == null) return false;

    setLoading(true);

    final success = await _dbService.updateUserProfile(
      oldEmail: _currentUserEmail!,
      newEmail: newEmail,
      newName: newName,
    );

    if (success) {
      // If email changed, we must update the session key to persist the login.
      if (_currentUserEmail != newEmail) {
        await _setSession(newEmail);
      } else {
        // If only the name changed, we manually trigger a UI rebuild.
        notifyListeners();
      }
    }
    setLoading(false);
    return success;
  }

  /// Pick an image from gallery, compress it, and save it to local storage.
  Future<bool> updateProfilePicture() async {
    if (_currentUserEmail == null) return false;

    try {
      final ImagePicker picker = ImagePicker();

      // Compressing image (quality: 70) to optimize storage and load performance
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return false; // User canceled selection

      setLoading(true);

      final directory = await getApplicationDocumentsDirectory();

      // Use timestamp in filename to avoid caching issues when the user changes photos
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final String newPath = path.join(directory.path, fileName);

      // Save copy to app's document directory
      await File(image.path).copy(newPath);

      // Update database reference
      final success = await _dbService.updateProfileImage(
        _currentUserEmail!,
        newPath,
      );

      if (success) {
        notifyListeners();
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

  /// Clears local session data and resets state.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefUserEmailKey);

    _isLoggedIn = false;
    _currentUserEmail = null;
    notifyListeners();
  }

  /// Checks for an existing session on app startup.
  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_prefUserEmailKey);

    if (email != null && email.isNotEmpty) {
      _currentUserEmail = email;
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  /// Helper to save user email to SharedPreferences and update state.
  Future<void> _setSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserEmailKey, email);

    _currentUserEmail = email;
    _isLoggedIn = true;
    notifyListeners();
  }
}
