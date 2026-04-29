import 'package:flutter/material.dart';
import 'package:sanad_ui/sanad_ui.dart';
import '../theme/app_palette.dart';

/// `AppColors` كان سابقاً typedef للـ `SanadColors` ثابت.
/// الآن أصبح غلافاً يقرأ ألوان الأساس من اللوحة المختارة في الإعدادات،
/// مع الإبقاء على الذهبي والنصوص والحالات ثابتة كهوية للعلامة.
class AppColors {
  AppColors._();

  static AppPalette _palette = AppPalette.beige;

  static void applyPalette(AppPalette palette) {
    _palette = palette;
  }

  static AppPalette get currentPalette => _palette;

  // ─── ألوان الأساس (تتغيّر مع اللوحة) ───
  static Color get primaryDeep => _palette.primaryDeep;
  static Color get primary => _palette.primary;
  static Color get primaryMedium => _palette.primaryMedium;
  static Color get primaryLight => _palette.primaryLight;

  static List<Color> get gradientColors => _palette.gradientColors;
  static List<Color> get headerGradient => _palette.headerGradient;

  // ─── الخلفيات (تتغيّر مع اللوحة في النهاري فقط) ───
  static Color get scaffoldBackground => _palette.scaffoldLight;
  static Color get cardBackground => _palette.cardLight;
  static Color get border => _palette.borderLight;
  static Color get divider => _palette.dividerLight;

  // ─── ثوابت الوضع الليلي ───
  static const Color scaffoldBackgroundDark = SanadColors.scaffoldBackgroundDark;
  static const Color cardBackgroundDark = SanadColors.cardBackgroundDark;
  static const Color borderDark = SanadColors.borderDark;
  static const Color dividerDark = SanadColors.dividerDark;

  // ─── الذهبي (هوية ثابتة) ───
  static const Color gold = SanadColors.gold;
  static const Color goldLight = SanadColors.goldLight;
  static const Color goldDark = SanadColors.goldDark;
  static const List<Color> goldGradient = SanadColors.goldGradient;

  // ─── النصوص ───
  static const Color textPrimary = SanadColors.textPrimary;
  static const Color textSecondary = SanadColors.textSecondary;
  static const Color textOnPrimary = SanadColors.textOnPrimary;
  static const Color textOnGold = SanadColors.textOnGold;

  // ─── الحالة ───
  static const Color error = SanadColors.error;
  static const Color success = SanadColors.success;
  static const Color warning = SanadColors.warning;
  static const Color info = SanadColors.info;

  // ─── المفضلة ───
  static const Color favoriteActive = SanadColors.favoriteActive;
  static const Color favoriteInactive = SanadColors.favoriteInactive;
  static const Color newBadge = SanadColors.newBadge;

  // ─── shimmer ───
  static const Color shimmerBase = SanadColors.shimmerBase;
  static const Color shimmerHighlight = SanadColors.shimmerHighlight;
  static const Color shimmerBaseDark = SanadColors.shimmerBaseDark;
  static const Color shimmerHighlightDark = SanadColors.shimmerHighlightDark;
}
