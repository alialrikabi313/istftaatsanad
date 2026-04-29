import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/topic.dart';
import '../../domain/entities/subtopic.dart';
import '../../domain/entities/qa_item.dart';
import '../models/topic_dto.dart';
import '../models/subtopic_dto.dart';
import '../models/qa_item_dto.dart';


class FirestoreContentRemote {
  final FirebaseFirestore _db;
  FirestoreContentRemote(this._db);


  Stream<List<Topic>> watchTopics() => _db
      .collection('topics')
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map((d) => TopicDto.fromMap(d.id, d.data()).toEntity()).toList());


  Stream<List<Subtopic>> watchSubtopics(String topicId) => _db
      .collection('topics')
      .doc(topicId)
      .collection('subtopics')
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map((d) => SubtopicDto.fromMap(d.id, topicId, d.data()).toEntity()).toList());


  Stream<List<QaItem>> watchQuestions(String topicId, String subtopicId) => _db
      .collection('topics')
      .doc(topicId)
      .collection('subtopics')
      .doc(subtopicId)
      .collection('questions')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => QaItemDto.fromMap(d.id, topicId, subtopicId, d.data()).toEntity()).toList());


  Future<List<QaItem>> search(String query) async {
// Firestore full-text search best via an index (e.g., Algolia or Firebase Extensions). Placeholder simple search by prefix on a mirror collection.
    final snap = await _db
        .collection('questions_search') // pre-indexed by admin app
        .where('q_prefix', isGreaterThanOrEqualTo: query)
        .where('q_prefix', isLessThan: '$query\uf8ff')
        .limit(50)
        .get();
    return snap.docs
        .map((d) => QaItemDto.fromMap(d.id, d['topicId'], d['subtopicId'], d.data()).toEntity())
        .toList();
  }


  Stream<Set<String>> watchFavorites(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('favorites')
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toSet());


  Future<void> toggleFavorite(String uid, String qaId, bool value) async {
    final ref = _db.collection('users').doc(uid).collection('favorites').doc(qaId);
    if (value) {
      await ref.set({'at': FieldValue.serverTimestamp()});
    } else {
      await ref.delete();
    }
  }
}