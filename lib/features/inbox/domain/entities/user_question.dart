import 'package:equatable/equatable.dart';


class UserQuestion extends Equatable {
  final String id;
  final String uid;
  final String email;
  final String text;
  final DateTime sentAt;
  const UserQuestion({required this.id, required this.uid, required this.email, required this.text, required this.sentAt});
  @override
  List<Object?> get props => [id, uid, email, text, sentAt];
}