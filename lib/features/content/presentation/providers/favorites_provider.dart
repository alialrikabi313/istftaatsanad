import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/content_repository_impl.dart';
import 'content_providers.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final ContentRepositoryImpl repo;
  FavoritesNotifier(this.repo) : super({}) {
    _load();
  }

  Future<void> _load() async {
    state = await repo.loadFavorites();
  }

  Future<void> toggle(String id, bool val) async {
    await repo.toggleFavorite(id, val);
    state = await repo.loadFavorites();
  }
}

final favoritesProvider =
StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final repo = ref.watch(contentRepositoryProvider);
  return FavoritesNotifier(repo);
});
