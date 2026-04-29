class Book {
  final String id;
  final String title;
  final String description; // ✅ تمت إضافة الوصف
  final String category;
  final String manifestPath;

  Book({
    required this.id,
    required this.title,
    required this.description, // ✅
    required this.category,
    required this.manifestPath,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '', // ✅ قراءة الوصف من ملف JSON
      category: json['category'] ?? '',
      manifestPath: json['path'] ?? '',
    );
  }
}

/// تمثيل عنوان فرعي (h1, h2, h3) داخل الفصل
class SubHeading {
  final String title;
  final int level; // 1 = h1, 2 = h2, 3 = h3
  final int position; // موقع العنوان في HTML للتمرير إليه

  SubHeading({
    required this.title,
    required this.level,
    this.position = 0,
  });
}

class Chapter {
  final String title;
  final String fileName;
  final List<SubHeading> subHeadings; // العناوين الفرعية المستخرجة من HTML

  Chapter({
    required this.title,
    required this.fileName,
    this.subHeadings = const [],
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      title: json['title'] ?? '',
      fileName: json['file'] ?? '',
    );
  }

  /// إنشاء نسخة مع العناوين الفرعية
  Chapter copyWithSubHeadings(List<SubHeading> headings) {
    return Chapter(
      title: title,
      fileName: fileName,
      subHeadings: headings,
    );
  }
}