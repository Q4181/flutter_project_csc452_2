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
        title: const Text(
          'Food Nutrient Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
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
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Changed from 2 to 4 for 4 cards per row
                    crossAxisSpacing: 10, // Reduced for denser layout
                    mainAxisSpacing: 10, // Reduced for denser layout
                    childAspectRatio: 0.9, // Adjusted for smaller, balanced cards
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ElevatedButton(
                  onPressed: () {
                    final totals = provider.calculateTotalNutrients();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Total Nutrients',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Calculate Nutrients',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}