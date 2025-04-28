import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/domain/models/food_item.dart';
import 'package:flutter_application/domain/models/meal.dart';

class MealRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /*Future<void> addMeal(String userId, Map<String, dynamic> mealData) async {
    await _firestore.collection('users').doc(userId).collection('meals').add(mealData);
  }*/

  Future<void> addOrUpdateMeal(String userId, Map<String, dynamic> mealData, String docId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('meals')
        .doc(docId)
        .set(mealData, SetOptions(merge: true)); // merge écrase uniquement les champs mis à jour
  }
/*
  Future<void> addFavorite(String userId, FoodItem foodItem) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(foodItem.code) // Utilise le code-barres comme ID
        .set(foodItem.toJson());
  }

  Future<void> removeFavorite(String userId, String foodId) async {
    await _firestore.collection('users').doc(userId).collection('favorites').doc(foodId).delete();
  }
*/

  /*
  Stream<List<Map<String, dynamic>>> getMeals(String userId) {
    print('Fetching meals for user: $userId');
    return _firestore.collection('users').doc(userId).collection('meals').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }*/

  Stream<List<Map<String, dynamic>>> getMeals(String userId) {
    print('Fetching meals for user: $userId');
    return _firestore.collection('users').doc(userId).collection('meals').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }


  removeFoodFromMeal(String userId, String mealName, FoodItem item, DateTime selectedDate) async {
    try {
      // 1. Construire la bonne référence du document
      final formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      print('formattedDate: $formattedDate');
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('meals')
          .doc('$mealName-$formattedDate');

      final docSnapshot = await docRef.get();

      print(docSnapshot);

      if (docSnapshot.exists) {
        final data = docSnapshot.data();

        if (data != null && data['foods'] != null) {
          List<dynamic> foods = List.from(data['foods']);
          
          // 2. Retirer l'aliment correspondant
          foods.removeWhere((food) => food['productName'] == item.productName);

          // 3. Mettre à jour le document
          await docRef.update({
            'foods': foods,
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la suppression de l\'aliment : $e');
    }
  }

  Future<List<Meal>> getMealsForDate(String userId, DateTime date) async {
  final allMealsStream = getMeals(userId);
  final mealsList = await allMealsStream.first; // Prendre une seule fois
  return mealsList
      .map((mealData) => Meal.fromMap(mealData))
      .where((meal) => isSameDay(meal.date, date))
      .toList();
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
/*
  Stream<List<FoodItem>> getFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodItem.fromJson(doc.data()))
            .toList());
  }
*/
}
