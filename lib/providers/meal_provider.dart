import 'package:flutter_application/domain/models/meal.dart';
import 'package:flutter_application/presentation/viewmodels/meal_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/meal_repository.dart';

final mealRepositoryProvider = Provider((ref) => MealRepository());

/*final mealsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  return ref.watch(mealRepositoryProvider).getMeals(userId);
});*/

final mealProvider = StateNotifierProvider.family<MealViewModel, List<Meal>, String>((ref, userId) {
  return MealViewModel(ref, userId);
});

final mealStreamProvider = StreamProvider.family<List<Meal>, String>((ref, userId) {
  return ref.watch(mealRepositoryProvider).getMeals(userId).map((mealList) {
    return mealList.map((map) => Meal.fromJson(map)).toList();
  });
});

/*
final favoritesProvider = StreamProvider.family<List<FoodItem>, String>((ref, userId) {
  return ref.watch(mealRepositoryProvider).getFavorites(userId);
});*/
