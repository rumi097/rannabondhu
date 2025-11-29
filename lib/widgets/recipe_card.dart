// lib/widgets/recipe_card.dart
import 'package:flutter/material.dart';
import 'package:rannabondhu/models/recipe.dart';
import 'package:rannabondhu/utils/app_theme.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // The subtle shadow
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0), // Match card shape
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralShadow.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        // CardTheme from app_theme.dart handles the shape and border
        clipBehavior: Clip.antiAlias, // Clips the image to the rounded corners
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // --- THE IMAGE SECTION IS NOW REMOVED ---
              
              // Recipe Title and Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Tomato Red" Accent Badge
                    if (recipe.region != null && recipe.region!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Chip(
                          label: Text(recipe.region!),
                          backgroundColor: AppColors.accent.withOpacity(0.1),
                          labelStyle: const TextStyle(color: AppColors.accent),
                        ),
                      ),
                    
                    Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    // Info Chips
                    Row(
                      children: [
                        if (recipe.cookTime != null)
                          _buildInfoChip(
                            context,
                            Icons.timer_outlined,
                            recipe.cookTime!,
                          ),
                        const SizedBox(width: 8),
                        if (recipe.calories != null)
                          _buildInfoChip(
                            context,
                            Icons.local_fire_department_outlined,
                            recipe.calories!,
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the info chips
  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}