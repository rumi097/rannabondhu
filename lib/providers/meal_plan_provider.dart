// lib/providers/meal_plan_provider.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rannabondhu/models/meal_plan_item.dart';

class MealPlanProvider extends ChangeNotifier {
  final Box<MealPlanItem> _mealPlanBox = Hive.box<MealPlanItem>('mealPlanBox');
  
  List<MealPlanItem> get allMeals => _mealPlanBox.values.toList();

  // Get meals for a specific date
  List<MealPlanItem> getMealsForDate(DateTime date) {
    return _mealPlanBox.values.where((meal) {
      // Compare year, month, and day only
      return meal.date.year == date.year &&
             meal.date.month == date.month &&
             meal.date.day == date.day;
    }).toList();
  }

  Future<void> addMeal(MealPlanItem meal) async {
    await _mealPlanBox.add(meal);
    notifyListeners();
  }

  Future<void> removeMeal(MealPlanItem meal) async {
    await meal.delete();
    notifyListeners();
  }
}