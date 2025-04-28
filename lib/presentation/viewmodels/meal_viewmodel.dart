import 'package:flutter_application/providers/meal_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/meal.dart';
import '../../domain/models/food_item.dart';

class MealViewModel extends StateNotifier<List<Meal>> {
  final Ref ref;
  final String userId;

    MealViewModel(this.ref, this.userId) : super([]) {
    _loadMealsFromFirestore(); // Charger les repas depuis Firestore lors de l'initialisation
  }

  Future<void> _loadMealsFromFirestore() async {
    final mealRepository = ref.read(mealRepositoryProvider);
    final mealsStream = mealRepository.getMeals(userId);

    mealsStream.listen((mealsData) {
      // Conversion des Map<String, dynamic> en objets Meal
      final meals = mealsData.map((mealData) => Meal.fromMap(mealData)).toList();

      // Mise à jour de l'état avec la liste des repas
      state = meals;
      print("Repas récupérés : $meals.toString()");
    });
  }


/*
  void addFoodToMeal(String mealName, FoodItem food, DateTime date) {
    final mealRepository = ref.read(mealRepositoryProvider);

    bool mealExists = state.any((meal) =>
        meal.name == mealName && isSameDay(meal.date, date));

    Meal updatedMeal = Meal(name: '', foods: [], date: DateTime.now());

    if (mealExists) {
      state = state.map((meal) {
        if (meal.name == mealName && isSameDay(meal.date, date)) {
          print("Ajout de l'aliment au repas existant : ${meal.name}");
          updatedMeal = Meal(name: meal.name, foods: [...meal.foods, food], date: meal.date);
          print("Nouveau repas : ${updatedMeal.toString()}");
          return updatedMeal;
        }
        return meal;
      }).toList();
    } else {
      updatedMeal = Meal(name: mealName, foods: [food], date: date);
      state = [...state, updatedMeal];
    }

    // Enregistrer dans Firestore
    mealRepository.addMeal(userId, updatedMeal.toMap());
  }
*/

void addFoodToMeal(String mealName, FoodItem food, DateTime date) {
  final mealRepository = ref.read(mealRepositoryProvider);

  bool mealExists = state.any((meal) =>
      meal.name == mealName && isSameDay(meal.date, date));

  Meal updatedMeal = Meal(name: '', foods: [], date: DateTime.now());

  if (mealExists) {
    state = state.map((meal) {
      if (meal.name == mealName && isSameDay(meal.date, date)) {
        updatedMeal = Meal(
          name: meal.name,
          foods: [...meal.foods, food],
          date: meal.date,
        );
        return updatedMeal;
      }
      return meal;
    }).toList();
  } else {
    updatedMeal = Meal(name: mealName, foods: [food], date: date);
    state = [...state, updatedMeal];
  }

  // 🔁 Sauvegarde dans Firestore (create or update)
  final docId = _generateMealDocId(mealName, date);
  mealRepository.addOrUpdateMeal(userId, updatedMeal.toMap(), docId);
}

/*
Future<void> addFavorite(String userId, FoodItem item) async {
  final mealRepository = ref.read(mealRepositoryProvider);
  await mealRepository.addFavorite(userId, item);
}

Future<void> removeFavorite(String userId, String foodId) async {
  final mealRepository = ref.read(mealRepositoryProvider);
  await mealRepository.removeFavorite(userId, foodId);
}*/


bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

String _generateMealDocId(String mealName, DateTime date) {
  final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  return "$mealName-$formattedDate";
}


void initializeDefaultMeals(DateTime date) {
  final defaultMealNames = ['Petit déjeuner', 'Déjeuner', 'Dîner'];
  final mealRepository = ref.read(mealRepositoryProvider);

  for (var name in defaultMealNames) {
    bool exists = state.any((meal) => meal.name == name && isSameDay(meal.date, date));

    if (!exists) {
      print("Création du repas par défaut : $name pour la date $date");
      final newMeal = Meal(name: name, date: date, foods: []);
      state = [...state, newMeal];

      final docId = _generateMealDocId(name, date);
      mealRepository.addOrUpdateMeal(userId, newMeal.toMap(), docId);
    }
  }
}

void removeFoodFromMeal(String mealName, FoodItem item, DateTime selectedDate) async {
  // Supprimer l'aliment du repas localement
  print("Suppression de l'aliment : ${item.productName} du repas : $mealName pour la date : $selectedDate");
  print(state.toString());
  state = state.map((meal) {
    if (meal.name == mealName && isSameDay(meal.date, selectedDate)) {
      print("Repas trouvé : ${meal.name} pour la date : $selectedDate");
      meal.foods.remove(item); // Supprimer l'aliment de la liste
    }
    return meal;
  }).toList();

  // Appeler la méthode pour supprimer l'aliment de la base de données
  final mealRepository = ref.read(mealRepositoryProvider);
  await mealRepository.removeFoodFromMeal(userId, mealName, item, selectedDate);
}
}
