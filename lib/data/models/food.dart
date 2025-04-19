class Food {
  final int foodId;
  final String foodName;
  final String category;
  final String servingSize;
  final String imageUrl;
  final Nutrient? nutrient;

  Food({
    required this.foodId,
    required this.foodName,
    required this.category,
    required this.servingSize,
    required this.imageUrl,
    this.nutrient,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      foodId: json['food_id'],
      foodName: json['food_name'],
      category: json['category'],
      servingSize: json['serving_size'],
      imageUrl: json['image_url'] ?? 'https://via.placeholder.com/150',
      nutrient: json['nutrient_id'] != null
          ? Nutrient.fromJson(json)
          : null,
    );
  }
}

class Nutrient {
  final int nutrientId;
  final int foodId;
  final double protein;
  final double fat;
  final double carbohydrates;
  final double fiber;
  final double sugar;
  final double sodium;

  Nutrient({
    required this.nutrientId,
    required this.foodId,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    required this.fiber,
    required this.sugar,
    required this.sodium,
  });

  factory Nutrient.fromJson(Map<String, dynamic> json) {
    return Nutrient(
      nutrientId: json['nutrient_id'],
      foodId: json['food_id'],
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
      sodium: (json['sodium'] as num).toDouble(),
    );
  }
}