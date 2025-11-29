// lib/providers/recipe_provider.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rannabondhu/models/recipe.dart';

class RecipeProvider extends ChangeNotifier {
  final Box<Recipe> _recipeBox = Hive.box<Recipe>('recipeBox');
  
  List<Recipe> get allRecipes => _recipeBox.values.toList();
  
  Future<void> addRecipe(Recipe recipe) async {
    // Hive uses an auto-incrementing int key by default
    // Or we can use our own string key (recipe.id)
    await _recipeBox.put(recipe.id, recipe);
    notifyListeners();
  }

  Future<void> removeRecipe(Recipe recipe) async {
    await recipe.delete();
    notifyListeners();
  }
  
  // Helper to find a recipe by its ID (for the meal planner)
  Recipe? getRecipeById(String id) {
    return _recipeBox.get(id);
  }
}