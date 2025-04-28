// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meal _$MealFromJson(Map<String, dynamic> json) => Meal(
  name: json['name'] as String,
  foods:
      (json['foods'] as List<dynamic>?)
          ?.map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$MealToJson(Meal instance) => <String, dynamic>{
  'name': instance.name,
  'foods': instance.foods,
  'date': instance.date.toIso8601String(),
};
