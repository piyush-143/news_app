import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app/services/db_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DbViewModel with ChangeNotifier {
  final DbService _dbService = DbService.getInstance;

  // State to track if user is currently logged in
  bool _isLoggedIn = false;
  String? _currentUserEmail;
  bool _isLoading = false;

  // --- UI State: Password Visibility ---
  bool _isLoginPasswordVisible = false;
  bool _isSignupPasswordVisible = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUserEmail;
  bool get isLoading => _isLoading;

  bool get isLoginPasswordVisible => _isLoginPasswordVisible;
  bool get isSignupPasswordVisible => _isSignupPasswordVisible;

  /// Helper to set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
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

  /// Sign Up Logic
  Future<bool> signup(String email, String password, String name) async {
    setLoading(true);
    bool success = await _dbService.saveDetails(
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
    await Future.delayed(const Duration(milliseconds: 500));

    bool exists = await _dbService.loginUser(email: email, pass: password);
    if (exists) {
      await _setSession(email);
    }
    setLoading(false);
    return exists;
  }

  /// Update Profile Logic
  Future<bool> updateProfile(String newName, String newEmail) async {
    if (_currentUserEmail == null) return false;

    setLoading(true);
    bool success = await _dbService.updateUserProfile(
      oldEmail: _currentUserEmail!,
      newEmail: newEmail,
      newName: newName,
    );

    if (success) {
      if (_currentUserEmail != newEmail) {
        await _setSession(newEmail);
      }
      notifyListeners();
    }
    setLoading(false);
    return success;
  }

  /// Update Profile Picture Logic
  Future<bool> updateProfilePicture() async {
    if (_currentUserEmail == null) return false;

    final ImagePicker picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return false; // User canceled

    setLoading(true);

    try {
      // 1. Get Application Document Directory
      final directory = await getApplicationDocumentsDirectory();

      // 2. Copy image to app directory to ensure persistence
      final String newPath = path.join(
        directory.path,
        'profile_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await File(image.path).copy(newPath);

      // 3. Update DB with new path
      bool success = await _dbService.updateProfileImage(
        _currentUserEmail!,
        newPath,
      );

      if (success) {
        notifyListeners(); // Refresh UI
      }

      setLoading(false);
      return success;
    } catch (e) {
      setLoading(false);
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_email');
    _isLoggedIn = false;
    _currentUserEmail = null;
    notifyListeners();
  }

  /// Check Session on App Start
  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user_email');
    if (email != null) {
      _currentUserEmail = email;
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  // Private helper to save session
  Future<void> _setSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_email', email);
    _currentUserEmail = email;
    _isLoggedIn = true;
    notifyListeners();
  }
}
