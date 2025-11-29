// lib/models/ai_recipe_suggestion.dart

class AiRecipeSuggestion {
  final String title;
  final String description;
  final List<String> ingredientsNeeded;
  final List<String> missingItems;

  AiRecipeSuggestion({
    required this.title,
    required this.description,
    required this.ingredientsNeeded,
    required this.missingItems,
  });

  factory AiRecipeSuggestion.fromJson(Map<String, dynamic> json) {
    return AiRecipeSuggestion(
      title: json['title_bn'] ?? 'নাম নেই',
      description: json['description_bn'] ?? '',
      ingredientsNeeded: List<String>.from(json['ingredients_needed_bn'] ?? []),
      missingItems: List<String>.from(json['missing_items_bn'] ?? []),
    );
  }
}