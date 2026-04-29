# استفتاءات الشيخ السند 📱

تطبيق Flutter شامل لعرض وإدارة استفتاءات الشيخ السند مع ميزات المكتبة والبحث والمفضلة.

## ✨ المميزات

### 📚 المكتبة
- عرض الكتب الدينية المتاحة
- قارئ كتب تفاعلي مع دعم HTML
- التنقل بين الفصول بسهولة
- حفظ آخر صفحة تم قراءتها

### ❓ الاستفتاءات
- تصفح الاستفتاءات حسب الأقسام والمواضيع
- عرض تفاصيل كل استفتاء
- إرسال أسئلة جديدة
- متابعة أسئلتك الشخصية

### ⭐ المفضلة
- حفظ الاستفتاءات المفضلة
- الوصول السريع للمفضلة
- مزامنة محلية

### 🔍 البحث الشامل
- بحث في الاستفتاءات والكتب
- فلترة النتائج (الكل / الاستفتاءات / المكتبة)
- تظليل النتائج المطابقة
- البحث بدون اتصال بالإنترنت

### 👤 المصادقة
- تسجيل الدخول بحساب Firebase
- وضع الضيف للتصفح بدون تسجيل
- إدارة الجلسات

## 🏗️ البنية المعمارية

التطبيق مبني باستخدام **Clean Architecture** مع:

- **Domain Layer**: الكيانات والواجهات
- **Data Layer**: المستودعات ومصادر البيانات
- **Presentation Layer**: الواجهات والمزودات

### التقنيات المستخدمة

- **Flutter** 3.4.0+
- **Riverpod** لإدارة الحالة
- **GoRouter** للتنقل
- **Firebase** (Auth, Firestore, Messaging)
- **SharedPreferences** للتخزين المحلي
- **Clean Architecture** لتنظيم الكود

## 📁 هيكل المشروع

```
lib/
├── core/                    # الملفات الأساسية المشتركة
│   ├── constants/          # الثوابت (ألوان، نصوص، مسارات)
│   ├── router/             # إعدادات التنقل
│   ├── theme/              # الثيمات (فاتح/داكن)
│   ├── utils/              # أدوات مساعدة
│   └── widgets/            # ويدجت مشتركة
├── features/               # الميزات الرئيسية
│   ├── auth/               # المصادقة
│   ├── content/            # الاستفتاءات
│   ├── library/            # المكتبة
│   ├── favorites/          # المفضلة
│   └── inbox/              # صندوق الوارد
├── di/                     # Dependency Injection
└── main.dart               # نقطة البداية
```

## 🚀 البدء

### المتطلبات

- Flutter SDK >= 3.4.0
- Dart SDK >= 3.4.0
- Android Studio / VS Code
- حساب Firebase

### التثبيت

1. استنسخ المشروع:
```bash
git clone <repository-url>
cd istftaatsanad
```

2. ثبت التبعيات:
```bash
flutter pub get
```

3. أضف ملفات Firebase:
   - ضع `google-services.json` في `android/app/`
   - تأكد من إعداد `firebase_options.dart`

4. شغّل التطبيق:
```bash
flutter run
```

## 🔧 الإعدادات

### Firebase Setup

1. أنشئ مشروع Firebase جديد
2. أضف تطبيق Android/iOS
3. حمّل ملفات التكوين
4. فعّل Authentication و Firestore

### Assets

تأكد من وجود الملفات التالية:
- `assets/books/index.json` - فهرس الكتب
- `assets/questions_index.json` - فهرس الاستفتاءات
- `assets/books/book_*/` - ملفات الكتب

## 📱 الميزات القادمة

- [ ] إشعارات Firebase
- [ ] تصدير/استيراد المفضلة
- [ ] وضع القراءة الليلي
- [ ] تحسينات الأداء
- [ ] دعم اللغات الإضافية

## 🤝 المساهمة

نرحب بالمساهمات! يرجى:

1. عمل Fork للمشروع
2. إنشاء فرع للميزة (`git checkout -b feature/AmazingFeature`)
3. عمل Commit للتغييرات (`git commit -m 'Add some AmazingFeature'`)
4. Push للفرع (`git push origin feature/AmazingFeature`)
5. فتح Pull Request

## 📄 الترخيص

هذا المشروع مرخص تحت [MIT License](LICENSE).

## 👨‍💻 المطور

تم تطويره باستخدام Flutter و Clean Architecture.

---

**ملاحظة**: هذا التطبيق مخصص لعرض استفتاءات الشيخ السند. جميع الحقوق محفوظة.
