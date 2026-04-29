import '../../domain/entities/topic.dart';

class TopicDto {
  final String id;
  final String name;
  final String icon; // ✅ تمت الإضافة
  final int order;

  TopicDto({
    required this.id,
    required this.name,
    required this.icon,
    required this.order,
  });

  // ✅ التعديل لقراءة البيانات بشكل صحيح
  factory TopicDto.fromMap(String id, Map<String, dynamic> m) => TopicDto(
    id: id,
    name: m['name'] ?? '',
    icon: m['icon'] ?? '', // ✅
    order: (m['order'] ?? 0).toInt(),
  );

  // ✅ تمرير الأيقونة للكيان الأصلي
  Topic toEntity() => Topic(
    id: id,
    name: name,
    icon: icon,
    order: order,
    isVisible: true, // قيمة افتراضية
  );
}