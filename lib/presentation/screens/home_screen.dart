import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../widgets/food_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (foodProvider.foods.isEmpty && !foodProvider.isLoading) {
        foodProvider.fetchFoods();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Nutrient Tracker'),
      ),
      body: Consumer<FoodProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          if (provider.foods.isEmpty) {
            return const Center(child: Text('No foods available'));
          }
          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: provider.foods.length,
                  itemBuilder: (context, index) {
                    final food = provider.foods[index];
                    return FoodCard(
                      food: food,
                      isSelected: provider.selectedFoods.contains(food),
                      onTap: () => provider.toggleFoodSelection(food),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    final totals = provider.calculateTotalNutrients();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Total Nutrients'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Protein: ${totals['protein']!.toStringAsFixed(1)} g'),
                            Text('Fat: ${totals['fat']!.toStringAsFixed(1)} g'),
                            Text('Carbohydrates: ${totals['carbohydrates']!.toStringAsFixed(1)} g'),
                            Text('Fiber: ${totals['fiber']!.toStringAsFixed(1)} g'),
                            Text('Sugar: ${totals['sugar']!.toStringAsFixed(1)} g'),
                            Text('Sodium: ${totals['sodium']!.toStringAsFixed(1)} mg'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Calculate Nutrients'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}