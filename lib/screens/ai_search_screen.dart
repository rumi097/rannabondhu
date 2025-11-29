// lib/screens/ai_search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rannabondhu/models/recipe.dart';
import 'package:rannabondhu/providers/fridge_provider.dart';
import 'package:rannabondhu/services/api_service.dart';
import 'package:rannabondhu/utils/strings_bn.dart';
import 'package:rannabondhu/widgets/recipe_card.dart';
import 'package:rannabondhu/screens/recipe_detail_screen.dart'; // <-- ADD THIS IMPORT

class AiSearchScreen extends StatefulWidget {
  const AiSearchScreen({super.key});

  @override
  State<AiSearchScreen> createState() => _AiSearchScreenState();
}

class _AiSearchScreenState extends State<AiSearchScreen> {
  final ApiService _apiService = ApiService();
  final _searchController = TextEditingController();
  
  bool _useFridge = true;
  bool _isLoading = false;
  Recipe? _generatedRecipe;

  Future<void> _generateRecipe() async {
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("দয়া করে কিছু একটা অনুসন্ধান করুন।")),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _generatedRecipe = null;
    });
    
    String prompt = _searchController.text;
    
    if (_useFridge) {
      final fridgeItems = context.read<FridgeProvider>().ingredientNames;
      if (fridgeItems.isNotEmpty) {
        prompt += " using ingredients like: ${fridgeItems.join(', ')}";
      }
    }
    
    try {
      final recipe = await _apiService.generateRecipe(prompt);
      setState(() {
        _generatedRecipe = recipe;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("AI রেসিপি তৈরি করতে পারেনি: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // We removed the _saveRecipe() function from here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.suggestionsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Search Area ---
            Text(
              AppStrings.aiSearchPrompt,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: AppStrings.aiSearchHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            CheckboxListTile(
              title: const Text(AppStrings.aiUseFridge),
              value: _useFridge,
              onChanged: (bool? value) {
                setState(() {
                  _useFridge = value ?? true;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateRecipe,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(AppStrings.aiSearchButton),
            ),
            
            const Divider(height: 40),
            
            // --- Result Area ---
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(AppStrings.aiGenerating, textAlign: TextAlign.center),
                  ],
                ),
              ),
            
            // --- THIS SECTION IS UPDATED ---
            if (_generatedRecipe != null)
              Column(
                children: [
                  Text(
                    "AI-এর তৈরি রেসিপি",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  RecipeCard(
                    recipe: _generatedRecipe!,
                    onTap: () {
                      // THIS IS THE FIX:
                      // Navigate to the detail screen in "preview" mode
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(
                            recipe: _generatedRecipe!,
                            isPreview: true, // <-- Pass the new "isPreview" flag
                          ),
                        ),
                      );
                    },
                  ),
                  // The "Save Recipe" button is no longer here
                ],
              ),
            // --- END OF UPDATE ---
          ],
        ),
      ),
    );
  }
}