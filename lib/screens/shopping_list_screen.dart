import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rannabondhu/providers/fridge_provider.dart';
import 'package:rannabondhu/providers/shopping_list_provider.dart';
import 'package:rannabondhu/providers/expense_provider.dart';
import 'package:rannabondhu/utils/strings_bn.dart';
import 'package:rannabondhu/models/shopping_item.dart';
import 'package:rannabondhu/models/ingredient.dart';
import 'package:intl/intl.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  bool _isAdding = false;
  
  // We need these providers for the delete action
  late ShoppingListProvider _shoppingProvider;

  @override
  void initState() {
    super.initState();
    _shoppingProvider = context.read<ShoppingListProvider>();
  }

  // --- UPDATED: "Add to Kitchen" Logic ---
  Future<void> _addCheckedItemsToKitchen() async {
    final fridgeProvider = context.read<FridgeProvider>();
    
    final List<ShoppingItem> checkedItems = _shoppingProvider.items.where((item) => item.isChecked).toList();

    if (checkedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("দয়া করে প্রথমে কিছু আইটেম চেক করুন।")),
      );
      return;
    }
    
    // --- "Total Cost" dialog is REMOVED ---
    
    setState(() => _isAdding = true);

    for (final item in checkedItems) {
      final existingItem = fridgeProvider.ingredients
          .where((i) => i.name.toLowerCase() == item.name.toLowerCase())
          .firstOrNull;

      if (existingItem != null) {
        // If it exists, we still need to ask for the price of the restock
        if (!mounted) continue;
        await _showRestockDialog(context, existingItem, item);
      } else {
        // If it's new, show the full "Add Ingredient" dialog
        if (!mounted) continue; 
        await _showAddIngredientDialog(
          context, 
          item: item,
        );
      }
      
      // Remove item from shopping list
      await _shoppingProvider.removeItem(item);
    }
    
    if (mounted) {
      setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.shoppingListTitle),
        actions: [
          if (_isAdding)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.add_shopping_cart, size: 20),
              label: const Text(AppStrings.addToKitchen),
              onPressed: _addCheckedItemsToKitchen,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            )
        ],
      ),
      body: Consumer<ShoppingListProvider>(
        builder: (context, provider, child) {
          if (provider.items.isEmpty) {
            return const Center(child: Text(AppStrings.shoppingListEmpty));
          }
          
          return ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];
              
              String title = item.name;
              final qty = item.quantity;
              final unit = item.unit;
              if (qty != null && unit != null && qty.isNotEmpty && unit.isNotEmpty) {
                title += " ($qty $unit)";
              } else if (qty != null && qty.isNotEmpty) {
                title += " ($qty)";
              }

              return CheckboxListTile(
                title: Text(
                  title,
                  style: TextStyle(
                    decoration: item.isChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: item.isChecked ? Colors.grey : null,
                  ),
                ),
                subtitle: Text(item.category),
                value: item.isChecked,
                onChanged: _isAdding ? null : (bool? value) {
                  provider.toggleChecked(item);
                },
                secondary: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: _isAdding ? null : () {
                    // We don't need expenseProvider here anymore
                    provider.removeItem(item);
                  },
                ),
              );
            },
          );
        },
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _isAdding ? null : () {
          _showAddCustomItemDialog(context);
        },
        tooltip: AppStrings.addCustomItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- UPDATED "Add Custom Item" Dialog (NO Price) ---
  void _showAddCustomItemDialog(BuildContext context) {
    final provider = context.read<ShoppingListProvider>();
    final TextEditingController itemController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController unitController = TextEditingController();
    String selectedCategory = AppStrings.categories[0];
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(AppStrings.addCustomItem),
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
                        controller: itemController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.itemName,
                          hintText: AppStrings.itemNameHint,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
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
                      // --- PRICE FIELD REMOVED ---
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(AppStrings.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final qty = quantityController.text.isEmpty ? null : quantityController.text;
                      final unit = unitController.text.isEmpty ? null : unitController.text;
                      
                      provider.addItem(
                        itemController.text, 
                        quantity: qty, 
                        unit: unit,
                        category: selectedCategory,
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
  
  // --- UPDATED "Add to Kitchen" Dialog (Price is REQUIRED) ---
  Future<void> _showAddIngredientDialog(
    BuildContext context, {
    required ShoppingItem item,
  }) {
    final fridgeProvider = context.read<FridgeProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: item.name); 
    final quantityController = TextEditingController(text: item.quantity);
    final unitController = TextEditingController(text: item.unit);
    final priceController = TextEditingController(); // <-- PRICE IS NEW
    DateTime? selectedDate;
    String selectedCategory = item.category;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("${AppStrings.addIngredient}: ${item.name}"),
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
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: AppStrings.ingredientName,
                        ),
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
                      // --- PRICE FIELD IS ADDED AND REQUIRED ---
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
                      // --- END OF PRICE FIELD ---
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
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                              );
                              if (picked != null) {
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
                      
                      // Add to kitchen (this no longer adds expense)
                      fridgeProvider.addIngredient(newItem);
                      
                      // Add the expense separately
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

  // --- NEW DIALOG: For Restocking an existing item ---
  Future<void> _showRestockDialog(BuildContext context, Ingredient existingItem, ShoppingItem shoppingItem) {
    final fridgeProvider = context.read<FridgeProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    
    final formKey = GlobalKey<FormState>();
    // Pre-fill quantity from shopping list
    final quantityController = TextEditingController(text: shoppingItem.quantity);
    final priceController = TextEditingController(); 

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("${AppStrings.restockItem}: ${existingItem.name}"),
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
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final double quantityToAdd = double.parse(quantityController.text);
                  final double price = double.parse(priceController.text);

                  // 1. Add quantity to the kitchen
                  fridgeProvider.incrementQuantity(existingItem, quantityToAdd);
                  
                  // 2. Add the cost to the ledger
                  expenseProvider.addExpense(
                    name: existingItem.name,
                    category: existingItem.category,
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

  // "Total Cost" Dialog is no longer used
  /*
  Future<double?> _showAddTotalCostDialog(BuildContext context) {
    ...
  }
  */
}