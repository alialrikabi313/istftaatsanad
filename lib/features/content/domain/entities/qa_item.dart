import 'package:equatable/equatable.dart';


class QaItem extends Equatable {
  final String id;
  final String topicId;
  final String subtopicId;
  final String question;
  final String answer;
  final DateTime createdAt;
  final List<String> tags;


  const QaItem({
    required this.id,
    required this.topicId,
    required this.subtopicId,
    required this.question,
    required this.answer,
    required this.createdAt,
    this.tags = const [],
  });


  @override
  List<Object?> get props => [id, topicId, subtopicId, question, answer, createdAt, tags];
}