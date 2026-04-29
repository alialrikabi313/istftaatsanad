import 'package:equatable/equatable.dart';

class Subtopic extends Equatable {
  final String id;
  final String topicId;
  final String name;
  final int order;

  const Subtopic({
    required this.id,
    required this.topicId,
    required this.name,
    required this.order,
  });

  // ✅ هذه الدالة ضرورية جداً وهي سبب الخطأ لديك
  factory Subtopic.fromMap(Map<String, dynamic> map, String documentId) {
    return Subtopic(
      id: map['id'] ?? documentId,
      topicId: map['topicId'] ?? '',
      name: map['name'] ?? '',
      order: (map['order'] ?? 0).toInt(),
    );
  }

  @override
  List<Object?> get props => [id, topicId, name, order];
}