// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodItem _$FoodItemFromJson(Map<String, dynamic> json) => FoodItem(
  code: json['code'] as String?,
  productName: json['productName'] as String?,
  imageUrl: json['imageUrl'] as String?,
  calories: (json['calories'] as num?)?.toDouble(),
  proteins: (json['proteins'] as num?)?.toDouble(),
  fats: (json['fats'] as num?)?.toDouble(),
  carbs: (json['carbs'] as num?)?.toDouble(),
);

Map<String, dynamic> _$FoodItemToJson(FoodItem instance) => <String, dynamic>{
  'code': instance.code,
  'productName': instance.productName,
  'imageUrl': instance.imageUrl,
  'calories': instance.calories,
  'proteins': instance.proteins,
  'fats': instance.fats,
  'carbs': instance.carbs,
};
