import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

/// Provider لإدارة حجم الخط
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return FontSizeNotifier(prefs)..loadFontSize();
});

class FontSizeNotifier extends StateNotifier<double> {
  final SharedPreferences _prefs;
  static const String _fontSizeKey = 'font_size';
  static const double _defaultFontSize = 1.0; // حجم افتراضي
  static const double _minFontSize = 0.8;
  static const double _maxFontSize = 1.5;

  FontSizeNotifier(this._prefs) : super(_defaultFontSize);

  Future<void> loadFontSize() async {
    final fontSize = _prefs.getDouble(_fontSizeKey) ?? _defaultFontSize;
    state = fontSize.clamp(_minFontSize, _maxFontSize);
  }

  Future<void> setFontSize(double size) async {
    final clampedSize = size.clamp(_minFontSize, _maxFontSize);
    state = clampedSize;
    await _prefs.setDouble(_fontSizeKey, clampedSize);
  }

  double get minFontSize => _minFontSize;
  double get maxFontSize => _maxFontSize;
}

