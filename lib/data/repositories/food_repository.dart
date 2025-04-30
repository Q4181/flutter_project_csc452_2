import '../models/food.dart';
import '../services/api_service.dart';

class FoodRepository {
  final ApiService apiService;

  FoodRepository(this.apiService);

  Future<List<Food>> getFoodsWithNutrients() async {
    return await apiService.fetchFoodsWithNutrients();
  }

  Future<void> createFood({
    required String foodName,
    required String category,
    required String servingSize,
    required double caloriesPerServing,
    String? imageUrl,
    double? protein,
    double? fat,
    double? carbohydrates,
    double? fiber,
    double? sugar,
    double? sodium,
  }) async {
    await apiService.createFood(
      foodName: foodName,
      category: category,
      servingSize: servingSize,
      caloriesPerServing: caloriesPerServing,
      imageUrl: imageUrl,
      protein: protein,
      fat: fat,
      carbohydrates: carbohydrates,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
    );
  }

  Future<void> updateFood({
    required int foodId,
    required String foodName,
    required String category,
    required String servingSize,
    required double caloriesPerServing,
    String? imageUrl,
    int? nutrientId,
    double? protein,
    double? fat,
    double? carbohydrates,
    double? fiber,
    double? sugar,
    double? sodium,
  }) async {
    await apiService.updateFood(
      foodId: foodId,
      foodName: foodName,
      category: category,
      servingSize: servingSize,
      caloriesPerServing: caloriesPerServing,
      imageUrl: imageUrl,
      nutrientId: nutrientId,
      protein: protein,
      fat: fat,
      carbohydrates: carbohydrates,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
    );
  }

  Future<void> deleteFood(int foodId) async {
    await apiService.deleteFood(foodId);
  }
}