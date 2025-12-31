import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firestore_service.dart';

class FirebaseAuthService {
  // Singleton Pattern to ensure a single instance throughout the app
  FirebaseAuthService._();
  static final FirebaseAuthService instance = FirebaseAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;

  // Using the specific instance getter as requested
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool isInitialized = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Registers a new user with Email and Password.
  /// Also syncs the provided Name to the Auth profile and Firestore.
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
        // Optimization: Update Auth Profile and create Firestore document in parallel
        // to reduce waiting time for the user.
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

  /// Logs in an existing user with Email and Password.
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

  /// Initializes the Google Sign-In configuration.
  /// This must be called before authentication.
  Future<void> initGoogleSignIn() async {
    if (!isInitialized) {
      await _googleSignIn.initialize(
        // Ensure this Client ID matches your Google Cloud Console credentials
        clientId:
            "620311657206-hrn0vkd2krp04dl2170f3ouoroj11r47.apps.googleusercontent.com",
      );
    }
    isInitialized = true;
  }

  /// Handles the complete Google Sign-In flow including:
  /// 1. Triggering the Google Authentication dialog.
  /// 2. Retrieving and verifying access tokens.
  /// 3. Signing in to Firebase with credentials.
  /// 4. Syncing user data to Firestore if it's a new user.
  Future<String?> googleSignIn() async {
    try {
      await initGoogleSignIn();

      // 1. Authenticate with Google
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // 2. Retrieve Tokens
      final idToken = googleUser.authentication.idToken;

      // Attempt to get authorization with specific scopes
      GoogleSignInClientAuthorization? authorization = await googleUser
          .authorizationClient
          .authorizationForScopes(['email', 'profile']);

      var accessToken = authorization?.accessToken;

      // Fallback logic if access token is missing initially
      if (accessToken == null) {
        final authorization2 = await googleUser.authorizationClient
            .authorizationForScopes(['email', 'profile']);
        if (authorization2?.accessToken == null) {
          return "Access Token Failed. User Different Gmail...";
        }
        accessToken = authorization2!.accessToken;
      }

      // 3. Create Firebase Credential
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // 4. Sign In to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        authCredential,
      );

      final user = userCredential.user;
      if (user != null) {
        // 5. Check if user exists in Firestore to avoid overwriting existing data
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

  /// Updates the user's profile information.
  /// - Name updates are immediate.
  /// - Email updates trigger a verification flow.
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
      // verifyBeforeUpdateEmail sends a verification link to the NEW email.
      // The actual email property on the user object won't update until clicked.
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

  /// Refreshes the local user object from the server.
  /// Useful to check if email verification is complete.
  Future<void> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await user.reload();

      // Sync latest Email to Firestore if it changed on the server (e.g. after verification)
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
