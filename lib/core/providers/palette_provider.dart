import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../constants/app_colors.dart';
import '../theme/app_palette.dart';

/// Provider لإدارة لوحة ألوان التطبيق المختارة.
/// الافتراضي: البيجي.
final paletteProvider =
    StateNotifierProvider<PaletteNotifier, AppPalette>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return PaletteNotifier(prefs)..load();
});

class PaletteNotifier extends StateNotifier<AppPalette> {
  final SharedPreferences _prefs;
  static const String _key = 'app_palette';

  PaletteNotifier(this._prefs) : super(AppPalette.beige) {
    AppColors.applyPalette(state);
  }

  void load() {
    final id = _prefs.getString(_key);
    final palette = AppPalette.byId(id);
    AppColors.applyPalette(palette);
    state = palette;
  }

  Future<void> setPalette(AppPalette palette) async {
    AppColors.applyPalette(palette);
    state = palette;
    await _prefs.setString(_key, palette.id);
  }
}
