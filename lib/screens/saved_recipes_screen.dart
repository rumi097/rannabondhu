import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rannabondhu/providers/recipe_provider.dart';
import 'package:rannabondhu/utils/strings_bn.dart';
import 'package:rannabondhu/screens/recipe_detail_screen.dart';
import 'package:rannabondhu/screens/create_recipe_screen.dart';
import 'package:rannabondhu/widgets/recipe_card.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.localRecipesTitle), // "সংরক্ষিত রেসিপি"
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          
          if (provider.allRecipes.isEmpty) {
            return const Center(child: Text(AppStrings.noRecipesFound));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.allRecipes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final recipe = provider.allRecipes[index];
              
              return RecipeCard(
                recipe: recipe,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Pass 'isPreview: false' (which is the default)
                      builder: (context) => RecipeDetailScreen(recipe: recipe),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      // --- THIS FAB IS UPDATED ---
      // This button is for adding your *own* manual recipes
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateRecipeScreen()),
          );
        },
        tooltip: AppStrings.addMyRecipe,
        child: const Icon(Icons.add),
      ),
      // --- END OF UPDATE ---
    );
  }
}