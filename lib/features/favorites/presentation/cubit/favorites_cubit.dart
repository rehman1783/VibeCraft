import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../../wallpaper_explore/domain/entities/wallpaper_entity.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repository;

  FavoritesCubit({required this.repository}) : super(const FavoritesState());

  Future<void> loadFavorites() async {
    emit(state.copyWith(isLoading: true));
    try {
      final list = await repository.getFavoriteWallpapers();
      final ids = list.map((w) => w.id).toSet();
      emit(state.copyWith(
        favorites: list,
        favoriteIds: ids,
        isLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  bool isFavorite(String wallpaperId) {
    return state.favoriteIds.contains(wallpaperId);
  }

  Future<bool> toggleFavorite(WallpaperEntity wallpaper) async {
    final isNowFavorite = await repository.toggleFavorite(wallpaper);
    await loadFavorites();
    return isNowFavorite;
  }

  Future<void> onWallpaperDownloaded(String wallpaperId, String localPath) async {
    await repository.updateFavoriteLocalPath(wallpaperId, localPath);
    await loadFavorites();
  }

  Future<void> onCacheCleared() async {
    await repository.sanitizeFavoritesAfterCacheClear();
    await loadFavorites();
  }
}
