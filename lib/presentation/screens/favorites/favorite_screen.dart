import 'package:flutter/material.dart';
import 'package:flutter_application/providers/favorite_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteScreen extends ConsumerWidget {
  final String userId;

  const FavoriteScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsyncValue = ref.watch(favoritesProvider(userId));
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text("Mes Favoris"),
      ),
      body: favoritesAsyncValue.when(
        data: (favoriteFoodItems) {
          if (favoriteFoodItems.isEmpty) {
            return const Center(
              child: Text("Aucun favori pour le moment."),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: favoriteFoodItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final foodItem = favoriteFoodItems[index];

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: foodItem.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            foodItem.imageUrl!,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[300],
                          child: const Icon(Icons.fastfood, size: 40),
                        ),
                  title: Text(
                    foodItem.productName ?? "Nom inconnu",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (foodItem.calories != null) Text("Calories: ${foodItem.calories!.toStringAsFixed(1)} kcal"),
                      if (foodItem.proteins != null) Text("Protéines: ${foodItem.proteins!.toStringAsFixed(1)} g"),
                      if (foodItem.carbs != null) Text("Glucides: ${foodItem.carbs!.toStringAsFixed(1)} g"),
                      if (foodItem.fats != null) Text("Lipides: ${foodItem.fats!.toStringAsFixed(1)} g"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirmer la suppression"),
                          content: const Text("Veux-tu supprimer cet aliment de tes favoris ?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Annuler"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final favoriteViewModel = ref.read(favoriteViewModelProvider(userId).notifier);
                        await favoriteViewModel.removeFavorite(userId, foodItem.code!);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("Erreur: $error")),
      ),
    ),
    );
  }
}
