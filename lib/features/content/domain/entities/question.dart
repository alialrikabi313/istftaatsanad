import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// موديل السؤال والجواب - مطابق لتطبيق الإدارة (SanadAdmin)
class Question extends Equatable {
  final String id;
  final String question;
  final String answer;
  final String topicId;
  final String subtopicId;
  final String topicName;
  final String subtopicName;
  final List<String> tags;
  final String status; // 'published' أو 'deleted'
  final bool isDeleted;
  final DateTime? createdAt;
  
  // حقول إضافية (للأسئلة القادمة من inbox)
  final String? createdBy; // 'admin' أو null
  final String? uid; // معرف المستخدم
  final String? userName;
  final String? email;
  final DateTime? sentAt;
  final DateTime? reviewedAt;
  
  // حقل محلي للمفضلة
  final bool isFavorite;

  const Question({
    required this.id,
    required this.question,
    required this.answer,
    required this.topicId,
    required this.subtopicId,
    this.topicName = '',
    this.subtopicName = '',
    this.tags = const [],
    this.status = 'published',
    this.isDeleted = false,
    this.createdAt,
    this.createdBy,
    this.uid,
    this.userName,
    this.email,
    this.sentAt,
    this.reviewedAt,
    this.isFavorite = false,
  });

  /// ✅ دالة التحويل من Firestore - مطابقة لتطبيق الإدارة
  factory Question.fromMap(Map<String, dynamic> map, String documentId) {
    return Question(
      id: documentId,
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      topicId: map['topicId'] ?? '',
      subtopicId: map['subtopicId'] ?? '',
      topicName: map['topicName'] ?? '',
      subtopicName: map['subtopicName'] ?? '',
      tags: (map['tags'] is Iterable) ? List.from(map['tags']).whereType<String>().toList() : [],
      status: map['status'] ?? 'published',
      isDeleted: map['isDeleted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy'],
      uid: map['uid'],
      userName: map['userName'],
      email: map['email'],
      sentAt: (map['sentAt'] as Timestamp?)?.toDate(),
      reviewedAt: (map['reviewedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// ✅ دالة التحويل من DocumentSnapshot - مطابقة لـ QaItem.fromDoc في تطبيق الإدارة
  factory Question.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Question.fromMap(data, doc.id);
  }

  /// هل السؤال محذوف؟ (للفلترة)
  bool get isDeletedOrHidden => isDeleted == true || status == 'deleted';

  @override
  List<Object?> get props => [
    id, question, answer, topicId, subtopicId, topicName, subtopicName,
    tags, status, isDeleted, createdAt, createdBy, uid, userName, email,
    sentAt, reviewedAt, isFavorite,
  ];
}