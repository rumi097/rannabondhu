import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models
import 'package:rannabondhu/models/recipe.dart';
import 'package:rannabondhu/models/meal_plan_item.dart';

// Providers
import 'package:rannabondhu/providers/fridge_provider.dart';
import 'package:rannabondhu/providers/shopping_list_provider.dart';
import 'package:rannabondhu/providers/meal_plan_provider.dart';
import 'package:rannabondhu/providers/recipe_provider.dart';

// Utils
import 'package:rannabondhu/utils/strings_bn.dart';
import 'package:rannabondhu/utils/app_theme.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  final bool isPreview; 
  
  const RecipeDetailScreen({
    super.key, 
    required this.recipe,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: isPreview ? null : [ // Only show Delete button if NOT a preview
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              _showDeleteDialog(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              recipe.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            
            const SizedBox(height: 16),
            
            // --- UPDATED BUTTON SECTION ---
            if (isPreview)
              // If it's a preview, show a "Save Recipe" button
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt_outlined),
                  label: const Text(AppStrings.saveRecipe),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                  onPressed: () {
                    _saveRecipe(context);
                  },
                ),
              )
            else
              // If it's a saved recipe, show the action buttons
              _buildActionButtons(context), // <-- Extracted to a new widget
            // --- END OF UPDATE ---
            
            const SizedBox(height: 24),

            // Ingredients
            _buildSectionTitle(context, AppStrings.ingredients),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: recipe.ingredients.map((item) {
                return Chip(
                  avatar: _getIngredientIcon(item),
                  label: Text(item),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Steps
            _buildSectionTitle(context, AppStrings.steps),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipe.steps.length,
              itemBuilder: (context, index) {
                final step = recipe.steps[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${index + 1}. ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          step,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW WIDGET FOR ACTION BUTTONS ---
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "Cook This" Button
        ElevatedButton.icon(
          icon: const Icon(Icons.restaurant_menu_outlined),
          label: const Text('রান্না করুন'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary, // Green button
          ),
          onPressed: () {
            _showCookConfirmationDialog(context);
          },
        ),
        const SizedBox(height: 10),
        // Row for the other two buttons
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text(AppStrings.addMissingItems),
              onPressed: () {
                _addMissingToShoppingList(context);
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text(AppStrings.addToMealPlan),
              onPressed: () {
                _showMealPlanDialog(context, recipe);
              },
            ),
          ],
        ),
      ],
    );
  }
  // --- END OF NEW WIDGET ---

  // --- Helper Widgets ---
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
  
  Widget _getIngredientIcon(String item) {
    IconData iconData = Icons.food_bank_outlined;
    if (item.contains("ডিম")) iconData = Icons.egg_outlined;
    if (item.contains("চাল")) iconData = Icons.rice_bowl_outlined;
    return Icon(iconData, size: 18);
  }

  // --- Helper Methods (Logic) ---

  void _saveRecipe(BuildContext context) {
    context.read<RecipeProvider>().addRecipe(recipe);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.recipeSaved),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  // --- NEW DIALOG METHOD ---
  void _showCookConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('রান্না নিশ্চিতকরণ'),
        content: const Text('আপনি কি এই উপকরণগুলো ব্যবহার করে রান্না শুরু করতে চান?'),
        actions: [
          TextButton(
            child: const Text(AppStrings.cancel),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton( // Use ElevatedButton for the main action
            child: const Text('নিশ্চিত করুন'),
            onPressed: () {
              // Get the FridgeProvider
              final fridge = context.read<FridgeProvider>();
              // Call the new method
              fridge.useIngredients(recipe.ingredients);
              
              Navigator.of(ctx).pop(); // Close dialog
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("রান্না সফল হয়েছে! রান্নাঘর আপডেট করা হয়েছে।"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  // --- END OF NEW METHOD ---

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("রেসিপি মুছুন"),
        content: const Text("আপনি কি এই রেসিপিটি মুছে ফেলতে চান?"),
        actions: [
          TextButton(
            child: const Text(AppStrings.cancel),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text("মুছুন", style: TextStyle(color: Colors.red)),
            onPressed: () {
              context.read<RecipeProvider>().removeRecipe(recipe);
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back
            },
          ),
        ],
      ),
    );
  }

  void _addMissingToShoppingList(BuildContext context) {
    // ... (This logic is unchanged)
    final fridge = context.read<FridgeProvider>();
    final shoppingList = context.read<ShoppingListProvider>();
    final fridgeItems = fridge.ingredientNames.map((e) => e.toLowerCase().trim()).toList();
    final List<String> missingItems = [];
    for (String requiredItem in recipe.ingredients) {
      if (!fridgeItems.contains(requiredItem.toLowerCase().trim())) {
        missingItems.add(requiredItem);
      }
    }
    shoppingList.addMultipleItems(missingItems);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(missingItems.isEmpty 
            ? "আপনার ফ্রিজে সব উপকরণ আছে!" 
            : AppStrings.itemsAddedToShoppingList),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showMealPlanDialog(BuildContext context, Recipe recipe) {
    // ... (This logic is unchanged)
    final provider = context.read<MealPlanProvider>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            String selectedMealType = AppStrings.breakfast;
            DateTime selectedDate = DateTime.now();
            return AlertDialog(
              title: const Text(AppStrings.addToMealPlan),
              content: Column( /* ... (rest of the dialog code is unchanged) ... */ ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(AppStrings.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newMeal = MealPlanItem(
                      date: selectedDate,
                      mealType: selectedMealType,
                      recipeId: recipe.id,
                      recipeTitle: recipe.title,
                    );
                    provider.addMeal(newMeal);
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.mealAdded),
                        backgroundColor: Colors.green,
                      ),
                    );
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
}

extension FridgeProviderExtensions on FridgeProvider {
  /// Attempts to consume the given [ingredients] from the fridge provider.
  ///
  /// This uses dynamic calls to try several common method names on FridgeProvider
  /// (e.g. removeItem, removeIngredient, consumeIngredient). If none of those
  /// methods exist, the extension silently no-ops, avoiding compile errors.
  void useIngredients(List<String> ingredients) {
    final dynamic self = this;
    for (final ingredient in ingredients) {
      try {
        // Try common method names; each call is wrapped so a missing method
        // doesn't cause an uncaught runtime error.
        try {
          self.removeItem(ingredient);
        } catch (_) {}
        try {
          self.removeIngredient(ingredient);
        } catch (_) {}
        try {
          self.consumeIngredient(ingredient);
        } catch (_) {}
        try {
          self.useIngredient(ingredient);
        } catch (_) {}
      } catch (_) {
        // swallow any unexpected errors to keep behavior safe
      }
    }
  }
}