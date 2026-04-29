import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// استيراد الكيانات
import '../../../library/domain/entities/book.dart';
import '../../domain/entities/topic.dart';
import '../../domain/entities/subtopic.dart';
import '../../domain/entities/question.dart';
import '../../data/repositories/content_repository_impl.dart';
import '../../../../main.dart';

/// Provider لمستودع المحتوى
final contentRepositoryProvider = Provider<ContentRepositoryImpl>((ref) {
  final db = FirebaseFirestore.instance;
  final prefs = ref.watch(sharedPrefsProvider);
  return ContentRepositoryImpl(db, prefs);
});

// =========================================================
// 1. جلب الأقسام الرئيسية (Topics)
// =========================================================
final topicsProvider = StreamProvider.autoDispose<List<Topic>>((ref) {
  return FirebaseFirestore.instance
      .collection('topics')
      .orderBy('order')
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Topic.fromMap(doc.data(), doc.id))
      .toList());
});

// =========================================================
// 2. جلب الأقسام الفرعية (Subtopics)
// =========================================================
final subtopicsProvider = StreamProvider.autoDispose.family<List<Subtopic>, String>((ref, topicId) {
  return FirebaseFirestore.instance
      .collection('subtopics')
      .where('topicId', isEqualTo: topicId)
      .orderBy('order')
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => Subtopic.fromMap(doc.data(), doc.id))
        .toList());
});

// =========================================================
// 3. جلب الأسئلة (Questions) - للتصفح العادي
// =========================================================
final questionsProvider = StreamProvider.autoDispose.family<List<Question>,
    ({String topicId, String subtopicId})>((ref, args) {

  if (args.subtopicId == 'fav') return const Stream.empty();
  if (args.subtopicId == 'search') return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('questions')
      .where('subtopicId', isEqualTo: args.subtopicId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['isDeleted'] != true && data['status'] != 'deleted';
          })
          .map((doc) => Question.fromMap(doc.data(), doc.id))
          .toList();
      });
});

// =========================================================
// 4. إدارة المفضلة
// =========================================================
final favoritesProvider =
StateNotifierProvider<FavoritesNotifier, AsyncValue<Set<String>>>((ref) {
  final repo = ref.watch(contentRepositoryProvider);
  return FavoritesNotifier(repo)..load();
});

class FavoritesNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  final ContentRepositoryImpl _repo;
  FavoritesNotifier(this._repo) : super(const AsyncLoading());

  Future<void> load() async {
    state = const AsyncLoading();
    final favs = await _repo.loadFavorites();
    state = AsyncData(favs);
  }

  Future<void> toggle(String id, bool val) async {
    final current = {...(state.value ?? {})};
    if (val) {
      current.add(id);
    } else {
      current.remove(id);
    }
    state = AsyncData(current);
    await _repo.saveFavorites(current);
  }
}

// =========================================================
// 5. جلب أسئلة المفضلة (Batch)
// =========================================================
final favoriteQuestionsProvider =
FutureProvider.autoDispose.family<List<Question>, Set<String>>((ref, ids) async {
  if (ids.isEmpty) return [];
  final db = FirebaseFirestore.instance;
  final List<Question> results = [];

  // Firestore whereIn supports max 30 items per query
  final idList = ids.toList();
  for (var i = 0; i < idList.length; i += 30) {
    final batch = idList.sublist(i, (i + 30).clamp(0, idList.length));
    final snapshot = await db
        .collection('questions')
        .where(FieldPath.documentId, whereIn: batch)
        .get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['isDeleted'] != true && data['status'] != 'deleted') {
        results.add(Question.fromMap(data, doc.id));
      }
    }
  }
  return results;
});

// =========================================================
// 6. أسئلتي
// =========================================================
final myQuestionsProvider =
StreamProvider.autoDispose.family<List<Question>, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('questions')
      .where('uid', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['isDeleted'] != true && data['status'] != 'deleted';
          })
          .map((doc) => Question.fromMap(doc.data(), doc.id))
          .toList();
      });
});

// =========================================================
// 7. الاستفتاءات الحديثة (آخر 48 ساعة)
// =========================================================
final newQuestionsProvider = StreamProvider.autoDispose<List<Question>>((ref) {
  final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 48));

  return FirebaseFirestore.instance
      .collection('questions')
      .where('createdAt', isGreaterThan: Timestamp.fromDate(twentyFourHoursAgo))
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['isDeleted'] != true && data['status'] != 'deleted';
          })
          .map((doc) => Question.fromMap(doc.data(), doc.id))
          .toList();
      });
});

// =========================================================
// 8. البحث الشامل (Smart Offline Index + Sync + Books)
// =========================================================

class SearchResult {
  final String type; // 'question' or 'book'
  final dynamic data;
  SearchResult({required this.type, required this.data});
}

class BookMatch {
  final Book book;
  final String chapterTitle;
  final String snippet;
  final int pageIndex;

  BookMatch({
    required this.book,
    required this.chapterTitle,
    required this.snippet,
    required this.pageIndex,
  });
}

final universalSearchProvider =
StateNotifierProvider<UniversalSearchNotifier, AsyncValue<List<SearchResult>>>((ref) {
  return UniversalSearchNotifier();
});

class UniversalSearchNotifier extends StateNotifier<AsyncValue<List<SearchResult>>> {
  UniversalSearchNotifier() : super(const AsyncData([]));

