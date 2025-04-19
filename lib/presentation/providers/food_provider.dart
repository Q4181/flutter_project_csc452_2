import 'package:flutter/material.dart';
import '../../data/models/food.dart';
import '../../data/repositories/food_repository.dart';
import '../../data/services/api_service.dart';

class FoodProvider with ChangeNotifier {
  final FoodRepository _foodRepository;
  List<Food> _foods = [];
  List<Food> _selectedFoods = [];
  bool _isLoading = false;
  String? _error;

  FoodProvider() : _foodRepository = FoodRepository(ApiService());

  List<Food> get foods => _foods;
  List<Food> get selectedFoods => _selectedFoods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFoods() async {
    _isLoading = true;
    notifyListeners();
    try {
      _foods = await _foodRepository.getFoodsWithNutrients();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleFoodSelection(Food food) {
    if (_selectedFoods.contains(food)) {
      _selectedFoods.remove(food);
    } else {
      _selectedFoods.add(food);
    }
    notifyListeners();
  }

  Map<String, double> calculateTotalNutrients() {
    double protein = 0;
    double fat = 0;
    double carbohydrates = 0;
    double fiber = 0;
    double sugar = 0;
    double sodium = 0;

    for (var food in _selectedFoods) {
      if (food.nutrient != null) {
        protein += food.nutrient!.protein;
        fat += food.nutrient!.fat;
        carbohydrates += food.nutrient!.carbohydrates;
        fiber += food.nutrient!.fiber;
        sugar += food.nutrient!.sugar;
        sodium += food.nutrient!.sodium;
      }
    }

    return {
      'protein': protein,
      'fat': fat,
      'carbohydrates': carbohydrates,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
    };
  }
}