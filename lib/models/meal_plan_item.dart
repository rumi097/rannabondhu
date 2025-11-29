import 'package:hive/hive.dart';

part 'meal_plan_item.g.dart'; // Run build_runner

@HiveType(typeId: 2)
class MealPlanItem extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String mealType;

  @HiveField(2)
  String recipeId; // <-- CHANGED FROM INT TO STRING

  @HiveField(3)
  String recipeTitle;

  MealPlanItem({
    required this.date,
    required this.mealType,
    required this.recipeId,
    required this.recipeTitle,
  });
}