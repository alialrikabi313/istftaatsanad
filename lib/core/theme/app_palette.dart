import 'package:flutter/material.dart';

/// لوحة ألوان كاملة للتطبيق. تتحكّم بالألوان الأساسية (primary)
/// والتدرّج المستخدم في الهيدرات والخلفيات والبطاقات.
/// الذهبي يبقى ثابتاً كهوية للعلامة.
class AppPalette {
  final String id;
  final String nameAr;

  // الأساسيات (primary trio)
  final Color primaryDeep;
  final Color primary;
  final Color primaryMedium;
  final Color primaryLight;

  // الخلفيات
  final Color scaffoldLight;
  final Color cardLight;
  final Color borderLight;
  final Color dividerLight;

  // معاينة في القائمة
  final Color swatch;

  const AppPalette({
    required this.id,
    required this.nameAr,
    required this.primaryDeep,
    required this.primary,
    required this.primaryMedium,
    required this.primaryLight,
    required this.scaffoldLight,
    required this.cardLight,
    required this.borderLight,
    required this.dividerLight,
    required this.swatch,
  });

  List<Color> get headerGradient => [primaryDeep, primary, primaryMedium];
  List<Color> get gradientColors => [primaryDeep, primary, primaryMedium];

  // ───────── البيجي (الافتراضي) ─────────
  static const beige = AppPalette(
    id: 'beige',
    nameAr: 'بيجي',
    primaryDeep: Color(0xFF3E2C18),
    primary: Color(0xFF5C4528),
    primaryMedium: Color(0xFF7A5C36),
    primaryLight: Color(0xFFA68259),
    scaffoldLight: Color(0xFFF5F0E5),
    cardLight: Color(0xFFFBF8F2),
    borderLight: Color(0xFFE0D6C2),
    dividerLight: Color(0xFFE6DDC9),
    swatch: Color(0xFFC9A878),
  );

  // ───────── الكحلي ─────────
  static const navy = AppPalette(
    id: 'navy',
    nameAr: 'كحلي',
    primaryDeep: Color(0xFF0D1B2A),
    primary: Color(0xFF1B3A5C),
    primaryMedium: Color(0xFF2E5984),
    primaryLight: Color(0xFF4A7FAD),
    scaffoldLight: Color(0xFFF5F3EE),
    cardLight: Colors.white,
    borderLight: Color(0xFFE5E1D8),
    dividerLight: Color(0xFFE8E4DB),
    swatch: Color(0xFF1B3A5C),
  );

  // ───────── الزيتي ─────────
  static const sage = AppPalette(
    id: 'sage',
    nameAr: 'زيتي',
    primaryDeep: Color(0xFF1F3320),
    primary: Color(0xFF3A5938),
    primaryMedium: Color(0xFF587454),
    primaryLight: Color(0xFF7C9A77),
    scaffoldLight: Color(0xFFECF0E5),
    cardLight: Color(0xFFF8FAF4),
    borderLight: Color(0xFFCFD7C0),
    dividerLight: Color(0xFFD9DEC9),
    swatch: Color(0xFF3A5938),
  );

  // ───────── العنابي ─────────
  static const burgundy = AppPalette(
    id: 'burgundy',
    nameAr: 'عنابي',
    primaryDeep: Color(0xFF3D1521),
    primary: Color(0xFF5C2433),
    primaryMedium: Color(0xFF7A3447),
    primaryLight: Color(0xFFA15768),
    scaffoldLight: Color(0xFFF5EAEA),
    cardLight: Color(0xFFFBF4F4),
    borderLight: Color(0xFFE1C4C4),
    dividerLight: Color(0xFFE8D0D0),
    swatch: Color(0xFF5C2433),
  );

  // ───────── الفحمي ─────────
  static const charcoal = AppPalette(
    id: 'charcoal',
    nameAr: 'فحمي',
    primaryDeep: Color(0xFF1A1A1A),
    primary: Color(0xFF303030),
    primaryMedium: Color(0xFF4A4A4A),
    primaryLight: Color(0xFF6B6B6B),
    scaffoldLight: Color(0xFFF0EFEC),
    cardLight: Colors.white,
    borderLight: Color(0xFFDCDAD3),
    dividerLight: Color(0xFFE3E1DB),
    swatch: Color(0xFF303030),
  );

  static const List<AppPalette> all = [
    beige,
    navy,
    sage,
    burgundy,
    charcoal,
  ];

  static AppPalette byId(String? id) {
    return all.firstWhere(
      (p) => p.id == id,
      orElse: () => beige,
    );
  }
}
