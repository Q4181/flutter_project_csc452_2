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
        backgroundColor: Color.fromARGB(255, 230, 67, 67),
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
          if (provider.foods.isEmpty && provider.selectedCategory == 'All') {
            return const Center(child: Text('No foods available'));
          }

          return Column(
            children: [
              // Dropdown สำหรับเลือกหมวดหมู่
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
              // FilterChip สำหรับเลือกหมวดหมู่ (ทางเลือกเสริม)
              /*
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: provider.categories.map((category) {
                    return FilterChip(
                      label: Text(category),
                      selected: provider.selectedCategory == category,
                      onSelected: (selected) {
                        provider.selectCategory(category);
                      },
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                    );
                  }).toList(),
                ),
              ),
              */
              // แสดงข้อความเมื่อไม่มีอาหารในหมวดหมู่
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
                    crossAxisCount: 4,
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
    );
  }
}