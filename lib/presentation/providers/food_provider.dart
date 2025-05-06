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
  List<String> _categories = ['All'];
  String _selectedCategory = 'All';

  FoodProvider() : _foodRepository = FoodRepository(ApiService());

  // Getters
  List<Food> get foods {
    if (_selectedCategory == 'All') {
      return _foods;
    }
    return _foods.where((food) => food.category == _selectedCategory).toList();
  }

  List<Food> get selectedFoods => _selectedFoods;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;

  // ดึงข้อมูลอาหาร
  Future<void> fetchFoods() async {
    _isLoading = true;
    notifyListeners();//update ui
    try {
      _foods = await _foodRepository.getFoodsWithNutrients();
      _categories = ['All', ..._foods.map((food) => food.category).toSet().toList()];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // เลือกหมวดหมู่
  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // สร้างอาหารใหม่
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
    _isLoading = true;
    notifyListeners();
    try {
      await _foodRepository.createFood(
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
      await fetchFoods();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // อัปเดตอาหาร
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
    _isLoading = true;
    notifyListeners();
    try {
      await _foodRepository.updateFood(
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
      await fetchFoods();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ลบอาหาร
  Future<void> deleteFood(int foodId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _foodRepository.deleteFood(foodId);
      _selectedFoods.removeWhere((food) => food.foodId == foodId);
      await fetchFoods();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // เลือกอาหาร
  void toggleFoodSelection(Food food) {
    if (_selectedFoods.contains(food)) {
      _selectedFoods.remove(food);
    } else {
      _selectedFoods.add(food);
    }
    notifyListeners();
  }

  // ล้างการเลือกอาหารทั้งหมด
  void clearSelectedFoods() {
    _selectedFoods.clear();
    notifyListeners();
  }

  // คำนวณสารอาหาร
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