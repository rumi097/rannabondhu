import 'package:hive/hive.dart';
import 'package:rannabondhu/utils/strings_bn.dart';

part 'ingredient.g.dart'; // Run build_runner after this

@HiveType(typeId: 0)
class Ingredient extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double? quantity;

  @HiveField(2)
  String? unit;

  @HiveField(3)
  DateTime? expiryDate;

  @HiveField(4)
  String category;
  
  // --- expenseId field (HiveField 5) is now REMOVED ---

  Ingredient({
    required this.name,
    this.quantity,
    this.unit,
    this.expiryDate,
    this.category = AppStrings.categoryOther,
    // expenseId removed from constructor
  });
}