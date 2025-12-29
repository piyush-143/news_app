import 'package:flutter/material.dart';

class ToggleViewModel with ChangeNotifier {
  // --- UI State: Password Visibility Toggles ---
  bool _isLoginPasswordVisible = false;
  bool _isSignupPasswordVisible = false;

  // --- Public Getters ---
  bool get isLoginPasswordVisible => _isLoginPasswordVisible;
  bool get isSignupPasswordVisible => _isSignupPasswordVisible;

  // --- UI Logic: Password Toggles ---

  void toggleLoginPasswordVisibility() {
    _isLoginPasswordVisible = !_isLoginPasswordVisible;
    notifyListeners();
  }

  void toggleSignupPasswordVisibility() {
    _isSignupPasswordVisible = !_isSignupPasswordVisible;
    notifyListeners();
  }
}
