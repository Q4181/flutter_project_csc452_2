import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../widgets/food_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {//ui widget
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (foodProvider.foods.isEmpty && !foodProvider.isLoading) {
        foodProvider.fetchFoods();//import food in ui
      }
    });

    return Scaffold(
      appBar: AppBar(//bar UI
        title: const Text(
          'Food Nutrient Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Color.fromARGB(255, 137, 208, 121),
        foregroundColor: Colors.white,
      ),
      body: Consumer<FoodProvider>(//UI state(loading,error,els)
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
                  padding: const EdgeInsets.all(12),//spase around card
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, //row
                    crossAxisSpacing: 10, //space layout x
                    mainAxisSpacing: 10,  //space layout y 
                    childAspectRatio: 0.9,
                  ),
                  itemCount: provider.foods.length,//create length
                  itemBuilder: (context, index) {//create food
                    final food = provider.foods[index];
                    return FoodCard(//out ui food card
                      food: food,
                      isSelected: provider.selectedFoods.contains(food),
                      onTap: () => provider.toggleFoodSelection(food),
                    );
                  },
                ),
              ),
              Padding(//button cal Ui
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ElevatedButton(
                  onPressed: () {
                    final totals = provider.calculateTotalNutrients();//cal
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Total Nutrients',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: SingleChildScrollView(//backup case so mush food in cal
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selected Foods:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (provider.selectedFoods.isEmpty)//case not select food
                                const Text(
                                  'No foods selected',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                )
                              else//case have food
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: provider.selectedFoods.asMap().entries.map((entry) {//ดึงอาหาร
                                    final index = entry.key;
                                    final food = entry.value;
                                    return Text(//show food select
                                      '${index + 1}. ${food.foodName}',
                                      style: const TextStyle(fontSize: 14),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 16),
                              const Text(
                                'Nutrient Totals:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Protein: ${totals['protein']!.toStringAsFixed(1)} g'),
                              Text('Fat: ${totals['fat']!.toStringAsFixed(1)} g'),
                              Text('Carbohydrates: ${totals['carbohydrates']!.toStringAsFixed(1)} g'),
                              Text('Fiber: ${totals['fiber']!.toStringAsFixed(1)} g'),
                              Text('Sugar: ${totals['sugar']!.toStringAsFixed(1)} g'),
                              Text('Sodium: ${totals['sodium']!.toStringAsFixed(1)} mg'),
                            ],
                          ),
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
                  style: ElevatedButton.styleFrom(//ui button OK
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