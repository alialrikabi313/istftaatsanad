import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/app_user.dart';


class FirebaseAuthRemote {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _db;
  FirebaseAuthRemote(this._auth, this._db);


  Stream<AppUser?> authChanges() => _auth.authStateChanges().map((u) => u == null ? null : AppUser(uid: u.uid, email: u.email ?? '', displayName: u.displayName));


  Future<AppUser> signInWithEmailAndCode(String email, String code) async {
// Example strategy:
// 1) Validate code exists in Firestore collection 'auth_codes/{email}' and matches, not expired.
    final doc = await _db.collection('auth_codes').doc(email).get();
    if (!doc.exists) {
      throw Exception('الرمز غير صحيح');
    }
    final data = doc.data()!;
    if (data['code'] != code) {
      throw Exception('الرمز غير صحيح');
    }
    final expiresAt = (data['expiresAt'] as Timestamp).toDate();
    if (DateTime.now().isAfter(expiresAt)) {
      throw Exception('انتهت صلاحية الرمز');
    }
// 2) If valid, sign in anonymously and link email via custom claim or create user with a fixed password convention via Cloud Function.
// For simplicity here: sign in anonymously then update profile with email in custom users collection.
    final cred = await _auth.signInAnonymously();
    final user = cred.user!;
    await _db.collection('users').doc(user.uid).set({
      'email': email,
      'displayName': data['name'] ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));


    return AppUser(uid: user.uid, email: email, displayName: data['name']);
  }


  Future<void> signOut() => _auth.signOut();
}