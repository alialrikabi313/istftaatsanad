import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/book.dart';
import '../providers/library_providers.dart';

class BookReaderPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> args;
  const BookReaderPage({super.key, required this.args});

  @override
  ConsumerState<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends ConsumerState<BookReaderPage> {
  late PageController _pageController;
  late Book _book;
  int _currentPage = 0;
  String? _highlightQuery;
  bool _showControls = true;
  String? _scrollToHeadingTitle;
  final Map<int, GlobalKey<_ChapterViewState>> _chapterKeys = {};

  @override
  void initState() {
    super.initState();
    _book = widget.args['book'] as Book;
    final initialPage = widget.args['initialPage'] as int? ?? 0;
    _currentPage = initialPage;
    _pageController = PageController(initialPage: initialPage);
    _highlightQuery = widget.args['highlight'] as String?;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String get _bookDir =>
      _book.manifestPath.replaceAll('/manifest.json', '');

  void _navigateToHeading(int chapterIndex, String headingTitle) {
    Navigator.pop(context);
    _pageController.jumpToPage(chapterIndex);
    setState(() => _scrollToHeadingTitle = headingTitle);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _chapterKeys[chapterIndex];
      if (key?.currentState != null) {
        key!.currentState!.scrollToHeading(headingTitle);
      }
      setState(() => _scrollToHeadingTitle = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync =
        ref.watch(bookDetailsProvider(_book.manifestPath));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark
              ? AppColors.scaffoldBackgroundDark
              : Theme.of(context).scaffoldBackgroundColor,

          // الفهرس الجانبي
          endDrawer: chaptersAsync.when(
            data: (chapters) => _buildTableOfContents(chapters, isDark),
            loading: () => const Drawer(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            ),
            error: (e, _) =>
                Drawer(child: Center(child: Text('خطأ: $e'))),
          ),

          body: Stack(
            children: [
              // المحتوى
              GestureDetector(
                onTap: () =>
                    setState(() => _showControls = !_showControls),
                child: chaptersAsync.when(
                  data: (chapters) => PageView.builder(
                    controller: _pageController,
                    itemCount: chapters.length,
                    onPageChanged: (i) =>
                        setState(() => _currentPage = i),
                    itemBuilder: (ctx, index) {
                      _chapterKeys[index] ??=
                          GlobalKey<_ChapterViewState>();
                      return _ChapterView(
                        key: _chapterKeys[index],
                        bookDir: _bookDir,
                        fileName: chapters[index].fileName,
                        highlightQuery: _highlightQuery,
                        initialScrollToHeading: index == _currentPage
                            ? _scrollToHeadingTitle
                            : null,
                        isDark: isDark,
                      );
                    },
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.gold),
                  ),
                  error: (e, _) =>
                      Center(child: Text('خطأ: $e')),
                ),
              ),

              // الشريط العلوي
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: _showControls ? 0 : -80,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        AppColors.primaryDeep.withValues(alpha:0.95),
                        AppColors.primary.withValues(alpha:0.95),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDeep.withValues(alpha:0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AppBar(
                    title: Text(
                      _book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    actions: [
                      Builder(builder: (context) {
                        return IconButton(
                          icon: const Icon(Icons.toc_rounded),
                          onPressed: () =>
                              Scaffold.of(context).openEndDrawer(),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // الشريط السفلي
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: _showControls ? 0 : -100,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardBackgroundDark.withValues(alpha:0.95)
                        : Colors.white.withValues(alpha:0.95),
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.border,
                        width: 0.5,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 20),
                  child: chaptersAsync.hasValue
                      ? Row(
                          children: [
                            Text("1",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall),
                            Expanded(
                              child: SliderTheme(
                                data:
                                    SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppColors.gold,
                                  inactiveTrackColor:
                                      AppColors.gold.withValues(alpha:0.2),
                                  thumbColor: AppColors.gold,
                                  overlayColor:
                                      AppColors.gold.withValues(alpha:0.1),
                                  trackHeight: 3,
                                ),
                                child: Slider(
                                  value: _currentPage.toDouble(),
                                  min: 0,
                                  max: (chaptersAsync.value!.length -
                                          1)
                                      .toDouble(),
                                  divisions:
                                      chaptersAsync.value!.length > 1
                                          ? chaptersAsync
                                                  .value!.length -
                                              1
                                          : 1,
                                  label: "فصل ${_currentPage + 1}",
                                  onChanged: (val) {
                                    _pageController
                                        .jumpToPage(val.toInt());
                                  },
                                ),
                              ),
                            ),
                            Text("${chaptersAsync.value!.length}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── بناء فهرس الكتاب ───
  Widget _buildTableOfContents(List<dynamic> chapters, bool isDark) {
    return Drawer(
      backgroundColor: isDark
          ? AppColors.scaffoldBackgroundDark
          : Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // هيدر الفهرس
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              right: 20,
              left: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: AppColors.headerGradient,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _book.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 30,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),

          // قائمة الفصول
          Expanded(
            child: ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (ctx, i) {
                final chapter = chapters[i];
                final hasSubHeadings =
                    chapter.subHeadings.isNotEmpty;
                final isActive = i == _currentPage;

                if (hasSubHeadings) {
                  return ExpansionTile(
                    leading: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.gold
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "${i + 1}",
                          style: TextStyle(
                            color: isActive
                                ? AppColors.primaryDeep
                                : (isDark
                                    ? Colors.white60
                                    : AppColors.textSecondary),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      chapter.title,
                      style: TextStyle(
                        color: isActive
                            ? AppColors.gold
                            : null,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    backgroundColor: isActive
                        ? AppColors.gold.withValues(alpha:0.05)
                        : null,
                    collapsedBackgroundColor: isActive
                        ? AppColors.gold.withValues(alpha:0.05)
                        : null,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _pageController.jumpToPage(i);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 48, vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow_rounded,
                                  size: 16,
                                  color: AppColors.gold
                                      .withValues(alpha:0.6)),
                              const SizedBox(width: 8),
                              Text(
                                'بداية الفصل',
                                style: TextStyle(
                                  color: AppColors.gold
                                      .withValues(alpha:0.7),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        indent: 48,
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.divider,
                      ),
                      ...chapter.subHeadings.map((heading) {
                        final double indent = heading.level == 1
                            ? 32.0
                            : heading.level == 2
                                ? 48.0
                                : 64.0;

                        return InkWell(
                          onTap: () =>
                              _navigateToHeading(i, heading.title),
                          child: Container(
                            padding: EdgeInsets.only(
                              right: indent,
                              left: 16,
                              top: 8,
                              bottom: 8,
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  heading.level == 1
                                      ? Icons.circle
                                      : Icons.remove,
                                  size: heading.level == 1 ? 6 : 12,
                                  color: AppColors.gold
                                      .withValues(alpha:0.5),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    heading.title,
                                    style: TextStyle(
                                      fontSize: heading.level == 1
                                          ? 13.0
                                          : 12.0,
                                      fontWeight:
                                          heading.level == 1
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                } else {
                  return ListTile(
                    title: Text(
                      chapter.title,
                      style: TextStyle(
                        color: isActive ? AppColors.gold : null,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    leading: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.gold
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "${i + 1}",
                          style: TextStyle(
                            color: isActive
                                ? AppColors.primaryDeep
                                : (isDark
                                    ? Colors.white60
                                    : AppColors.textSecondary),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    selected: isActive,
                    selectedTileColor:
                        AppColors.gold.withValues(alpha:0.05),
                    onTap: () {
                      Navigator.pop(context);
                      _pageController.jumpToPage(i);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ويدجت عرض الفصل ───
class _ChapterView extends ConsumerStatefulWidget {
  final String bookDir;
  final String fileName;
  final String? highlightQuery;
  final String? initialScrollToHeading;
  final bool isDark;

  const _ChapterView({
    super.key,
    required this.bookDir,
    required this.fileName,
    this.highlightQuery,
    this.initialScrollToHeading,
    this.isDark = false,
  });

  @override
  ConsumerState<_ChapterView> createState() => _ChapterViewState();
}

class _ChapterViewState extends ConsumerState<_ChapterView> {
  final ScrollController _scrollController = ScrollController();
  String? _currentHtml;
  final Map<String, double> _headingPositions = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _calculateHeadingPositions(String html) {
    _headingPositions.clear();
    final RegExp headingPattern = RegExp(
      r'<h([1-3])[^>]*>(.*?)</h\1>',
      caseSensitive: false,
      dotAll: true,
    );
    for (final match in headingPattern.allMatches(html)) {
      String title = match.group(2)!;
      title = title.replaceAll(RegExp(r'<[^>]*>'), '').trim();
      if (title.isNotEmpty) {
        final position = match.start / html.length;
        _headingPositions[title] = position;
      }
    }
  }

  void scrollToHeading(String headingTitle) {
    if (!_scrollController.hasClients) return;
    final position = _headingPositions[headingTitle];
    if (position != null) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final targetPosition =
          (position * maxScroll).clamp(0.0, maxScroll);
      _scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(chapterContentProvider(
        (bookDir: widget.bookDir, fileName: widget.fileName)));

    return contentAsync.when(
      data: (html) {
        String finalHtml = html;

        if (_currentHtml != html) {
          _currentHtml = html;
          _calculateHeadingPositions(html);
          if (widget.initialScrollToHeading != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollToHeading(widget.initialScrollToHeading!);
            });
          }
        }

        if (widget.highlightQuery != null &&
            widget.highlightQuery!.trim().isNotEmpty) {
          final q = widget.highlightQuery!.trim();
          final pattern = RegExp(RegExp.escape(q), caseSensitive: false);
          finalHtml = finalHtml.replaceAllMapped(pattern, (match) =>
              '<mark style="background-color: #F0DCA4; color: #0D1B2A; padding: 2px 4px;">${match.group(0)}</mark>');
        }

        return SelectionArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(
                top: 80, bottom: 80, left: 18, right: 18),
            child: HtmlWidget(
              finalHtml,
              textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.9,
                    fontFamily: 'Tahoma',
                    color: widget.isDark ? Colors.white : AppColors.textPrimary,
                  ) ??
                  TextStyle(
                    fontSize: 18,
                    height: 1.9,
                    fontFamily: 'Tahoma',
                    color: widget.isDark ? Colors.white : AppColors.textPrimary,
                  ),
              customStylesBuilder: (e) {
                if (e.localName == 'h1') {
                  return {
                    'color': widget.isDark ? '#F0DCA4' : '#0D1B2A',
                    'text-align': 'center',
                    'font-weight': 'bold',
                    'font-size': '24px',
                    'margin-bottom': '24px',
                  };
                }
                if (e.localName == 'h2') {
                  return {
                    'color': widget.isDark ? '#D4A843' : '#1B3A5C',
                    'text-align': 'center',
                    'margin-bottom': '20px',
                  };
                }
                if (e.localName == 'h3') {
                  return {
                    'color': widget.isDark ? '#E8C56B' : '#2E5984',
                    'font-weight': 'bold',
                    'margin-top': '20px',
                    'font-size': '20px',
                  };
                }
                if (e.localName == 'mark') {
                  return {
                    'background-color': '#F0DCA4',
                    'color': '#0D1B2A',
                  };
                }
                return null;
              },
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
      error: (e, _) => Center(child: Text('تعذر تحميل الفصل: $e')),
    );
  }
}
