import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firebase_auth_service.dart';

class FirebaseAuthViewModel with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService.instance;

  User? _user;
  String? _profileImagePath; // Local path to image stored in Firestore
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _user;
  String? get profileImagePath => _profileImagePath;
  bool get isLoggedIn => currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FirebaseAuthViewModel() {
    _user = _authService.currentUser;
    // Initial fetch if user is already logged in
    if (_user != null) {
      _fetchUserProfileImage();
    }

    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _fetchUserProfileImage();
      } else {
        _profileImagePath = null;
      }
      notifyListeners();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Helper to fetch the image path from Firestore
  Future<void> _fetchUserProfileImage() async {
    if (_user != null) {
      _profileImagePath = await _authService.getUserImagePath(_user!.uid);
      notifyListeners();
    }
  }

  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    final error = await _authService.loginWithEmailAndPassword(email, password);
    if (error != null) _errorMessage = error;
    _setLoading(false);
    notifyListeners();
    return error == null;
  }

  Future<bool> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    _setLoading(true);
    _errorMessage = null;
    final error = await _authService.signUpWithEmailAndPassword(
      email,
      password,
      name,
    );
    if (error != null) _errorMessage = error;
    _setLoading(false);
    notifyListeners();
    return error == null;
  }

  Future<bool> updateUserProfile({
    required String name,
    required String email,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final error = await _authService.updateUserProfile(
      name: name,
      email: email,
    );

    if (error != null) {
      _errorMessage = error;
    } else {
      _user = _authService.currentUser;
      notifyListeners();
    }

    _setLoading(false);
    return error == null;
  }

  Future<bool> updateProfilePicture(String imagePath) async {
    _setLoading(true);
    _errorMessage = null;

    final error = await _authService.uploadProfileImage(imagePath);

    if (error != null) {
      _errorMessage = error;
    } else {
      // Update local state immediately so UI reflects the new image
      _profileImagePath = imagePath;
      notifyListeners();
    }

    _setLoading(false);
    return error == null;
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    final error = await _authService.forgotPassword(email);
    if (error != null) _errorMessage = error;
    _setLoading(false);
    return error == null;
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
