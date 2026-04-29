import 'package:fpdart/fpdart.dart';
import '../entities/topic.dart';
import '../entities/subtopic.dart';
import '../entities/qa_item.dart';


abstract class ContentRepository {
  Stream<List<Topic>> watchTopics();
  Stream<List<Subtopic>> watchSubtopics(String topicId);
  Stream<List<QaItem>> watchQuestions(String topicId, String subtopicId);
  Future<Either<String, List<QaItem>>> search(String query); // across all
  Future<void> toggleFavorite(String qaId, bool value);
  Stream<Set<String>> watchFavorites();
}