import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/question_inbox_repository.dart';
import '../datasources/firestore_inbox_remote.dart';

class QuestionInboxRepositoryImpl implements QuestionInboxRepository {
  final FirestoreInboxRemote remote;
  QuestionInboxRepositoryImpl(this.remote);

  @override
  Future<Either<String, Unit>> sendQuestion({
    required String uid,
    required String email,
    required String name,
    required String text,
  }) async {
    try {
      await remote.send(uid, email, name, text);
      return const Right(unit);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
