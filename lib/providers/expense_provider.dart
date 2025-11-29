import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rannabondhu/models/expense_item.dart';
import 'package:intl/intl.dart';

class ExpenseProvider extends ChangeNotifier {
  final Box<ExpenseItem> _expenseBox = Hive.box<ExpenseItem>('expenseBox');

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime get selectedMonth => _selectedMonth;

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month, 1);
    notifyListeners();
  }

  List<ExpenseItem> get allExpenses => _expenseBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  List<ExpenseItem> get expensesForSelectedMonth {
    return allExpenses
        .where((e) => e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month)
        .toList();
  }

  // --- Calculation Methods (unchanged) ---
  double get totalForSelectedMonth {
    return expensesForSelectedMonth.fold(0.0, (sum, item) => sum + item.cost);
  }
  double get totalTodayInSelectedMonth {
    // ... (logic unchanged)
    final now = DateTime.now();
    if (_selectedMonth.year == now.year && _selectedMonth.month == now.month) {
      return expensesForSelectedMonth
          .where((e) => DateFormat('yyyy-MM-dd').format(e.date) == DateFormat('yyyy-MM-dd').format(now))
          .fold(0.0, (sum, item) => sum + item.cost);
    }
    return 0.0;
  }
  double get totalThisWeekInSelectedMonth {
    // ... (logic unchanged)
    final now = DateTime.now();
    if (_selectedMonth.year == now.year && _selectedMonth.month == now.month) {
      final startOfWeek = now.subtract(Duration(days: (now.weekday % 7))); 
      return expensesForSelectedMonth
          .where((e) => e.date.isAfter(startOfWeek) || DateFormat('yyyy-MM-dd').format(e.date) == DateFormat('yyyy-MM-dd').format(startOfWeek))
          .fold(0.0, (sum, item) => sum + item.cost);
    }
    return 0.0;
  }
  Map<String, double> get spendingByCategoryForSelectedMonth {
    // ... (logic unchanged)
    final Map<String, double> map = {};
    for (final item in expensesForSelectedMonth) {
      if (map.containsKey(item.category)) {
        map[item.category] = map[item.category]! + item.cost;
      } else {
        map[item.category] = item.cost;
      }
    }
    return map;
  }

  // --- UPDATED: Database Methods ---

  // --- CHANGED: Now returns the created ExpenseItem ---
  Future<ExpenseItem> addExpense({
    required String name,
    required String category,
    required double cost,
    required DateTime date,
  }) async {
    final newExpense = ExpenseItem(
      id: "exp_${DateTime.now().millisecondsSinceEpoch}",
      name: name,
      category: category,
      cost: cost,
      date: date,
    );
    // Use `put` to store with a key we know
    await _expenseBox.put(newExpense.id, newExpense);
    notifyListeners();
    return newExpense; // Return the item so we can get its ID
  }

  Future<void> removeExpense(ExpenseItem expense) async {
    await expense.delete();
    notifyListeners();
  }
  
  // --- NEW: Remove an expense by its ID ---
  Future<void> removeExpenseById(String id) async {
    final expense = _expenseBox.get(id);
    if (expense != null) {
      await expense.delete();
      notifyListeners();
    }
  }
  
  // --- NEW: Reset the entire ledger ---
  Future<void> clearAllExpenses() async {
    await _expenseBox.clear();
    notifyListeners();
  }
}