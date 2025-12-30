import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class FirebaseAuthViewModel with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;

  User? _user;
  Map<String, dynamic>? _userData;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  User? get currentUser => _user;
  Map<String, dynamic>? get userData => _userData;
  String? get profileImagePath => _userData?['image'] as String?;

  bool get isLoggedIn => currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  FirebaseAuthViewModel() {
    _user = _authService.currentUser;
    _init();
  }

  void _init() {
    // Listen for Auth State Changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;

      _userDocSubscription?.cancel();

      if (user != null) {
        // Use FirestoreService to listen to data
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

    _setLoading(false); // Handles notification
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

    _setLoading(false); // Handles notification
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
    await _authService.signOut();
  }

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
