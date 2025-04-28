import 'package:json_annotation/json_annotation.dart';
import 'food_item.dart';

part 'meal.g.dart';

@JsonSerializable()
class Meal {
  final String name;
  final List<FoodItem> foods;
  final DateTime date;

  // Le constructeur inclut maintenant une date obligatoire
  Meal({
    required this.name,
    List<FoodItem>? foods,
    required this.date, // La date est maintenant obligatoire
  }) : foods = foods ?? [];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'foods': foods.map((f) => f.toMap()).toList(),
    };
  }

    factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      name: map['name'],
      foods: (map['foods'] as List<dynamic>).map((foodMap) => FoodItem.fromMap(foodMap)).toList(),
      date: DateTime.parse(map['date']),
    );
  }

  // Calcul des calories totales du repas
  double get totalCalories => foods.fold(0, (sum, food) => sum + (food.calories ?? 0));

    // Calcul du total des protéines
  double get totalProteins => foods.fold(0, (sum, food) => sum + (food.proteins ?? 0));

  // Calcul du total des lipides
  double get totalFats => foods.fold(0, (sum, food) => sum + (food.fats ?? 0));

  // Calcul du total des glucides
  double get totalCarbs => foods.fold(0, (sum, food) => sum + (food.carbs ?? 0));

  factory Meal.fromJson(Map<String, dynamic> json) =>
      _$MealFromJson(json);

  Map<String, dynamic> toJson() => _$MealToJson(this);
}