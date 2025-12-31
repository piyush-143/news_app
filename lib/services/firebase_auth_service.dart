import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firestore_service.dart';

class FirebaseAuthService {
  // Singleton Pattern
  FirebaseAuthService._();
  static final FirebaseAuthService instance = FirebaseAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool isInitialized = false;

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

      final user = credential.user;
      if (user != null) {
        // Optimization: Run Auth update and Firestore save in parallel
        await Future.wait([
          user.updateDisplayName(name),
          user.updatePhotoURL(user.photoURL),
          _firestoreService.saveUser(uid: user.uid, email: email, name: name),
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

  Future<void> initGoogleSignIn() async {
    if (!isInitialized) {
      await _googleSignIn.initialize(
        clientId:
            "620311657206-hrn0vkd2krp04dl2170f3ouoroj11r47.apps.googleusercontent.com",
      );
    }
    isInitialized = true;
  }

  Future<String?> googleSignIn() async {
    try {
      await initGoogleSignIn();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      GoogleSignInClientAuthorization? authorization = await googleUser
          .authorizationClient
          .authorizationForScopes(['email', 'profile']);
      final accessToken = authorization?.accessToken;
      if (accessToken == null) {
        final authorization2 = await googleUser.authorizationClient
            .authorizationForScopes(['email', 'profile']);
        if (authorization2?.accessToken == null) {
          return "Access Token Failed. User Different Gmail...";
        }
        authorization = authorization2;
      }
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(
        authCredential,
      );

      final user = userCredential.user;
      if (user != null) {
        // ✅ CHECK IF USER EXISTS BEFORE SAVING
        // Fetch the document snapshot to see if we already have data for this user
        final DocumentSnapshot userDoc = await _firestoreService
            .getUserStream(user.uid)
            .first;

        if (!userDoc.exists) {
          // Only save/reset data if this is a brand new user
          await Future.wait([
            user.updateDisplayName(user.displayName ?? 'No Name'),
            user.updatePhotoURL(user.photoURL),
            _firestoreService.saveUser(
              uid: user.uid,
              email: user.email!,
              name: user.displayName ?? 'No Name',
            ),
          ]);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Google Sign-In Cancelled...";
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
        await user.verifyBeforeUpdateEmail(email!);
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
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
