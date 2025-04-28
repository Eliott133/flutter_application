import 'package:openfoodfacts/openfoodfacts.dart';
import '../../../domain/models/food_item.dart';

class OpenFoodFactsAPI {

  final User _user = const User(userId: 'flutterApp', password: 'flutterApp');

  OpenFoodFactsAPI() {
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'NomDeTonApp',
      version: '1.0.0',
      system: 'Flutter',
    );
  }

  Future<FoodItem?> fetchFoodItem(String barcode) async {
    ProductQueryConfiguration config = ProductQueryConfiguration(
      barcode,
      version: ProductQueryVersion.v3,
      language: OpenFoodFactsLanguage.FRENCH,
    );

    try {
      ProductResultV3 result = await OpenFoodAPIClient.getProductV3(config);

      if (result.product != null) {
        Product product = result.product!;
        return FoodItem(
          code: product.barcode,
          productName: product.productName,
          imageUrl: product.imageFrontUrl,
          calories: product.nutriments?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
          proteins: product.nutriments?.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
          fats: product.nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams),
          carbs: product.nutriments?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
        );
      }
    } catch (e) {
      print("Erreur lors de la récupération de l'aliment : $e");
    }
    return null;
  }

  Future<List<FoodItem>> searchFoodByName(String name) async {
    final queryConfig = ProductSearchQueryConfiguration(
      parametersList: [SearchTerms(terms: [name])],
      language: OpenFoodFactsLanguage.FRENCH,
      fields: [ProductField.ALL],
      version: ProductQueryVersion.v3,
    );

    try {
      final result = await OpenFoodAPIClient.searchProducts(
        _user,
        queryConfig,
      );

      return result.products
              ?.map((product) => FoodItem(
                    code: product.barcode,
                    productName: product.productName,
                    imageUrl: product.imageFrontUrl,
                    calories: product.nutriments?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
                    proteins: product.nutriments?.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
                    fats: product.nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams),
                    carbs: product.nutriments?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
                  ))
              .whereType<FoodItem>()
              .toList() ??
          [];
    } catch (e) {
      print("Erreur recherche nom : $e");
      return [];
    }
  }
}
