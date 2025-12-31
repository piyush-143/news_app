import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class FirebaseAuthViewModel with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;

  User? _user;
  Map<String, dynamic>? _userData; // Holds real-time data from Firestore
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  bool _isLoading = false;
  bool _isGoogleSignIn = false;
  String? _errorMessage;
  String? _successMessage;

  User? get currentUser => _user;
  Map<String, dynamic>? get userData => _userData;

  // Safely extract the image path from the Firestore data map
  String? get profileImagePath => _userData?['image'] as String?;

  bool get isLoggedIn => currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isGoogleSignIn => _isGoogleSignIn;

  FirebaseAuthViewModel() {
    // Initialize user synchronously to prevent "Not Logged In" flash on app restart
    _user = _authService.currentUser;
    _init();
  }

  void _init() {
    // Listen for Auth State Changes (Login/Logout events)
    _authService.authStateChanges.listen((User? user) {
      _user = user;

      // Cancel previous Firestore subscription to avoid memory leaks
      _userDocSubscription?.cancel();

      if (user != null) {
        // If logged in, subscribe to the specific user's Firestore document
        // This ensures the UI updates immediately when data (like Name/Image) changes in the DB
        _userDocSubscription = _firestoreService
            .getUserStream(user.uid)
            .listen(
              (snapshot) {
                if (snapshot.exists && snapshot.data() != null) {
                  _userData = snapshot.data() as Map<String, dynamic>;
                  notifyListeners();
                }
              },
              onError: (error) {
                debugPrint("Error listening to user doc: $error");
              },
            );
      } else {
        // If logged out, clear local user data
        _userData = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _userDocSubscription?.cancel();
    super.dispose();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Persists the Google Sign-In state to SharedPreferences.
  /// Used to conditionally hide UI elements (like Email Edit) for Google users.
  Future<void> setGoogleSignIn(bool isGoogle) async {
    if (_isGoogleSignIn != isGoogle) {
      _isGoogleSignIn = isGoogle;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isGoogleSignIn', isGoogle);
      notifyListeners();
    }
  }

  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    final error = await _authService.loginWithEmailAndPassword(email, password);

    if (error != null) {
      _errorMessage = error;
    } else {
      // Sync Firestore with Auth data immediately upon login
      await reloadUserData();
    }

    _setLoading(false);
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

    if (error != null) {
      _errorMessage = error;
    }

    _setLoading(false);
    return error == null;
  }

  Future<bool> googleSignIn() async {
    _setLoading(true);
    _errorMessage = null;

    final error = await _authService.googleSignIn();

    if (error != null) {
      _errorMessage = error;
    } else {
      // Flag session as Google Sign-In and sync data
      await setGoogleSignIn(true);
      await reloadUserData();
    }

    _setLoading(false);
    return error == null;
  }

  Future<bool> updateUserProfile({
    required String name,
    required String email,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final result = await _authService.updateUserProfile(
      name: name,
      email: email,
    );

    _setLoading(false);

    if (result != null) {
      // If result contains "Verification", it's a specific success case requiring logout
      if (result.contains("Verification email sent")) {
        _successMessage = result;
        return true;
      } else {
        _errorMessage = result;
        return false;
      }
    } else {
      _successMessage = "Profile updated successfully";
      await reloadUserData();
      return true;
    }
  }

  Future<bool> updateProfilePicture(String imagePath) async {
    _setLoading(true);
    _errorMessage = null;

    if (_user == null) {
      _setLoading(false);
      return false;
    }

    // Update Firestore directly; the _init() stream will update the UI automatically
    final error = await _firestoreService.updateProfileImage(
      _user!.uid,
      imagePath,
    );

    if (error != null) {
      _errorMessage = error;
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
    // Reset Google Sign-In flag on logout
    await setGoogleSignIn(false);
    await _authService.signOut();
  }

  /// Forces a refresh of the User object from Firebase Auth
  /// and updates local state. Useful after email verification.
  Future<void> reloadUserData() async {
    if (_user == null) return;

    await _authService.reloadUser();

    final refreshedUser = _authService.currentUser;

    if (refreshedUser != null) {
      _user = refreshedUser;
      notifyListeners();
    }
  }
}
