// lib/screens/recipe_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:rannabondhu/screens/ai_search_screen.dart';
import 'package:rannabondhu/screens/saved_recipes_screen.dart';
import 'package:rannabondhu/utils/strings_bn.dart';
import 'package:rannabondhu/utils/app_theme.dart';

class RecipeHubScreen extends StatelessWidget {
  const RecipeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navRecipes), // "রেসিপি"
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Button 1: AI Recipe Search ---
            _buildHubCard(
              context: context,
              icon: Icons.smart_toy_outlined,
              title: AppStrings.suggestionsTitle, // "AI রেসিপি অনুসন্ধান"
              subtitle: "নতুন রেসিপি খুঁজে বের করুন এবং সংরক্ষণ করুন।",
              color: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AiSearchScreen()),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // --- Button 2: Saved Recipes ---
            _buildHubCard(
              context: context,
              icon: Icons.menu_book_outlined,
              title: AppStrings.localRecipesTitle, // "সংরক্ষিত রেসিপি"
              subtitle: "আপনার নিজের এবং সেভ করা রেসিপিগুলো দেখুন।",
              color: AppColors.secondary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedRecipesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the tappable cards
  Widget _buildHubCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}