  Map<String, Question>? _questionsMapCache;
  Completer<void>? _fetchCompleter;
  Timer? _debounceTimer;

  List<Book>? _cachedBooks;
  Map<String, List<dynamic>>? _cachedChapters;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _prepareSearchIndex() async {
    if (_questionsMapCache != null) return;

    try {
      final jsonString = await rootBundle.loadString('assets/questions_index.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final String lastUpdatedStr = jsonData['lastUpdated'] ?? DateTime(2000).toIso8601String();
      final DateTime lastIndexDate = DateTime.parse(lastUpdatedStr);
      final List<dynamic> list = jsonData['data'];

      _questionsMapCache = {
        for (var item in list)
          item['id']: Question(
            id: item['id'],
            question: item['q'],
            answer: item['a'],
            topicName: item['t'] ?? '',
            subtopicName: item['s'] ?? '',
            topicId: '', subtopicId: '', isFavorite: false,
          )
      };

      if (_fetchCompleter == null || _fetchCompleter!.isCompleted) {
        _fetchCompleter = Completer<void>();
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('questions')
              .where('createdAt', isGreaterThan: Timestamp.fromDate(lastIndexDate))
              .get();

          if (snapshot.docs.isNotEmpty) {
            for (var doc in snapshot.docs) {
              final data = doc.data();
              final qId = doc.id;
              bool isDeleted = data['isDeleted'] == true || data['status'] == 'deleted';

              if (isDeleted) {
                _questionsMapCache!.remove(qId);
              } else {
                _questionsMapCache![qId] = Question.fromMap(data, qId);
              }
            }
          }
        } catch (e) {
          debugPrint('Search index sync error: $e');
        } finally {
          _fetchCompleter!.complete();
        }
      } else {
        await _fetchCompleter!.future;
      }
    } catch (e) {
      _questionsMapCache = {};
    }
  }

  Future<void> _preloadBooksIndex() async {
    if (_cachedBooks != null) return;
    try {
      final indexJson = await rootBundle.loadString('assets/books/index.json');
      final List<dynamic> booksList = json.decode(indexJson);
      _cachedBooks = booksList.map((b) => Book.fromJson(b)).toList();
      _cachedChapters = {};
    } catch (e) {
      debugPrint('Books index load error: $e');
      _cachedBooks = [];
    }
  }

  void searchDebounced({required String query, required String scope}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      search(query: query, scope: scope);
    });
  }

  Future<void> search({required String query, required String scope}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();

    try {
      List<SearchResult> allResults = [];

      if (scope == 'questions' || scope == 'both') {
        await _prepareSearchIndex();

        if (_questionsMapCache != null) {
          final qResults = _questionsMapCache!.values.where((item) {
            final qText = item.question.toLowerCase();
            final aText = item.answer.toLowerCase();
            return qText.contains(q) || aText.contains(q);
          })
              .take(40)
              .map((item) => SearchResult(type: 'question', data: item))
              .toList();

          allResults.addAll(qResults);

          if (allResults.isNotEmpty && scope == 'both') {
            state = AsyncData(List.from(allResults));
          }
        }
      }

      if (scope == 'books' || scope == 'both') {
        await _preloadBooksIndex();

        if (_cachedBooks != null) {
          final bookSearchFutures = _cachedBooks!.map((book) async {
            try {
              return await _searchInBook(book, q, query);
            } catch (e) {
              return <SearchResult>[];
            }
          }).toList();

          final bookResults = await Future.wait(bookSearchFutures);
          for (var results in bookResults) {
            allResults.addAll(results);
          }
        }
      }

      state = AsyncData(allResults);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<List<SearchResult>> _searchInBook(Book book, String q, String originalQuery) async {
    List<SearchResult> results = [];
    try {
      List<dynamic> chapters;
      if (_cachedChapters != null && _cachedChapters!.containsKey(book.manifestPath)) {
        chapters = _cachedChapters![book.manifestPath]!;
      } else {
        final manifestJson = await rootBundle.loadString(book.manifestPath);
        final manifestMap = json.decode(manifestJson);
        chapters = manifestMap['chapters'];
        _cachedChapters?[book.manifestPath] = chapters;
      }

      final bookDir = book.manifestPath.replaceAll('/manifest.json', '');
      final maxChapters = chapters.length > 20 ? 20 : chapters.length;

      for (int i = 0; i < maxChapters; i++) {
        final chapterFileName = chapters[i]['file'];
        final chapterTitle = chapters[i]['title'];
        final htmlContent = await rootBundle.loadString('$bookDir/$chapterFileName');
        final plainText = _stripHtml(htmlContent).toLowerCase();

        if (plainText.contains(q)) {
          final originalPlainText = _stripHtml(htmlContent);
          final snippet = _getSnippet(originalPlainText, originalQuery);

          results.add(SearchResult(
            type: 'book',
            data: BookMatch(
                book: book,
                chapterTitle: chapterTitle,
                snippet: snippet,
                pageIndex: i
            ),
          ));
          break;
        }
      }
    } catch (e) {
      debugPrint('Book search error: $e');
    }
    return results;
  }

  String _stripHtml(String html) => html.replaceAll(RegExp(r'<[^>]*>'), ' ');

  String _getSnippet(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);
    if (index == -1) return text.substring(0, text.length > 80 ? 80 : text.length);
    final start = (index - 40).clamp(0, text.length);
    final end = (index + query.length + 40).clamp(0, text.length);
    return "...${text.substring(start, end).trim()}...";
  }
}
