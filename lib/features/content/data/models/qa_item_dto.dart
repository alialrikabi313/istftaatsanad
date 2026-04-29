import '../../domain/entities/qa_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class QaItemDto {
  final String id;
  final String topicId;
  final String subtopicId;
  final String question;
  final String answer;
  final DateTime createdAt;
  final List<String> tags;
  QaItemDto({
    required this.id,
    required this.topicId,
    required this.subtopicId,
    required this.question,
    required this.answer,
    required this.createdAt,
    required this.tags,
  });


  factory QaItemDto.fromMap(String id, String topicId, String subtopicId, Map<String, dynamic> m) => QaItemDto(
    id: id,
    topicId: topicId,
    subtopicId: subtopicId,
    question: m['question'] as String,
    answer: m['answer'] as String,
    createdAt: (m['createdAt'] as Timestamp).toDate(),
    tags: (m['tags'] as List?)?.cast<String>() ?? const [],
  );
  QaItem toEntity() => QaItem(id: id, topicId: topicId, subtopicId: subtopicId, question: question, answer: answer, createdAt: createdAt, tags: tags);
}