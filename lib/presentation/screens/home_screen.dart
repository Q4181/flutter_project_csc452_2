import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../widgets/food_card.dart';
import '../widgets/food_form.dart';

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
        backgroundColor: Color.fromARGB(255, 148, 67, 230),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Consumer<FoodProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.error != null) {
                return Center(child: Text('Error: ${provider.error}'));
              }
              if (provider.foods.isEmpty && provider.selectedCategory == 'All') {
                return const Center(child: Text('No foods available'));
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButton<String>(
                      value: provider.selectedCategory,
                      isExpanded: true,
                      hint: const Text('Select Category'),
                      items: provider.categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.selectCategory(value);
                        }
                      },
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  if (provider.foods.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No foods in this category',
                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.9,
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
                            content: SingleChildScrollView(
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
                                  if (provider.selectedFoods.isEmpty)
                                    const Text(
                                      'No foods selected',
                                      style: TextStyle(fontStyle: FontStyle.italic),
                                    )
                                  else
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: provider.selectedFoods.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final food = entry.value;
                                        return Text(
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
          // ปุ่ม Create, Edit, Delete (แนวนอน, ล่างซ้าย)
          Positioned(
            bottom: 16,
            left: 16,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => FoodForm(
                        onSubmit: ({
                          required String foodName,
                          required String category,
                          required String servingSize,
                          String? imageUrl,
                          int? foodId,
                          int? nutrientId,
                          double? caloriesPerServing,
                          double? protein,
                          double? fat,
                          double? carbohydrates,
                          double? fiber,
                          double? sugar,
                          double? sodium,
                        }) async {
                          try {
                            await foodProvider.createFood(
                              foodName: foodName,
                              category: category,
                              servingSize: servingSize,
                              caloriesPerServing: caloriesPerServing ?? 0,
                              imageUrl: imageUrl,
                              protein: protein,
                              fat: fat,
                              carbohydrates: carbohydrates,
                              fiber: fiber,
                              sugar: sugar,
                              sodium: sodium,
                            );
                          } catch (e) {
                            // ไม่แสดง SnackBar
                          }
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Create',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                   onPressed: () {
                    if (foodProvider.selectedFoods.isEmpty) {
                      return;
                    }
                    if (foodProvider.selectedFoods.length > 1) {
                      return;
                    }        
                    final food = foodProvider.selectedFoods.first;
                    showDialog(
                      context: context,
                      builder: (context) => FoodForm(
                        food: food,
                        onSubmit: ({
                          required String foodName,
                          required String category,
                          required String servingSize,
                          String? imageUrl,
                          int? foodId,
                          int? nutrientId,
                          double? caloriesPerServing,
                          double? protein,
                          double? fat,
                          double? carbohydrates,
                          double? fiber,
                          double? sugar,
                          double? sodium,
                        }) async {
                          try {
                            await foodProvider.updateFood(
                              foodId: foodId!,
                              foodName: foodName,
                              category: category,
                              servingSize: servingSize,
                              caloriesPerServing: caloriesPerServing ?? 0,
                              imageUrl: imageUrl,
                              nutrientId: nutrientId,
                              protein: protein,
                              fat: fat,
                              carbohydrates: carbohydrates,
                              fiber: fiber,
                              sugar: sugar,
                              sodium: sodium,
                            );
                          } catch (e) {
                            // ไม่แสดง SnackBar
                          }
                        },
                      ),
                    );
                    foodProvider.clearSelectedFoods();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Edit',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (foodProvider.selectedFoods.isEmpty) {
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: Text(
                          'Are you sure you want to delete ${foodProvider.selectedFoods.length} food(s)?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                for (var food in foodProvider.selectedFoods) {
                                  await foodProvider.deleteFood(food.foodId);
                                }
                                Navigator.pop(context);
                              } catch (e) {
                                // ไม่แสดง SnackBar
                              }
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ปุ่ม Clear (ขวาล่าง)
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                if (foodProvider.selectedFoods.isEmpty) {
                  return;
                }
                foodProvider.clearSelectedFoods();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Clear',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}