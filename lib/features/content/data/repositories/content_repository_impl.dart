import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/topic.dart';
import '../../domain/entities/subtopic.dart';
import '../../domain/entities/question.dart';

/// مستودع المحتوى - مطابق لتطبيق الإدارة (SanadAdmin)
class ContentRepositoryImpl {
  final FirebaseFirestore _db;
  final SharedPreferences _prefs;

  ContentRepositoryImpl(this._db, this._prefs);

  // ---------------------------
  // الأقسام الرئيسية (Topics)
  // ---------------------------
  Stream<List<Topic>> watchTopics() {
    return _db.collection('topics').orderBy('order').snapshots().map((s) {
      return s.docs.map((d) => Topic.fromMap(d.data(), d.id)).toList();
    });
  }

  // ---------------------------
  // الأقسام الفرعية (Subtopics) - مطابق لتطبيق الإدارة
  // ---------------------------
  Stream<List<Subtopic>> watchSubtopics(String topicId) {
    // ✅ collection مستقل + where + orderBy
    return _db
        .collection('subtopics')
        .where('topicId', isEqualTo: topicId)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => Subtopic.fromMap(d.data(), d.id)).toList());
  }

  // ---------------------------
  // الأسئلة (Questions) - مع فلترة المحذوفات
  // ---------------------------
  Stream<List<Question>> watchQuestions(String topicId, String subtopicId) {
    Query col = _db.collection('questions');

    if (subtopicId != 'all') {
      col = col.where('subtopicId', isEqualTo: subtopicId);
    }

    return col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) {
          // ✅ فلترة المحذوفات كما في تطبيق الإدارة
          return s.docs
            .where((d) {
              final data = d.data() as Map<String, dynamic>;
              return data['isDeleted'] != true && data['status'] != 'deleted';
            })
            .map((d) => Question.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList();
        });
  }

  // ---------------------------
  // البحث
  // ---------------------------
  Future<List<Question>> searchQuestions(String keyword) async {
    final q = keyword.trim();
    if (q.isEmpty) return [];

    final snap = await _db
        .collection('questions')
        .where('question', isGreaterThanOrEqualTo: q)
        .where('question', isLessThan: '$q\uf8ff')
        .limit(20)
        .get();

    // ✅ فلترة المحذوفات
    return snap.docs
        .where((d) {
          final data = d.data();
          return data['isDeleted'] != true && data['status'] != 'deleted';
        })
        .map((d) => Question.fromMap(d.data(), d.id))
        .toList();
  }

  // ---------------------------
  // أسئلتي (My Questions) - مطابق لتطبيق الإدارة
  // ---------------------------
  Stream<List<Question>> watchMyQuestions(String uid) {
    // ✅ استخدام 'uid' بدلاً من 'userId'
    return _db
        .collection('questions')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) {
          // ✅ فلترة المحذوفات
          return s.docs
            .where((d) {
              final data = d.data();
              return data['isDeleted'] != true && data['status'] != 'deleted';
            })
            .map((d) => Question.fromMap(d.data(), d.id))
            .toList();
        });
  }

  // ---------------------------
  // المفضلة (Favorites)
  // ---------------------------
  static const _favoritesKey = 'favorites';

  Future<Set<String>> loadFavorites() async {
    final list = _prefs.getStringList(_favoritesKey) ?? [];
    return list.toSet();
  }

  Future<void> saveFavorites(Set<String> favs) async {
    await _prefs.setStringList(_favoritesKey, favs.toList());
  }

  Future<void> toggleFavorite(String id, bool val) async {
    final favs = await loadFavorites();
    if (val) {
      favs.add(id);
    } else {
      favs.remove(id);
    }
    await saveFavorites(favs);
  }

  // ---------------------------
  // جلب عنصر مفرد
  // ---------------------------
  Future<Question?> getQuestionById(String id) async {
    final doc = await _db.collection('questions').doc(id).get();
    final data = doc.data();

    if (data == null) {
      return null; // السؤال غير موجود أو تم حذفه
    }

    // ✅ التحقق من أن السؤال ليس محذوفاً
    if (data['isDeleted'] == true || data['status'] == 'deleted') {
      return null;
    }

    return Question.fromMap(data, id);
  }
}