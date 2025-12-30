import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Singleton Pattern
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- User Collection Constants ---
  static const String _collectionUser = 'user';

  /// Stream to listen to real-time changes in the user's document
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String uid) {
    return _firestore.collection(_collectionUser).doc(uid).snapshots();
  }

  /// Creates or Overwrites user data (Used during Sign Up)
  Future<void> saveUser({
    required String uid,
    required String email,
    required String name,
  }) async {
    await _firestore.collection(_collectionUser).doc(uid).set({
      'email': email,
      'name': name,
      'image': '', // Initialize empty image path
    }, SetOptions(merge: true));
  }

  /// Updates the User's Name
  Future<void> updateName(String uid, String name) async {
    await _firestore.collection(_collectionUser).doc(uid).update({
      'name': name,
    });
  }

  /// Updates the User's Email
  Future<void> updateEmail(String uid, String email) async {
    await _firestore.collection(_collectionUser).doc(uid).update({
      'email': email,
    });
  }

  /// Saves/Updates the local image path
  Future<String?> updateProfileImage(String uid, String imagePath) async {
    try {
      await _firestore.collection(_collectionUser).doc(uid).set({
        'image': imagePath,
      }, SetOptions(merge: true));
      return null; // Success
    } on FirebaseException catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to save image path: $e";
    }
  }
}
