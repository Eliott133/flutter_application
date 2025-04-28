import 'package:flutter/material.dart';
import '../../../providers/favorite_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/food_viewmodel.dart';
import '../../../domain/models/food_item.dart';
import 'barcode_scanner_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String userId;
  final String? mealName;

  const SearchScreen({super.key, required this.userId, this.mealName});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foodState = ref.watch(foodProvider);
    final favoriteViewModel = ref.read(favoriteViewModelProvider(widget.userId).notifier);
    final favoriteState = ref.watch(favoritesProvider(widget.userId));


    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Recherche d'aliments")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _searchFocusNode,
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: "Entrez un code-barres ou nom",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onSubmitted: (value) {
                        ref.read(foodProvider.notifier).searchFood(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    tooltip: "Scanner un code-barres",
                    onPressed: () async {
                      final scannedCode = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
                      );

                      if (scannedCode != null && scannedCode is String) {
                        _barcodeController.text = scannedCode;
                        ref.read(foodProvider.notifier).searchFood(scannedCode);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: foodState.when(
                  data: (foodList) {
                    if (foodList.isEmpty) {
                      return const Center(child: Text("Aucun aliment trouvé."));
                    }
                    return ListView.builder(
                      itemCount: foodList.length,
                      itemBuilder: (context, index) {
                        final foodItem = foodList[index];
                        final isFavorite = favoriteState.value?.any((fav) => fav.code == foodItem.code) ?? false;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (foodItem.imageUrl != null)
                                  Center(child: Image.network(foodItem.imageUrl!, height: 100)),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        foodItem.productName ?? "Nom inconnu",
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? Colors.red : Colors.grey,
                                      ),
                                      onPressed: () {
                                        if (isFavorite) {
                                          favoriteViewModel.removeFavorite(widget.userId, foodItem.code!);
                                        } else {
                                          favoriteViewModel.addFavorite(widget.userId, foodItem);
                                        }
                                      },
                                    ),

                                  ],
                                ),
                                Text("Calories: ${foodItem.calories?.toStringAsFixed(2) ?? 'N/A'} kcal"),
                                Text("Protéines: ${foodItem.proteins?.toStringAsFixed(2) ?? 'N/A'} g"),
                                Text("Lipides: ${foodItem.fats?.toStringAsFixed(2) ?? 'N/A'} g"),
                                Text("Glucides: ${foodItem.carbs?.toStringAsFixed(2) ?? 'N/A'} g"),
                                const SizedBox(height: 15),
                                ElevatedButton.icon(
                                onPressed: () async {
                                  String? mealType = widget.mealName;

                                  if (mealType == null) {
                                    print("mealType");
                                    // Si aucun repas n'est précisé, demander à l'utilisateur
                                    mealType = await showModalBottomSheet<String>(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                      builder: (context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                "Ajouter à quel repas ?",
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 20),
                                              ListTile(
                                                leading: const Icon(Icons.free_breakfast),
                                                title: const Text('Petit-déjeuner'),
                                                onTap: () => Navigator.pop(context, 'Petit-déjeuner'),
                                              ),
                                              ListTile(
                                                leading: const Icon(Icons.lunch_dining),
                                                title: const Text('Déjeuner'),
                                                onTap: () => Navigator.pop(context, 'Déjeuner'),
                                              ),
                                              ListTile(
                                                leading: const Icon(Icons.dinner_dining),
                                                title: const Text('Dîner'),
                                                onTap: () => Navigator.pop(context, 'Dîner'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }

                                  if (mealType != null) {
                                    Navigator.pop(context, {
                                      'foodItem': foodItem,
                                      'mealType': mealType,
                                    });
                                  }
                                },

                                  icon: const Icon(Icons.add),
                                  label: const Text("Ajouter à mon repas"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text("Erreur: $err")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}