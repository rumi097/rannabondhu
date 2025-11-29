import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rannabondhu/models/meal_plan_item.dart';
import 'package:rannabondhu/providers/meal_plan_provider.dart';
import 'package:rannabondhu/providers/recipe_provider.dart';
import 'package:rannabondhu/screens/recipe_detail_screen.dart';
import 'package:rannabondhu/utils/strings_bn.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('bn', 'BD'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch both providers
    final planProvider = context.watch<MealPlanProvider>();
    final recipeProvider = context.read<RecipeProvider>();
    
    final mealsForDay = planProvider.getMealsForDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.mealPlannerTitle),
      ),
      body: Column(
        children: [
          // Date Picker Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd MMMM, yyyy', 'bn_BD').format(_selectedDate),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ],
            ),
          ),
          const Divider(),
          // List of meals
          Expanded(
            child: mealsForDay.isEmpty
                ? const Center(child: Text(AppStrings.mealPlannerEmpty))
                : ListView.builder(
                    itemCount: mealsForDay.length,
                    itemBuilder: (context, index) {
                      final meal = mealsForDay[index];
                      // Find the full recipe from the RecipeProvider
                      final recipe = recipeProvider.getRecipeById(meal.recipeId);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(meal.recipeTitle),
                          subtitle: Text(meal.mealType),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              planProvider.removeMeal(meal);
                            },
                          ),
                          // Only allow tapping if it's a real recipe
                          onTap: (recipe == null) ? null : () {
                            // Go to the recipe details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailScreen(recipe: recipe),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // --- ADD THIS FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCustomPlanDialog(context, planProvider, _selectedDate);
        },
        tooltip: AppStrings.addCustomPlan,
        child: const Icon(Icons.add),
      ),
      // --- END OF ADDITION ---
    );
  }

  // --- ADD THIS NEW DIALOG METHOD ---
  void _showAddCustomPlanDialog(BuildContext context, MealPlanProvider provider, DateTime date) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController mealController = TextEditingController();
    String selectedMealType = AppStrings.breakfast; // Default

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(AppStrings.addCustomPlan),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meal Name
                    TextFormField(
                      controller: mealController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.mealName,
                        hintText: AppStrings.mealNameHint,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.fieldRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Meal Type Picker
                    Text("${AppStrings.selectMealType}:"),
                    DropdownButton<String>(
                      value: selectedMealType,
                      isExpanded: true,
                      items: [AppStrings.breakfast, AppStrings.lunch, AppStrings.dinner]
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedMealType = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(AppStrings.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newMeal = MealPlanItem(
                        date: date,
                        mealType: selectedMealType,
                        // Use a special ID for custom items
                        recipeId: "custom_${DateTime.now().millisecondsSinceEpoch}", 
                        recipeTitle: mealController.text,
                      );
                      
                      provider.addMeal(newMeal);
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text(AppStrings.add),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // --- END OF NEW METHOD ---
}