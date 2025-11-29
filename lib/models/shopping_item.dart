import 'package:hive/hive.dart';
import 'package:rannabondhu/utils/strings_bn.dart';

part 'shopping_item.g.dart'; // Run build_runner after this

@HiveType(typeId: 1)
class ShoppingItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool isChecked;

  @HiveField(2)
  String? quantity;

  @HiveField(3)
  String? unit;

  @HiveField(4)
  String category;
  
  // --- expenseId field (HiveField 5) is now REMOVED ---

  ShoppingItem({
    required this.name,
    this.isChecked = false,
    this.quantity,
    this.unit,
    this.category = AppStrings.categoryOther,
    // expenseId removed from constructor
  });
}