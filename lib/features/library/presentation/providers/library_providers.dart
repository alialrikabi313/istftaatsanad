import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/book.dart';

// 1. قائمة الكتب الرئيسية
final booksListProvider = FutureProvider<List<Book>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/books/index.json');
  final List<dynamic> list = json.decode(jsonString);
  return list.map((e) => Book.fromJson(e)).toList();
});

/// استخراج العناوين الفرعية (h1, h2, h3) من محتوى HTML
List<SubHeading> _extractHeadingsFromHtml(String html) {
  final List<SubHeading> headings = [];
  
  // استخدام RegExp لاستخراج العناوين h1, h2, h3
  final RegExp headingPattern = RegExp(
    r'<h([1-3])[^>]*>(.*?)</h\1>',
    caseSensitive: false,
    dotAll: true,
  );
  
  int position = 0;
  for (final match in headingPattern.allMatches(html)) {
    final level = int.parse(match.group(1)!);
    String title = match.group(2)!;
    
    // تنظيف العنوان من HTML tags
    title = title.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    
    // تجاهل العناوين الفارغة
    if (title.isNotEmpty) {
      headings.add(SubHeading(
        title: title,
        level: level,
        position: position,
      ));
      position++;
    }
  }
  
  return headings;
}

// 2. تفاصيل الكتاب (الفصول) مع استخراج العناوين الفرعية
// نمرر مسار الـ manifest ونحصل على قائمة الفصول مع عناوينها الفرعية
final bookDetailsProvider = FutureProvider.family<List<Chapter>, String>((ref, manifestPath) async {
  final jsonString = await rootBundle.loadString(manifestPath);
  final Map<String, dynamic> data = json.decode(jsonString);
  final List<dynamic> chaptersJson = data['chapters'];
  final chapters = chaptersJson.map((e) => Chapter.fromJson(e)).toList();
  
  // استخراج مسار مجلد الكتاب
  final bookDir = manifestPath.replaceAll('/manifest.json', '');
  
  // استخراج العناوين الفرعية لكل فصل
  final List<Chapter> chaptersWithHeadings = [];
  for (final chapter in chapters) {
    try {
      final htmlPath = '$bookDir/${chapter.fileName}';
      final html = await rootBundle.loadString(htmlPath);
      final headings = _extractHeadingsFromHtml(html);
      chaptersWithHeadings.add(chapter.copyWithSubHeadings(headings));
    } catch (e) {
      // في حالة خطأ، نضيف الفصل بدون عناوين فرعية
      chaptersWithHeadings.add(chapter);
    }
  }
  
  return chaptersWithHeadings;
});

// 3. محتوى الفصل (HTML)
// نمرر (مسار مجلد الكتاب، اسم ملف الفصل)
final chapterContentProvider = FutureProvider.family<String, ({String bookDir, String fileName})>((ref, params) async {
  final fullPath = '${params.bookDir}/${params.fileName}';
  return await rootBundle.loadString(fullPath);
});