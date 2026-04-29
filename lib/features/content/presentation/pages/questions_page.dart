import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/text_highlighter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/content_providers.dart';
import '../widgets/qa_tile.dart';
import '../../domain/entities/question.dart';

class QuestionsPage extends ConsumerStatefulWidget {
  final String topicId;
  final String subtopicId;
  final String subtopicName;

  const QuestionsPage({
    super.key,
    required this.topicId,
    required this.subtopicId,
    required this.subtopicName,
  });

  @override
  ConsumerState<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends ConsumerState<QuestionsPage> {
  String _searchScope = 'both';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider).value ?? {};
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ═══ حالة المفضلة ═══
    if (widget.subtopicId == 'fav') {
      return SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: const CustomAppBar(title: 'المفضلة'),
            drawer: const AppDrawer(),
            body: favorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_outline_rounded,
                          size: 56,
                          color: AppColors.gold.withValues(alpha:0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.noFavorites,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ref.watch(favoriteQuestionsProvider(favorites)).when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Text('خطأ في تحميل المفضلة: $e'),
                    ),
                    data: (favQuestions) => ListView.builder(
                      itemCount: favQuestions.length,
                      cacheExtent: 500,
                      itemBuilder: (ctx, i) {
                        final item = favQuestions[i];
                        return QaTile(
                          item: item,
                          isFavorite: true,
                          onTap: () =>
                              _openQuestion(context, item, 'المفضلة'),
                          onToggleFavorite: (val) async {
                            await ref
                                .read(contentRepositoryProvider)
                                .toggleFavorite(item.id, val);
                            ref.invalidate(favoritesProvider);
                          },
                        );
                      },
                    ),
                  ),
          ),
        ),
      );
    }

    // ═══ حالة البحث ═══
    if (widget.subtopicId == 'search') {
      final searchState = ref.watch(universalSearchProvider);
      final searchNotifier =
          ref.read(universalSearchProvider.notifier);
      final searchQuery = _searchCtrl.text.trim();

      return SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: const CustomAppBar(title: 'بحث شامل'),
            drawer: const AppDrawer(),
            body: Column(
              children: [
                // حقل البحث
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: AppColors.gold.withValues(alpha:0.6),
                            ),
                            hintText: AppStrings.searchHint,
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded,
                                        size: 20),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                          ),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              searchNotifier.search(
                                  query: val, scope: _searchScope);
                            }
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            if (_searchCtrl.text.trim().isNotEmpty) {
                              searchNotifier.search(
                                query: _searchCtrl.text,
                                scope: _searchScope,
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Icon(
                              Icons.search_rounded,
                              color: AppColors.primaryDeep,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // فلاتر البحث
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      _buildFilterChip(AppStrings.searchAll, 'both'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          AppStrings.searchQuestions, 'questions'),
                      const SizedBox(width: 8),
                      _buildFilterChip(AppStrings.searchBooks, 'books'),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 1,
                        color: AppColors.gold.withValues(alpha:0.3),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 0.5,
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.divider,
                        ),
                      ),
                    ],
                  ),
                ),

                // النتائج
                Expanded(
                  child: searchState.when(
                    data: (results) {
                      if (results.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 56,
                                  color: AppColors.gold.withValues(alpha:0.3)),
                              const SizedBox(height: 12),
                              Text(
                                AppStrings.noResults,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: results.length,
                        cacheExtent: 1000,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                        itemBuilder: (ctx, i) {
                          final result = results[i];

                          if (result.type == 'question') {
                            final qItem = result.data as Question;
                            return QaTile(
                              item: qItem,
                              isFavorite: favorites.contains(qItem.id),
                              highlightQuery: searchQuery.isNotEmpty
                                  ? searchQuery
                                  : null,
                              onTap: () =>
                                  _openQuestion(context, qItem, 'بحث'),
                              onToggleFavorite: (val) async {
                                await ref
                                    .read(contentRepositoryProvider)
                                    .toggleFavorite(qItem.id, val);
                                ref.invalidate(favoritesProvider);
                              },
                            );
                          } else if (result.type == 'book') {
                            final match = result.data as BookMatch;
                            return _buildBookResult(
                                context, match, searchQuery, isDark);
                          }
                          return const SizedBox.shrink();
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.gold,
                      ),
                    ),
                    error: (e, st) =>
                        Center(child: Text('${AppStrings.errorOccurred}: $e')),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ═══ العرض الاعتيادي ═══
    final questions = ref.watch(
      questionsProvider(
          (topicId: widget.topicId, subtopicId: widget.subtopicId)),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(title: widget.subtopicName),
          drawer: const AppDrawer(),
          body: questions.when(
            data: (items) => items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.quiz_outlined,
                            size: 56,
                            color: AppColors.gold.withValues(alpha:0.4)),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.noQuestionsInSection,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    cacheExtent: 500,
                    itemBuilder: (ctx, i) {
                      return QaTile(
                        item: items[i],
                        isFavorite: favorites.contains(items[i].id),
                        onTap: () => _openQuestion(
                            context, items[i], widget.subtopicName),
                        onToggleFavorite: (val) async {
                          await ref
                              .read(contentRepositoryProvider)
                              .toggleFavorite(items[i].id, val);
                          ref.invalidate(favoritesProvider);
                        },
                      );
                    },
                  ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
            error: (e, st) => Center(child: Text('خطأ: $e')),
          ),
        ),
      ),
    );
  }

  // ─── نتيجة كتاب ───
  Widget _buildBookResult(
    BuildContext context,
    BookMatch match,
    String searchQuery,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha:isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.pushNamed('bookReader', extra: {
              'book': match.book,
              'initialPage': match.pageIndex,
              'highlight': searchQuery,
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextHighlighter(
                        text: match.book.title,
                        query: searchQuery,
                        style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700) ??
                            const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      TextHighlighter(
                        text: "فصل: ${match.chapterTitle}",
                        query: searchQuery,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gold.withValues(alpha:0.7),
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 6),
                      TextHighlighter(
                        text: match.snippet,
                        query: searchQuery,
                        style: Theme.of(context).textTheme.bodyMedium ??
                            const TextStyle(fontSize: 13),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _searchScope == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() => _searchScope = value);
          if (_searchCtrl.text.isNotEmpty) {
            ref.read(universalSearchProvider.notifier).search(
                  query: _searchCtrl.text,
                  scope: value,
                );
          }
        }
      },
      selectedColor: AppColors.gold.withValues(alpha:0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.goldDark : null,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }

  void _openQuestion(
      BuildContext context, Question item, String subName) {
    context.pushNamed(
      'questionDetail',
      queryParameters: {
        'id': item.id,
        'q': item.question,
        'a': item.answer,
        'topicName': item.topicName,
        'subtopicName': subName,
      },
    );
  }
}
