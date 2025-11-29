import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rannabondhu/providers/expense_provider.dart';
import 'package:rannabondhu/utils/strings_bn.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:rannabondhu/utils/app_theme.dart';
import 'package:rannabondhu/models/expense_item.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {

  Future<void> _selectMonth(BuildContext context) async {
    // ... (This function is unchanged) ...
    final expenseProvider = context.read<ExpenseProvider>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: expenseProvider.selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDatePickerMode: DatePickerMode.year,
      locale: const Locale('bn', 'BD'),
    );
    if (picked != null && (picked.year != expenseProvider.selectedMonth.year || picked.month != expenseProvider.selectedMonth.month)) {
      expenseProvider.setSelectedMonth(picked);
    }
  }
  
  void _goToPreviousMonth() {
    // ... (This function is unchanged) ...
    final expenseProvider = context.read<ExpenseProvider>();
    final current = expenseProvider.selectedMonth;
    final previousMonth = DateTime(current.year, current.month - 1, 1);
    expenseProvider.setSelectedMonth(previousMonth);
  }
  
  void _goToNextMonth() {
    // ... (This function is unchanged) ...
    final expenseProvider = context.read<ExpenseProvider>();
    final current = expenseProvider.selectedMonth;
    final nextMonth = DateTime(current.year, current.month + 1, 1);
    final now = DateTime.now();
    if (nextMonth.year > now.year || (nextMonth.year == now.year && nextMonth.month > now.month)) {
      return;
    }
    expenseProvider.setSelectedMonth(nextMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.ledgerTitle),
        // --- ADDED RESET BUTTON ---
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppStrings.resetLedger,
            onPressed: () {
              _showResetConfirmationDialog(context);
            },
          ),
        ],
        // --- END OF ADDITION ---
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          
          final expenses = provider.expensesForSelectedMonth;
          final total = provider.totalForSelectedMonth;
          final today = provider.totalTodayInSelectedMonth;
          final week = provider.totalThisWeekInSelectedMonth;
          final categoryData = provider.spendingByCategoryForSelectedMonth;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMonthNavigator(context, provider.selectedMonth),
                const SizedBox(height: 16),
                _buildStatCard(
                  AppStrings.thisMonthsSpending,
                  "৳ ${total.toStringAsFixed(0)}",
                  Colors.blue,
                ),
                if (today > 0) ...[
                  const SizedBox(height: 12),
                  _buildStatCard(
                    AppStrings.todaysSpending,
                    "৳ ${today.toStringAsFixed(0)}",
                    Colors.orange,
                  ),
                ],
                if (week > 0) ...[
                  const SizedBox(height: 12),
                  _buildStatCard(
                    AppStrings.thisWeeksSpending,
                    "৳ ${week.toStringAsFixed(0)}",
                    Colors.green,
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  AppStrings.spendingByCategory,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                _buildPieChart(categoryData),
                const SizedBox(height: 24),
                Text(
                  AppStrings.recentTransactions,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                _buildRecentTransactions(expenses, provider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddManualExpenseDialog(context);
        },
        tooltip: AppStrings.addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- NEW: Reset Confirmation Dialog ---
  void _showResetConfirmationDialog(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.resetLedgerConfirmTitle),
        content: const Text(AppStrings.resetLedgerConfirmBody),
        actions: [
          TextButton(
            child: const Text(AppStrings.cancel),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent, // Red button
            ),
            child: const Text(AppStrings.reset),
            onPressed: () {
              provider.clearAllExpenses();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
  // --- END OF NEW DIALOG ---

  Widget _buildMonthNavigator(BuildContext context, DateTime selectedMonth) {
    // ... (This widget is unchanged) ...
    final now = DateTime.now();
    final isCurrentMonth = selectedMonth.year == now.year && selectedMonth.month == now.month;
    return Card(
      elevation: 0,
      color: AppColors.backgroundLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: _goToPreviousMonth,
            ),
            TextButton(
              onPressed: () => _selectMonth(context),
              child: Text(
                DateFormat('MMMM, yyyy', 'bn_BD').format(selectedMonth),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: isCurrentMonth ? null : _goToNextMonth,
              color: isCurrentMonth ? Colors.grey : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String amount, Color color) {
    // ... (This widget is unchanged) ...
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data) {
    // ... (This widget is unchanged) ...
    if (data.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text(AppStrings.noExpenses)),
      );
    }
    final colors = List.generate(data.length, (index) => Colors.primaries[index % Colors.primaries.length].shade300);
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: data.entries.map((entry) {
            final index = data.keys.toList().indexOf(entry.key);
            return PieChartSectionData(
              color: colors[index],
              value: entry.value,
              title: "৳${entry.value.toStringAsFixed(0)}",
              radius: 80,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(List<ExpenseItem> expenses, ExpenseProvider provider) {
    // ... (This widget is unchanged) ...
    if (expenses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: Text(AppStrings.noExpenses)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final item = expenses[index];
        return Card(
          child: ListTile(
            title: Text(item.name),
            subtitle: Text(item.category),
            leading: Text(
              DateFormat('dd\nMMM', 'bn_BD').format(item.date),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            trailing: Text(
              "৳ ${item.cost.toStringAsFixed(0)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.accent),
            ),
            onLongPress: () {
              provider.removeExpense(item);
            },
          ),
        );
      },
    );
  }

  // --- "Add Manual Expense" Dialog (Price is REQUIRED) ---
  void _showAddManualExpenseDialog(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final costController = TextEditingController();
    String selectedCategory = AppStrings.categories[0]; 

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(AppStrings.addExpense),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.expenseName,
                          hintText: AppStrings.expenseNameHint,
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? AppStrings.fieldRequired : null,
                      ),
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: costController,
                        decoration: InputDecoration(
                          labelText: AppStrings.takarPorimanRequired,
                          hintText: AppStrings.takarPorimanHint,
                          prefixText: "৳ ",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return AppStrings.fieldRequired;
                          if (double.tryParse(value) == null) return AppStrings.invalidNumber;
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12),
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
                      provider.addExpense(
                        name: nameController.text,
                        category: selectedCategory,
                        cost: double.parse(costController.text),
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
}