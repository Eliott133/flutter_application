import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/favorite_repository.dart';
import '../presentation/viewmodels/favorite_viewmodel.dart';
import '../../domain/models/food_item.dart';

final favoriteRepositoryProvider = Provider((ref) => FavoriteRepository());

final favoriteViewModelProvider = StateNotifierProvider.family<FavoriteViewModel, List<FoodItem>, String>((ref, userId) {
  return FavoriteViewModel(ref, userId);
});

final favoritesProvider = StreamProvider.family<List<FoodItem>, String>((ref, userId) {
  return ref.watch(favoriteRepositoryProvider).getFavorites(userId);
});
