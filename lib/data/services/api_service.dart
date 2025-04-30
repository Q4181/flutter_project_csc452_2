import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food.dart';
import '../../constants.dart';

class ApiService {
  Future<List<Food>> fetchFoodsWithNutrients() async {
    final response = await http.get(Uri.parse('${Constants.apiBaseUrl}/foods/nutrients'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Food.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load foods: ${response.statusCode}');
    }
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
    final foodResponse = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/foods'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'food_name': foodName,
        'category': category,
        'serving_size': servingSize,
        'image_url': imageUrl,
        'calories_per_serving': caloriesPerServing,
      }),
    );

    if (foodResponse.statusCode != 201) {
      throw Exception('Failed to create food: ${foodResponse.body}');
    }

    final foodData = json.decode(foodResponse.body);
    final foodId = foodData['food_id'];

    if (protein != null || fat != null || carbohydrates != null || fiber != null || sugar != null || sodium != null) {
      final nutrientResponse = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/nutrients'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'food_id': foodId,
          'protein': protein ?? 0,
          'fat': fat ?? 0,
          'carbohydrates': carbohydrates ?? 0,
          'fiber': fiber ?? 0,
          'sugar': sugar ?? 0,
          'sodium': sodium ?? 0,
        }),
      );

      if (nutrientResponse.statusCode != 201) {
        throw Exception('Failed to create nutrient: ${nutrientResponse.body}');
      }
    }
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
    final foodResponse = await http.put(
      Uri.parse('${Constants.apiBaseUrl}/foods/$foodId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'food_name': foodName,
        'category': category,
        'serving_size': servingSize,
        'image_url': imageUrl,
        'calories_per_serving': caloriesPerServing,
      }),
    );

    if (foodResponse.statusCode != 200) {
      throw Exception('Failed to update food: ${foodResponse.body}');
    }

    if (nutrientId != null) {
      final nutrientResponse = await http.put(
        Uri.parse('${Constants.apiBaseUrl}/nutrients/$nutrientId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'food_id': foodId,
          'protein': protein ?? 0,
          'fat': fat ?? 0,
          'carbohydrates': carbohydrates ?? 0,
          'fiber': fiber ?? 0,
          'sugar': sugar ?? 0,
          'sodium': sodium ?? 0,
        }),
      );

      if (nutrientResponse.statusCode != 200) {
        throw Exception('Failed to update nutrient: ${nutrientResponse.body}');
      }
    }
  }

  Future<void> deleteFood(int foodId) async {
    final response = await http.delete(
      Uri.parse('${Constants.apiBaseUrl}/foods/$foodId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete food: ${response.body}');
    }
  }
}