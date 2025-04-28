import 'package:flutter/material.dart';
import 'package:flutter_application/core/navigation/custom_page_route.dart';
import 'package:flutter_application/providers/meal_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/food_item.dart';
import '../search/search_screen.dart';
import '../../../domain/models/meal.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String userId;

  const DashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime selectedDate = DateTime.now();

  final Set<String> _expandedMeals = {};


  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    initializeDateFormatting('fr_FR', null);

    Future.microtask(() async {
      final mealsToday = await ref.read(mealRepositoryProvider).getMealsForDate(userId, selectedDate);
      print("Repas du jour : $mealsToday");
      if (mealsToday.isEmpty) {
        ref.read(mealProvider(userId).notifier).initializeDefaultMeals(selectedDate);
      }
  });
  }
  
Widget build(BuildContext context) {
  final asyncMeals = ref.watch(mealStreamProvider(userId));
  double totalCalories = 0;

  print("async meal $asyncMeals");

  asyncMeals.when(
    data: (mealsList) {
      final todayMeals = mealsList.where(
        (meal) => isSameDay(meal.date, selectedDate),
      ).toList();

      // Calculer le total des calories consommées
      for (var meal in todayMeals) {
        totalCalories += meal.totalCalories;
      }
    },
    loading: () {},
    error: (e, _) {},
  );

  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sélecteur de date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () {
                  setState(() {
                    selectedDate = selectedDate.subtract(const Duration(days: 1));
                  });
                },
              ),
              Text(
                DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(selectedDate),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: selectedDate.isBefore(DateTime.now())
                    ? () {
                        setState(() {
                          selectedDate = selectedDate.add(const Duration(days: 1));
                        });
                      }
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildPieChart(),

          const SizedBox(height: 16),

          // Barre de progression
          _buildProgressGoalBar(totalCalories),

          const SizedBox(height: 16),

          // Liste des repas
          Expanded(
            child: asyncMeals.when(
              data: (meals) {
                final todayMeals = meals.where(
                  (meal) => isSameDay(meal.date, selectedDate),
                ).toList();

                return ListView.builder(
                  itemCount: todayMeals.length,
                  itemBuilder: (context, index) {
                    final meal = todayMeals[index];
                    return _buildMealTile(context, meal);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Erreur : $e")),
            ),
          ),
        ],
      ),
    ),
  );
}


Widget _buildPieChart() {
  // Calculer les totaux des macronutriments pour la journée
  final meals = ref.watch(mealStreamProvider(userId));
  double totalProteins = 0;
  double totalFats = 0;
  double totalCarbs = 0;

  meals.when(
    data: (mealsList) {
      final todayMeals = mealsList.where(
        (meal) => isSameDay(meal.date, selectedDate),
      ).toList();

      for (var meal in todayMeals) {
        totalProteins += meal.totalProteins;
        totalFats += meal.totalFats;
        totalCarbs += meal.totalCarbs;
      }
    },
    loading: () {},
    error: (e, _) {},
  );

  // Vérifier si tous les totaux sont à zéro
  if (totalProteins == 0 && totalFats == 0 && totalCarbs == 0) {
    return Center(
      child: Text(
        "Commencez à ajouter un aliment pour voir les statistiques.",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Calcul du total général (la somme des 3 macronutriments)
  final totalMacronutrients = totalProteins + totalFats + totalCarbs;

  return SizedBox(
    height: 200,
    child: PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: totalCarbs / totalMacronutrients * 100,
            color: Colors.green,
            title: "Glucides\n${totalCarbs.toStringAsFixed(2)}g",
          ),
          PieChartSectionData(
            value: totalProteins / totalMacronutrients * 100,
            color: Colors.blue,
            title: "Protéines\n${totalProteins.toStringAsFixed(2)}g",
          ),
          PieChartSectionData(
            value: totalFats / totalMacronutrients * 100,
            color: Colors.red,
            title: "Lipides\n${totalFats.toStringAsFixed(2)}g",
          ),
        ],
      ),
    ),
  );
}


