import '../../domain/entities/subtopic.dart';


class SubtopicDto {
  final String id;
  final String topicId;
  final String name;
  final int order;
  SubtopicDto({required this.id, required this.topicId, required this.name, required this.order});
  factory SubtopicDto.fromMap(String id, String topicId, Map<String, dynamic> m) => SubtopicDto(id: id, topicId: topicId, name: m['name'] as String, order: (m['order'] ?? 0) as int);
  Subtopic toEntity() => Subtopic(id: id, topicId: topicId, name: name, order: order);
}