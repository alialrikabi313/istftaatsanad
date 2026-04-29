import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/favorites_local.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((_) => throw UnimplementedError());
final favoritesLocalProvider = Provider<FavoritesLocal>((ref) => FavoritesLocal(ref.watch(sharedPrefsProvider)));

final favoritesListProvider = StateNotifierProvider.family<FavoritesNotifier, List<String>, String>((ref, uid) {
  return FavoritesNotifier(ref.watch(favoritesLocalProvider), uid);
});

class FavoritesNotifier extends StateNotifier<List<String>> {
  final FavoritesLocal local;
  final String uid;
  FavoritesNotifier(this.local, this.uid) : super(local.getFavorites(uid));

  void toggle(String qId) {
    final newState = [...state];
    if (newState.contains(qId)) {
      newState.remove(qId);
      local.toggle(uid, qId, false);
    } else {
      newState.add(qId);
      local.toggle(uid, qId, true);
    }
    state = newState;
  }

  bool isFav(String qId) => state.contains(qId);
}
