import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create or overwrite user document at `users/{uid}` with [data]
  static Future<void> setUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data);
  }

  /// Update fields on existing user document. Creates doc if missing.
  static Future<void> updateUserData(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  /// Convenience to set the user's score (number)
  static Future<void> setUserScore(String uid, int score) async {
    await updateUserData(uid, {
      'score': score,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Read user document once
  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(
    String uid,
  ) async {
    return await _db.collection('users').doc(uid).get();
  }
}
