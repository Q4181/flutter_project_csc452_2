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
}