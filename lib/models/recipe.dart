import 'package:hive/hive.dart';

part 'recipe.g.dart'; // Run build_runner after this

@HiveType(typeId: 3)
class Recipe extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<String> ingredients;

  @HiveField(4)
  List<String> steps;

  @HiveField(5)
  String? region;

  @HiveField(6)
  String? cookTime;

  @HiveField(7)
  String? calories;
  
  // --- FIELD 8 (imageUrl) IS NOW REMOVED ---

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    this.region,
    this.cookTime,
    this.calories,
  });

  // Factory to create a Recipe from the AI's JSON
  factory Recipe.fromAiJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title_bn'] ?? 'নামহীন রেসিপি',
      description: json['description_bn'] ?? 'কোনো বিবরণ নেই।',
      ingredients: List<String>.from(json['ingredients_bn'] ?? []),
      steps: List<String>.from(json['steps_bn'] ?? ['প্রণালী নেই।']),
      region: json['region_bn'],
      cookTime: json['cook_time_bn'],
      calories: json['calories_bn'],
      // imageUrl is no longer here
    );
  }
}