Widget _buildProgressGoalBar(double totalCalories) {
  const double goalCalories = 2000;

  double progress = totalCalories / goalCalories;

  // Si le nombre de calories dépasse l'objectif, mettre la barre en rouge
  Color progressColor = totalCalories > goalCalories ? Colors.red : Colors.green;

  return Column(
    children: [
      // Barre de progression
      LinearProgressIndicator(
        value: progress > 1 ? 1 : progress, // Limiter à 100%
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation(progressColor),
      ),
      const SizedBox(height: 8),
      // Afficher les calories consommées
      Text(
        "${totalCalories.toStringAsFixed(2)} kcal / $goalCalories kcal",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: progressColor,
        ),
      ),
    ],
  );
}

void _showFoodDetailsDialog(BuildContext context, FoodItem item) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding autour du contenu
          child: Column(
            mainAxisSize: MainAxisSize.min, // Permet au modal de s'ajuster selon le contenu
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image en haut du modal
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!, // URL de l'image de l'aliment
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
              ),
              const SizedBox(height: 16),

              // Titre de l'aliment
              Text(
                item.productName ?? "Nom inconnu",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Affichage des informations de l'aliment
              Text("Calories: ${item.calories?.toStringAsFixed(2)} kcal"),
              const SizedBox(height: 8),
              Text("Protéines: ${item.proteins?.toStringAsFixed(2)}g"),
              Text("Glucides: ${item.carbs?.toStringAsFixed(2)}g"),
              Text("Lipides: ${item.fats?.toStringAsFixed(2)}g"),

              const SizedBox(height: 16),

              // Bouton pour fermer le modal
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Fermer"),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


Widget _buildMealTile(BuildContext context, Meal meal) {
  final bool isExpanded = _expandedMeals.contains(meal.name);

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: ExpansionTile(
      title: Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Calories: ${meal.totalCalories.toStringAsFixed(2)} kcal"),
      trailing: Icon(
        isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
      ),
      initiallyExpanded: isExpanded,
      onExpansionChanged: (bool expanded) {
        setState(() {
          if (expanded) {
            _expandedMeals.add(meal.name);
          } else {
            _expandedMeals.remove(meal.name);
          }
        });
      },
      children: [
        if (meal.foods.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Aucun aliment ajouté."),
          )
        else
          ...meal.foods.map((item) {
            return Dismissible(
              key: Key(item.productName ?? 'unknown_food'), // Utiliser un identifiant unique pour chaque aliment
              direction: DismissDirection.endToStart, // Swipe de droite à gauche
              onDismissed: (direction) {
                // Appeler la fonction pour supprimer l'aliment du repas
                ref.read(mealProvider(userId).notifier).removeFoodFromMeal(meal.name, item, selectedDate);
              },
              background: Container(
                color: Colors.red, // Couleur rouge lorsque l'aliment est glissé
                alignment: Alignment.centerRight,
                child: const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
              ),
              child: ListTile(
                title: Text(item.productName ?? "Aliment inconnu"),
                subtitle: Text("${item.calories?.toStringAsFixed(2)} kcal"),
                onTap: () {
                  // Afficher les détails de l'aliment dans un modal
                  _showFoodDetailsDialog(context, item);
                },
              ),
            );
          }).toList(),

        const SizedBox(height: 8),

        TextButton.icon(
          onPressed: () async {
            final selectedFood = await Navigator.push(
              context,
              CustomPageRoute(
                page: SearchScreen(
                  userId: userId,
                  mealName: meal.name,
                ),
              ),
            );

            if (selectedFood is Map) {
              final foodItem = selectedFood['foodItem'] as FoodItem;
              final mealType = selectedFood['mealType'] as String;

              ref.read(mealProvider(userId).notifier).addFoodToMeal(
                mealType,
                foodItem,
                selectedDate,
              );
            }
          },
          icon: const Icon(Icons.add),
          label: const Text("Ajouter un aliment"),
        ),
      ],
    ),
  );
}


  // Vérifier si deux dates sont le même jour
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}