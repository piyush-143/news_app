import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firestore_service.dart';

class FirebaseAuthService {
  // Singleton Pattern
  FirebaseAuthService._();
  static final FirebaseAuthService instance = FirebaseAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<String?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Optimization: Run Auth update and Firestore save in parallel
        // This reduces the total time the user waits
        await Future.wait([
          credential.user!.updateDisplayName(name),
          _firestoreService.saveUser(
            uid: credential.user!.uid,
            email: email,
            name: name,
          ),
        ]);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred";
    }
  }

  Future<String?> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred";
    }
  }

  Future<String?> updateUserProfile({
    required String name,
    required String email,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "User not logged in";

      // Optimization: Check if changes are actually needed before making API calls
      final bool nameChanged = name != user.displayName;
      final bool emailChanged = email != user.email;

      if (!nameChanged && !emailChanged) return null;

      // 1. Update Name (Parallelize Auth and Firestore updates)
      if (nameChanged) {
        await Future.wait([
          user.updateDisplayName(name),
          _firestoreService.updateName(user.uid, name),
        ]);
      }

      // 2. Handle Email Update
      if (emailChanged) {
        await user.verifyBeforeUpdateEmail(email);
        await user.reload();
        return "Verification email sent to $email. Please check your inbox.";
      }

      await user.reload();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return "Security Check: Please logout and login again to change your email.";
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await user.reload();

      // Sync latest Email to Firestore if verified/changed
      if (user.email != null) {
        await _firestoreService.updateEmail(user.uid, user.email!);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error reloading user: $e");
      }
    }
  }

  Future<String?> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
