import '../../models/food_model.dart';
import '../data/food_database.dart';

class FoodSearchService {
  /// Cari rekomendasi makanan dari dataset lokal berdasarkan target nutrisi
  Future<List<FoodModel>> searchFoodRecommendations(
    double calories, {
    double? sugar,
    double? fat,
    double? protein,
  }) async {
    // Simulasi delay untuk memberikan UX yang smooth
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      print(
        'DEBUG: Searching dataset for calories=$calories, protein=$protein, fat=$fat, sugar=$sugar',
      );

      // Cari dari dataset
      final results = FoodDatabase.searchByNutrition(
        targetCalories: calories,
        targetProtein: protein,
        targetFat: fat,
        targetSugar: sugar,
        limit: 5,
      );

      print('DEBUG: Found ${results.length} recommendations from dataset');

      // Konversi ke FoodModel
      return results
          .map(
            (item) => FoodModel(
              id: '${(item['name'] as String).replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}',
              name: item['name'] as String,
              calories: (item['calories'] as num).toDouble(),
              protein: (item['protein'] as num).toDouble(),
              fat: (item['fat'] as num).toDouble(),
              carbs: (item['carbs'] as num).toDouble(),
              sugar: (item['sugar'] as num).toDouble(),
              consumedAt: DateTime.now(),
            ),
          )
          .toList();
    } catch (e) {
      print('ERROR searchFoodRecommendations: $e');
      return [];
    }
  }
}
