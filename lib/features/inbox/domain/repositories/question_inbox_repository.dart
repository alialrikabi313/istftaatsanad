import 'package:fpdart/fpdart.dart';

abstract class QuestionInboxRepository {
  Future<Either<String, Unit>> sendQuestion({
    required String uid,
    required String email,
    required String name,
    required String text,
  });
}
