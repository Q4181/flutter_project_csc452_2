import 'package:flutter/material.dart';
import '../../data/models/food.dart';

class FoodForm extends StatefulWidget {
  final Food? food; // null สำหรับ Create, มีค่าเมื่อ Edit
  final Future<void> Function({
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
  }) onSubmit;

  const FoodForm({super.key, this.food, required this.onSubmit});

  @override
  _FoodFormState createState() => _FoodFormState();
}

class _FoodFormState extends State<FoodForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _foodNameController;
  late TextEditingController _categoryController;
  late TextEditingController _servingSizeController;
  late TextEditingController _imageUrlController;
  late TextEditingController _caloriesPerServingController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbohydratesController;
  late TextEditingController _fiberController;
  late TextEditingController _sugarController;
  late TextEditingController _sodiumController;

  @override
  void initState() {
    super.initState();
    _foodNameController = TextEditingController(text: widget.food?.foodName ?? '');
    _categoryController = TextEditingController(text: widget.food?.category ?? '');
    _servingSizeController = TextEditingController(text: widget.food?.servingSize ?? '');
    _imageUrlController = TextEditingController(text: widget.food?.imageUrl ?? '');
    _caloriesPerServingController = TextEditingController(text: '0'); // Default to 0
    _proteinController = TextEditingController(text: widget.food?.nutrient?.protein.toString() ?? '');
    _fatController = TextEditingController(text: widget.food?.nutrient?.fat.toString() ?? '');
    _carbohydratesController = TextEditingController(text: widget.food?.nutrient?.carbohydrates.toString() ?? '');
    _fiberController = TextEditingController(text: widget.food?.nutrient?.fiber.toString() ?? '');
    _sugarController = TextEditingController(text: widget.food?.nutrient?.sugar.toString() ?? '');
    _sodiumController = TextEditingController(text: widget.food?.nutrient?.sodium.toString() ?? '');
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _categoryController.dispose();
    _servingSizeController.dispose();
    _imageUrlController.dispose();
    _caloriesPerServingController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbohydratesController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.food == null ? 'Create Food' : 'Edit Food'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _servingSizeController,
                decoration: const InputDecoration(labelText: 'Serving Size'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL (Optional)'),
              ),
              TextFormField(
                controller: _caloriesPerServingController,
                decoration: const InputDecoration(labelText: 'Calories per Serving (kcal)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              const Text('Nutrients (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _fatController,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _carbohydratesController,
                decoration: const InputDecoration(labelText: 'Carbohydrates (g)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _fiberController,
                decoration: const InputDecoration(labelText: 'Fiber (g)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _sugarController,
                decoration: const InputDecoration(labelText: 'Sugar (g)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _sodiumController,
                decoration: const InputDecoration(labelText: 'Sodium (mg)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(
                foodId: widget.food?.foodId,
                foodName: _foodNameController.text,
                category: _categoryController.text,
                servingSize: _servingSizeController.text,
                imageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
                caloriesPerServing: double.tryParse(_caloriesPerServingController.text) ?? 0,
                nutrientId: widget.food?.nutrient?.nutrientId,
                protein: _proteinController.text.isEmpty ? null : double.tryParse(_proteinController.text),
                fat: _fatController.text.isEmpty ? null : double.tryParse(_fatController.text),
                carbohydrates: _carbohydratesController.text.isEmpty ? null : double.tryParse(_carbohydratesController.text),
                fiber: _fiberController.text.isEmpty ? null : double.tryParse(_fiberController.text),
                sugar: _sugarController.text.isEmpty ? null : double.tryParse(_sugarController.text),
                sodium: _sodiumController.text.isEmpty ? null : double.tryParse(_sodiumController.text),
              );
              Navigator.pop(context);
            }
          },
          child: Text(widget.food == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}