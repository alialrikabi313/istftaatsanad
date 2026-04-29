/// ثوابت مسارات التطبيق
class AppRoutes {
  AppRoutes._();

  // المسارات الرئيسية
  static const String signIn = '/signin';
  static const String home = '/';

  // مسارات الاستفتاءات
  static const String subtopics = 'subtopics';
  static const String questions = 'questions';
  static const String questionDetail = 'question';
  static const String myQuestions = 'my-questions';

  // مسارات المكتبة
  static const String bookReader = 'reader';

  // أسماء المسارات (للتنقل باستخدام goNamed)
  static const String signInName = 'signin';
  static const String homeName = 'home';
  static const String subtopicsName = 'subtopics';
  static const String questionsName = 'questions';
  static const String questionDetailName = 'questionDetail';
  static const String myQuestionsName = 'myQuestions';
  static const String bookReaderName = 'bookReader';
}

