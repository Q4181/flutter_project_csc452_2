import '../models/food.dart';
import '../services/api_service.dart';

class FoodRepository {
  final ApiService apiService;

  FoodRepository(this.apiService);

  Future<List<Food>> getFoodsWithNutrients() async {
    return await apiService.fetchFoodsWithNutrients();//ส่งapiเข้าprogram
  }
}