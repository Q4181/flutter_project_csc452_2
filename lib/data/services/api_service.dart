import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food.dart';
import '../../constants.dart';

class ApiService {//import api to use this program
  Future<List<Food>> fetchFoodsWithNutrients() async {//cheack api work?
    final response = await http.get(Uri.parse('${Constants.apiBaseUrl}/foods/nutrients'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Food.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load foods: ${response.statusCode}');
    }
  }
}