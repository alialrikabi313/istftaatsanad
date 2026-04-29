/// ثوابت عامة للتطبيق
class AppConstants {
  AppConstants._();

  // إعدادات البحث
  static const int maxSearchResults = 50;
  static const int snippetLength = 90;

  // إعدادات العرض
  static const double defaultPadding = 12.0;
  static const double defaultBorderRadius = 16.0;
  static const double cardElevation = 2.0;

  // إعدادات المفضلة
  static const String favoritesKey = 'favorites';

  // إعدادات المستخدم الضيف
  static const String isGuestKey = 'isGuest';
  static const String uidKey = 'uid';
  static const String emailKey = 'email';
  static const String nameKey = 'name';

  // إعدادات Firebase
  static const String usersCollection = 'users';
  static const String topicsCollection = 'topics';
  static const String subtopicsCollection = 'subtopics';
  static const String questionsCollection = 'questions';

  // مسارات Assets
  static const String questionsIndexPath = 'assets/questions_index.json';
  static const String booksIndexPath = 'assets/books/index.json';
}

