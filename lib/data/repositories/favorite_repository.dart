import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/food_item.dart';

class FavoriteRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addFavorite(String userId, FoodItem foodItem) async {
    await _firestore.collection('users').doc(userId).collection('favorites').doc(foodItem.code).set(foodItem.toJson());
  }

  Future<void> removeFavorite(String userId, String foodId) async {
    await _firestore.collection('users').doc(userId).collection('favorites').doc(foodId).delete();
  }

  Stream<List<FoodItem>> getFavorites(String userId) {
    return _firestore
      .collection('users')
      .doc(userId)
      .collection('favorites')
      .snapshots()
      .map((snapshot) =>
        snapshot.docs.map((doc) => FoodItem.fromJson(doc.data())).toList());
  }
}
