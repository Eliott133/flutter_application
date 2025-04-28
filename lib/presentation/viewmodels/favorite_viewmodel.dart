  import 'package:flutter_application/providers/favorite_provider.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../domain/models/food_item.dart';

  class FavoriteViewModel extends StateNotifier<List<FoodItem>> {
    final Ref ref;
    final String userId;

    FavoriteViewModel(this.ref, this.userId) : super([]);

    Future<void> addFavorite(String userId, FoodItem foodItem) async {
      await ref.read(favoriteRepositoryProvider).addFavorite(userId, foodItem);
    }

    Future<void> removeFavorite(String userId, String foodId) async {
      await ref.read(favoriteRepositoryProvider).removeFavorite(userId, foodId);
    }
  }
