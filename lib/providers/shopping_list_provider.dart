import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rannabondhu/models/shopping_item.dart';
import 'package:rannabondhu/utils/strings_bn.dart';

class ShoppingListProvider extends ChangeNotifier {
  final Box<ShoppingItem> _shoppingBox = Hive.box<ShoppingItem>('shoppingListBox');

  List<ShoppingItem> get items => _shoppingBox.values.toList();

  // --- UPDATED: addItem ---
  // This method no longer handles any price logic
  Future<void> addItem(String name, {String? quantity, String? unit, String category = AppStrings.categoryOther}) async {
    final exists = items.any((item) => item.name.toLowerCase() == name.toLowerCase());
    
    if (!exists) {
      await _shoppingBox.add(ShoppingItem(
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
      ));
      notifyListeners();
    }
  }
  
  Future<void> addMultipleItems(List<String> names) async {
    final currentItemNames = items.map((item) => item.name.toLowerCase()).toList();
    
    for (String name in names) {
      if (!currentItemNames.contains(name.toLowerCase())) {
        await _shoppingBox.add(ShoppingItem(name: name));
      }
    }
    notifyListeners();
  }

  // --- UPDATED: removeItem ---
  // This method no longer handles any price logic
  Future<void> removeItem(ShoppingItem item) async {
    await item.delete();
    notifyListeners();
  }

  Future<void> toggleChecked(ShoppingItem item) async {
    item.isChecked = !item.isChecked;
    await item.save();
    notifyListeners();
  }
  
  // --- UPDATED: clearCheckedItems ---
  // This method no longer handles any price logic
  Future<void> clearCheckedItems() async {
    final List<ShoppingItem> checkedItems = items.where((item) => item.isChecked).toList();
    for (var item in checkedItems) {
      await item.delete();
    }
    notifyListeners();
  }
}