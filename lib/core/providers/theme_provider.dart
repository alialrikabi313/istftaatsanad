import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

/// Provider لإدارة وضع الثيم (ليلي/نهاري/تلقائي)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ThemeModeNotifier(prefs)..loadTheme();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const String _themeKey = 'theme_mode';

  ThemeModeNotifier(this._prefs) : super(ThemeMode.system);

  Future<void> loadTheme() async {
    final themeString = _prefs.getString(_themeKey);
    if (themeString == null) {
      state = ThemeMode.system;
      return;
    }
    
    switch (themeString) {
      case 'ThemeMode.light':
        state = ThemeMode.light;
        break;
      case 'ThemeMode.dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_themeKey, mode.toString());
  }

  ThemeMode get currentMode => state;
}

