import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rannabondhu/models/recipe.dart';
import 'package:rannabondhu/providers/recipe_provider.dart';
import 'package:rannabondhu/utils/strings_bn.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();

  void _saveMyRecipe() {
    if (_formKey.currentState!.validate()) {
      // Convert text blocks to lists
      final ingredientsList = _ingredientsController.text
          .split('\n')
          .where((s) => s.isNotEmpty) // Remove empty lines
          .toList();
          
      final stepsList = _stepsController.text
          .split('\n')
          .where((s) => s.isNotEmpty) // Remove empty lines
          .toList();

      if (ingredientsList.isEmpty || stepsList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("দয়া করে উপকরণ ও প্রণালী লিখুন।")),
        );
        return;
      }

      // Create new Recipe object
      final newRecipe = Recipe(
        id: "custom_${DateTime.now().millisecondsSinceEpoch}", // Unique custom ID
        title: _titleController.text,
        description: _descController.text,
        ingredients: ingredientsList,
        steps: stepsList,
        region: "পারিবারিক", // "Family" recipe
      );
      
      // Save to Hive via provider
      context.read<RecipeProvider>().addRecipe(newRecipe);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.recipeSaved),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop(); // Go back
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.newRecipeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMyRecipe,
            tooltip: AppStrings.saveRecipe,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: AppStrings.recipeTitle,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: AppStrings.recipeDesc,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: AppStrings.ingredients,
                  hintText: AppStrings.ingredientsHint,
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stepsController,
                decoration: const InputDecoration(
                  labelText: AppStrings.steps,
                  hintText: AppStrings.stepsHint,
                  border: OutlineInputBorder(),
                ),
                maxLines: 12,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}