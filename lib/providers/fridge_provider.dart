import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rannabondhu/models/ingredient.dart';
import 'dart:collection';

class FridgeProvider extends ChangeNotifier {
  final Box<Ingredient> _fridgeBox = Hive.box<Ingredient>('fridgeBox');
  
  List<Ingredient> get ingredients => _fridgeBox.values.toList();
  
  // ... (expiringSoon, ingredientNames, groupedIngredients logic unchanged) ...
  List<Ingredient> get expiringSoon {
    final now = DateTime.now();
    return _fridgeBox.values.where((item) {
      if (item.expiryDate == null) return false; 
      return item.expiryDate!.isAfter(now) && 
             item.expiryDate!.difference(now).inDays <= 3;
    }).toList();
  }
  List<String> get ingredientNames => _fridgeBox.values.map((i) => i.name).toList();
  Map<String, List<Ingredient>> get groupedIngredients {
    final Map<String, List<Ingredient>> map = {};
    for (final item in ingredients) {
      if (map.containsKey(item.category)) {
        map[item.category]!.add(item);
      } else {
        map[item.category] = [item];
      }
    }
    return SplayTreeMap<String, List<Ingredient>>.from(
      map, (a, b) => a.compareTo(b)
    );
  }

  // --- UPDATED: addIngredient ---
  // This method no longer handles any price logic
  Future<void> addIngredient(Ingredient ingredient) async {
    final existing = ingredients.where((i) => i.name.toLowerCase() == ingredient.name.toLowerCase());
    if (existing.isEmpty) {
      await _fridgeBox.add(ingredient);
    } else {
      final existingItem = existing.first;
      existingItem.quantity = (existingItem.quantity ?? 0) + (ingredient.quantity ?? 0);
      existingItem.unit = ingredient.unit ?? existingItem.unit;
      existingItem.expiryDate = ingredient.expiryDate ?? existingItem.expiryDate;
      existingItem.category = ingredient.category;
      await existingItem.save();
    }
    notifyListeners();
  }

  // --- UPDATED: removeIngredient ---
  // This method no longer handles any price logic
  Future<void> removeIngredient(Ingredient ingredient) async {
    await ingredient.delete();
    notifyListeners();
  }
    
  // --- UPDATED: incrementQuantity ---
  // Now takes a specific amount to add (for restocking)
  Future<void> incrementQuantity(Ingredient item, double quantityToAdd) async {
    item.quantity = (item.quantity ?? 0) + quantityToAdd;
    await item.save();
    notifyListeners();
  }
  
  // --- UPDATED: decrementQuantity ---
  // This logic is simple, as requested. No price calculation.
  Future<void> decrementQuantity(Ingredient item) async {
    item.quantity = (item.quantity ?? 1) - 1;
    if (item.quantity! <= 0) {
      await item.delete();
    } else {
      await item.save();
    }
    notifyListeners();
  }
}