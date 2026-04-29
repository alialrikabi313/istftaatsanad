import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/firestore_inbox_remote.dart';
import '../../data/repositories/question_inbox_repository_impl.dart';
import '../../domain/repositories/question_inbox_repository.dart';

final inboxRemoteProvider =
Provider<FirestoreInboxRemote>((ref) => FirestoreInboxRemote(FirebaseFirestore.instance));

final inboxRepositoryProvider = Provider<QuestionInboxRepository>(
        (ref) => QuestionInboxRepositoryImpl(ref.watch(inboxRemoteProvider)));

final askQuestionControllerProvider =
StateNotifierProvider<AskQuestionController, AsyncValue<void>>(
        (ref) => AskQuestionController(ref.watch(inboxRepositoryProvider)));

class AskQuestionController extends StateNotifier<AsyncValue<void>> {
  final QuestionInboxRepository _repo;
  AskQuestionController(this._repo) : super(const AsyncData(null));

  Future<void> send({
    required String uid,
    required String email,
    required String name,
    required String text,
  }) async {
    state = const AsyncLoading();
    final res =
    await _repo.sendQuestion(uid: uid, email: email, name: name, text: text);
    state = res.match(
            (l) => AsyncError(l, StackTrace.current), (_) => const AsyncData(null));
  }
}
