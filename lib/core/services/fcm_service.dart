import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // اشتراك عام لإعلانات الشيخ
    try {
      await _messaging.subscribeToTopic('sanad_public');
    } catch (_) {}

    _auth.authStateChanges().listen((user) async {
      if (user == null) return;
      await _saveToken(user.uid);
    });

    _messaging.onTokenRefresh.listen((token) async {
      final uid = _auth.currentUser?.uid;
      if (uid != null) await _writeToken(uid, token);
    });

    FirebaseMessaging.onMessage.listen((msg) {
      if (kDebugMode) {
        debugPrint('FCM foreground: ${msg.notification?.title}');
      }
    });
  }

  Future<void> _saveToken(String uid) async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await _writeToken(uid, token);
  }

  Future<void> _writeToken(String uid, String token) async {
    await _db.collection('users').doc(uid).set({
      'fcmToken': token,
      'fcmUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
