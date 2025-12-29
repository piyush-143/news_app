import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  // Singleton Pattern
  FirebaseAuthService._();
  static final FirebaseAuthService instance = FirebaseAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

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

  // ✅ UPDATED: Accepts Name and updates profile immediately + Creates Firestore Doc
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
        await credential.user!.updateDisplayName(name);

        // Create the user document in Firestore to prevent errors later
        await _firestore.collection('user').doc(credential.user!.uid).set({
          'email': email,
          'name': name,
          'image': '', // Initialize empty image path
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred";
    }
  }

  // ✅ UPDATED: Updates Name in Firebase Auth AND Firestore
  Future<String?> updateUserProfile({
    required String name,
    required String email,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "User not logged in";

      if (name != user.displayName) {
        await user.updateDisplayName(name);
        // Also update Firestore
        await _firestore.collection('user').doc(user.uid).update({
          'name': name,
        });
      }

      if (email != user.email) {
        await user.verifyBeforeUpdateEmail(email);
      }

      await user.reload();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ✅ NEW: Saves image PATH to Firestore
  Future<String?> uploadProfileImage(String imagePath) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "User not logged in";

      // Store the path string in the 'user' collection
      final ref = _firestore.collection('user').doc(user.uid);

      // Use SetOptions(merge: true) to ensure we don't overwrite existing data
      await ref.set({'image': imagePath}, SetOptions(merge: true));

      return null; // Success
    } on FirebaseException catch (e) {
      return e.message;
    } catch (e) {
      return "Image path save failed: $e";
    }
  }

  // ✅ NEW: Retrieve the image path from Firestore (Simplified method)
  Future<String?> getUserImagePath(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('user').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc['image'].toString();
      }
      return null;
    } catch (e) {
      return null;
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

  // ✅ Kept Google Sign-In to prevent app breakage (Commented Out)
  /*
  Future<String?> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Google Sign-In cancelled.";

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Google Sign-In failed: $e";
    }
  }
  */

  Future<void> signOut() async {
    // await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
