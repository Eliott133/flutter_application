import 'package:json_annotation/json_annotation.dart';

part 'food_item.g.dart';

@JsonSerializable()
class FoodItem {
  final String? code;
  final String? productName;
  final String? imageUrl;
  final double? calories;
  final double? proteins;
  final double? fats;
  final double? carbs;

  FoodItem({
    this.code,
    this.productName,
    this.imageUrl,
    this.calories,
    this.proteins,
    this.fats,
    this.carbs,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'productName': productName,
      'imageUrl': imageUrl,
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      code: map['code'] as String?,
      productName: map['productName'] as String?,
      imageUrl: map['imageUrl'] as String?,
      calories: map['calories'] != null ? (map['calories'] as num).toDouble() : null,
      proteins: map['proteins'] != null ? (map['proteins'] as num).toDouble() : null,
      fats: map['fats'] != null ? (map['fats'] as num).toDouble() : null,
      carbs: map['carbs'] != null ? (map['carbs'] as num).toDouble() : null,
    );
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      _$FoodItemFromJson(json);

  Map<String, dynamic> toJson() => _$FoodItemToJson(this);
}
