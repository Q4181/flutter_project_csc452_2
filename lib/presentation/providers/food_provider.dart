import 'package:flutter/material.dart';
import '../../data/models/food.dart';
import '../../data/repositories/food_repository.dart';
import '../../data/services/api_service.dart';

class FoodProvider with ChangeNotifier {//เป็นstateเวลาพวกอาหาร(อยู่ในprogram cant see)
  final FoodRepository _foodRepository;
  List<Food> _foods = [];
  List<Food> _selectedFoods = [];
  bool _isLoading = false;
  String? _error;//เป็นstateต่างๆ(มีไว้checkเฉยๆไม่มีก็ได้ถ้าไม่ต้องการ)
                          //   <-------
  FoodProvider() : _foodRepository = FoodRepository(ApiService());
//getter
  List<Food> get foods => _foods;
  List<Food> get selectedFoods => _selectedFoods;
  bool get isLoading => _isLoading;
  String? get error => _error;

// ดึงข้อมูลอาหารจาก repository
  Future<void> fetchFoods() async {
    _isLoading = true;
    notifyListeners();
    try {           //|-------------Repository-------------|
      _foods = await _foodRepository.getFoodsWithNutrients();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
//selection food มีผลกับcheckboxใน  ้นทำ
  void toggleFoodSelection(Food food) {
    if (_selectedFoods.contains(food)) {
      _selectedFoods.remove(food);
    } else {
      _selectedFoods.add(food);
    }
    notifyListeners();
  }

  Map<String, double> calculateTotalNutrients() {// cal nutrients selection
    double protein = 0;//add nutrients
    double fat = 0;
    double carbohydrates = 0;
    double fiber = 0;
    double sugar = 0;
    double sodium = 0;

    for (var food in _selectedFoods) {//cal select
      if (food.nutrient != null) {
        protein += food.nutrient!.protein;
        fat += food.nutrient!.fat;
        carbohydrates += food.nutrient!.carbohydrates;
        fiber += food.nutrient!.fiber;
        sugar += food.nutrient!.sugar;
        sodium += food.nutrient!.sodium;
      }
    }

    return { // ส่งกลับ
      'protein': protein,
      'fat': fat,
      'carbohydrates': carbohydrates,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
    };
  }
}