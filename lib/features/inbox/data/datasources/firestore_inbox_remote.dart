import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreInboxRemote {
  final FirebaseFirestore _db;
  FirestoreInboxRemote(this._db);

  Future<void> send(String uid, String email, String name, String text) async {
    await _db.collection('inbox').add({
      'uid': uid,
      'email': email,
      'name': name,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
      'status': 'new',
    });
  }
}
