import 'package:flutter/material.dart';
import 'package:rannabondhu/screens/fridge_screen.dart';
import 'package:rannabondhu/screens/recipe_hub_screen.dart'; // <-- CHANGED
import 'package:rannabondhu/screens/meal_planner_screen.dart';
import 'package:rannabondhu/screens/shopping_list_screen.dart';
import 'package:rannabondhu/screens/expense_tracker_screen.dart';
import 'package:rannabondhu/utils/strings_bn.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of all your main pages
  static const List<Widget> _pages = <Widget>[
    FridgeScreen(),
    RecipeHubScreen(), // <-- CHANGED from SavedRecipesScreen
    MealPlannerScreen(),
    ShoppingListScreen(),
    ExpenseTrackerScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      
      // No Floating Action Button on the main home screen
      floatingActionButton: null,

      // The Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // Tab 1: Fridge (Rannaghor)
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen_outlined),
            activeIcon: Icon(Icons.kitchen),
            label: AppStrings.navHome, // "রান্নাঘর"
          ),
          // Tab 2: Recipes (Now "রেসিপি")
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: AppStrings.navRecipes, // "রেসিপি"
          ),
          // Tab 3: Meal Planner
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: AppStrings.navPlanner, // "পরিকল্পনা"
          ),
          // Tab 4: Shopping List
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: AppStrings.navShoppingList, // "বাজারের তালিকা"
          ),
          // Tab 5: Ledger
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: AppStrings.navLedger, // "হিসাব খাতা"
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}