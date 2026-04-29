import 'package:shared_preferences/shared_preferences.dart';

class FavoritesLocal {
  final SharedPreferences _sp;
  FavoritesLocal(this._sp);

  String _key(String uid) => 'favorites_$uid';

  List<String> getFavorites(String uid) {
    return _sp.getStringList(_key(uid)) ?? <String>[];
  }

  Future<void> toggle(String uid, String qId, bool isFav) async {
    final list = getFavorites(uid);
    if (isFav) {
      if (!list.contains(qId)) list.add(qId);
    } else {
      list.remove(qId);
    }
    await _sp.setStringList(_key(uid), list);
  }

  bool isFav(String uid, String qId) => getFavorites(uid).contains(qId);
}
