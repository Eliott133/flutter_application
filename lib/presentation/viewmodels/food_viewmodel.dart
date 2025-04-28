import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/open_food_facts_api.dart';
import '../../domain/models/food_item.dart';

final foodProvider = StateNotifierProvider<FoodViewModel, AsyncValue<List<FoodItem>>>(
  (ref) => FoodViewModel(),
);

class FoodViewModel extends StateNotifier<AsyncValue<List<FoodItem>>> {
  final OpenFoodFactsAPI _api = OpenFoodFactsAPI();

  FoodViewModel() : super(const AsyncValue.data([]));

  Future<void> searchFood(String query) async {
    state = const AsyncValue.loading();

    try {
      final isBarcode = RegExp(r'^\d{8,13}$').hasMatch(query);
      if (isBarcode) {
        final item = await _api.fetchFoodItem(query);
        if (item != null) {
          state = AsyncValue.data([item]);
        } else {
          state = const AsyncValue.data([]);
        }
      } else {
        final items = await _api.searchFoodByName(query);
        state = AsyncValue.data(items);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

