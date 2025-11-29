import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rannabondhu/models/ingredient.dart';
import 'package:rannabondhu/providers/fridge_provider.dart';
import 'package:rannabondhu/providers/expense_provider.dart';
import 'package:rannabondhu/utils/strings_bn.dart';
import 'package:rannabondhu/utils/app_theme.dart';

class FridgeScreen extends StatelessWidget {
  const FridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the provider here, so it's available for the list builder
    final fridgeProvider = context.watch<FridgeProvider>();
    final grouped = fridgeProvider.groupedIngredients;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.fridgeTitle),
      ),
      body: grouped.isEmpty
          ? const Center(child: Text(AppStrings.fridgeIsEmpty))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: grouped.keys.length,
              itemBuilder: (context, index) {
                final category = grouped.keys.elementAt(index);
                final items = grouped[category]!;
                // We pass the provider *and* context down to the next widget
                return _buildCategorySection(context, category, items, fridgeProvider);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddIngredientDialog(context);
        },
        child: const Icon(Icons.add),
        tooltip: AppStrings.addIngredient,
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String category, List<Ingredient> items, FridgeProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        color: AppColors.backgroundLight,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const Divider(),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  // Pass the context and provider down again
                  return _buildIngredientItem(context, items[index], provider);
                },
                separatorBuilder: (context, index) => const SizedBox(height: 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildIngredientItem(BuildContext context, Ingredient item, FridgeProvider provider) {
    final expiry = item.expiryDate == null 
        ? null 
        : DateFormat('dd MMM, yyyy', 'bn_BD').format(item.expiryDate!);
        
    final isExpiring = provider.expiringSoon.contains(item);
    
    return Container(
      decoration: BoxDecoration(
        color: isExpiring ? Colors.red.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: expiry != null ? Text(
          "${AppStrings.expiresOn} $expiry",
          style: TextStyle(
            fontSize: 12, 
            color: isExpiring ? AppColors.accent : AppColors.textSecondary,
          ),
        ) : null,
        
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- THIS IS THE FIX ---
            IconButton(
              onPressed: () {
                provider.decrementQuantity(item);
              },
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.accent),
              padding: EdgeInsets.zero,
            ),
            // --- END OF FIX ---
            
            Text(
              "${item.quantity ?? 0} ${item.unit ?? ''}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            
            IconButton(
              onPressed: () {
                 _showRestockDialog(context, item);
              },
              icon: const Icon(Icons.add_circle_outline, color: AppColors.secondary),
              padding: EdgeInsets.zero,
            ),
            
            // --- THIS IS THE FIX ---
            IconButton(
              onPressed: () {
                provider.removeIngredient(item);
              },
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              padding: EdgeInsets.zero,
            ),
            // --- END OF FIX ---
          ],
        ),
      ),
    );
  }
  
  void _showAddIngredientDialog(BuildContext context, {String? itemName}) {
    // Get both providers. 'context.read' is safe inside a method.
    final fridgeProvider = context.read<FridgeProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: itemName); 
    final quantityController = TextEditingController();
    final unitController = TextEditingController();
    final priceController = TextEditingController();
    DateTime? selectedDate;
    String selectedCategory = AppStrings.categories[0]; 

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(AppStrings.addIngredient),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: AppStrings.categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: AppStrings.category,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.ingredientName,
                          hintText: AppStrings.ingredientNameHint,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.quantityOptional,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: unitController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.unitOptional,
                          hintText: AppStrings.unitHint,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: AppStrings.takarPorimanRequired,
                          hintText: AppStrings.takarPorimanHint,
                          prefixText: "৳ ",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          if (double.tryParse(value) == null) {
                            return AppStrings.invalidNumber;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              selectedDate == null
                                  ? AppStrings.expiryDateOptional
                                  : DateFormat('dd MMM, yyyy', 'bn_BD')
                                      .format(selectedDate!),
                            ),
                          ),
                          TextButton(
                            child: const Text(AppStrings.selectDate),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                              );
                              if (picked != null && picked != selectedDate) {
                                setState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(AppStrings.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final price = double.parse(priceController.text);
                      
                      final newItem = Ingredient(
                        category: selectedCategory,
                        name: nameController.text,
                        quantity: double.tryParse(quantityController.text), 
                        unit: unitController.text.isEmpty ? null : unitController.text,
                        expiryDate: selectedDate,
                      );
                      
                      // Add the item and record the expense
                      fridgeProvider.addIngredient(newItem);
                      expenseProvider.addExpense(
                        name: newItem.name,
                        category: newItem.category,
                        cost: price,
                        date: DateTime.now(),
                      );
                      
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text(AppStrings.add),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRestockDialog(BuildContext context, Ingredient item) {
    final fridgeProvider = context.read<FridgeProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    
    final formKey = GlobalKey<FormState>();
    final quantityController = TextEditingController();
    final priceController = TextEditingController(); 

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("${AppStrings.restockItem}: ${item.name}"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.restockQuantity,
                      hintText: "e.g., 2, 5, 1.5",
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.fieldRequired;
                      }
                      if (double.tryParse(value) == null) {
                        return AppStrings.invalidNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: AppStrings.takarPorimanRequired,
                      hintText: AppStrings.takarPorimanHint,
                      prefixText: "৳ ",
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.fieldRequired;
                      }
                      if (double.tryParse(value) == null) {
                        return AppStrings.invalidNumber;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final double quantityToAdd = double.parse(quantityController.text);
                  final double price = double.parse(priceController.text);

                  // 1. Add quantity to the kitchen
                  fridgeProvider.incrementQuantity(item, quantityToAdd);
                  
                  // 2. Add the cost to the ledger
                  expenseProvider.addExpense(
                    name: item.name,
                    category: item.category,
                    cost: price,
                    date: DateTime.now(),
                  );
                  
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text(AppStrings.add),
            ),
          ],
        );
      },
    );
  }
}