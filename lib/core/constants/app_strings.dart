/// ثوابت النصوص المستخدمة في التطبيق
class AppStrings {
  AppStrings._();

  // العناوين الرئيسية
  static const String appTitle = 'استفتاءات الشيخ السند';
  static const String library = 'المكتبة';
  static const String questions = 'الاستفتاءات';
  static const String favorites = 'المفضلة';
  static const String search = 'بحث';
  static const String myQuestions = 'أسئلتي';
  static const String newQuestions = 'الاستفتاءات الحديثة';
  static const String allTopics = 'أقسام الاستفتاءات';

  // رسائل
  static const String loading = 'جاري التحميل...';
  static const String noData = 'لا توجد بيانات';
  static const String noFavorites = 'لا عناصر مفضلة';
  static const String noResults = 'لا توجد نتائج، جرب كلمة أخرى';
  static const String errorOccurred = 'حدث خطأ';
  static const String tryAgain = 'حاول مرة أخرى';
  static const String noNewQuestions = 'لا توجد استفتاءات جديدة';
  static const String noTopics = 'لا توجد أقسام بعد';
  static const String noQuestionsInSection = 'لا توجد أسئلة في هذا القسم';
  static const String noMatchingResults = 'لا توجد نتائج مطابقة';

  // أزرار
  static const String sendQuestion = 'إرسال سؤال';
  static const String signOut = 'تسجيل الخروج';
  static const String confirmSignOut = 'تأكيد الخروج';
  static const String cancel = 'إلغاء';
  static const String share = 'مشاركة';
  static const String copy = 'نسخ';
  static const String save = 'حفظ';
  static const String readMore = 'اقرأ المزيد';
  static const String viewAll = 'عرض الكل';

  // حقول النماذج
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة المرور';
  static const String name = 'الاسم';
  static const String searchHint = 'ابحث في الاستفتاءات أو الكتب...';

  // فلاتر البحث
  static const String searchAll = 'الكل';
  static const String searchQuestions = 'الاستفتاءات';
  static const String searchBooks = 'المكتبة';

  // رسائل النجاح
  static const String copied = 'تم النسخ بنجاح';
  static const String questionSent = 'تم إرسال السؤال بنجاح';
  static const String favoriteAdded = 'تمت الإضافة للمفضلة';
  static const String favoriteRemoved = 'تم الحذف من المفضلة';

  // رسائل الأخطاء
  static const String errorLoading = 'حدث خطأ أثناء التحميل';
  static const String errorSending = 'حدث خطأ أثناء الإرسال';
  static const String networkError = 'خطأ في الاتصال بالإنترنت';

  // صفحة التفاصيل
  static const String questionDetail = 'تفاصيل الاستفتاء';
  static const String theQuestion = 'السؤال';
  static const String theAnswer = 'الجواب';
  static const String notAnsweredYet = 'لم تتم الإجابة بعد';
  static const String copiedQA = 'تم نسخ السؤال والجواب';

  // صفحة تسجيل الدخول
  static const String login = 'تسجيل الدخول';
  static const String createAccount = 'إنشاء حساب جديد';
  static const String guestLogin = 'الدخول كضيف';
  static const String skipRegistration = 'تخطي التسجيل';

  // الإعدادات
  static const String settings = 'الإعدادات';
  static const String appearance = 'المظهر';
  static const String fontSize = 'حجم الخط';
  static const String themeAuto = 'تلقائي (حسب النظام)';
  static const String themeLight = 'نهاري';
  static const String themeDark = 'ليلي';

  // حول التطبيق
  static const String about = 'حول التطبيق';
  static const String shareApp = 'مشاركة التطبيق';

  // التوقيت
  static const String newBadge = 'جديد';
  static const String last48Hours = 'آخر 48 ساعة';
}
