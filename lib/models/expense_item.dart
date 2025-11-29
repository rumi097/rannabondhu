// lib/models/expense_item.dart
import 'package:hive/hive.dart';

part 'expense_item.g.dart'; // Run build_runner after this

@HiveType(typeId: 4) // This is our 5th model (0, 1, 2, 3, 4)
class ExpenseItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name; // e.g., "Bazar" or "Gas Cylinder"

  @HiveField(2)
  String category;

  @HiveField(3)
  double cost;

  @HiveField(4)
  DateTime date;

  ExpenseItem({
    required this.id,
    required this.name,
    required this.category,
    required this.cost,
    required this.date,
  });
}