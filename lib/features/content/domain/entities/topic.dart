import 'package:equatable/equatable.dart';

class Topic extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int order;
  final bool isVisible;

  const Topic({
    required this.id,
    required this.name,
    required this.icon,
    required this.order,
    this.isVisible = true,
  });

  factory Topic.fromMap(Map<String, dynamic> map, String documentId) {
    return Topic(
      id: map['id'] ?? documentId,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      order: (map['order'] ?? 0).toInt(),
      isVisible: map['isVisible'] ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, order, isVisible];
}