import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';

// Models
import 'package:rannabondhu/models/ingredient.dart';
import 'package:rannabondhu/models/shopping_item.dart';
import 'package:rannabondhu/models/meal_plan_item.dart';
import 'package:rannabondhu/models/recipe.dart';
import 'package:rannabondhu/models/expense_item.dart';

// Providers
import 'package:rannabondhu/providers/fridge_provider.dart';
import 'package:rannabondhu/providers/shopping_list_provider.dart';
import 'package:rannabondhu/providers/meal_plan_provider.dart';
import 'package:rannabondhu/providers/recipe_provider.dart';
import 'package:rannabondhu/providers/expense_provider.dart';

// Screens
import 'package:rannabondhu/screens/home_screen.dart';
//import 'package:rannabondhu/screens/auth/register_screen.dart';

// Utils
import 'package:rannabondhu/utils/strings_bn.dart';
import 'package:rannabondhu/utils/app_theme.dart';

void main() async {
  // 1. Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize Bangla date formatting
  await initializeDateFormatting('bn_BD', null);

  // 3. Initialize Hive
  await Hive.initFlutter();
  
  // 4. Register ALL adapters
  Hive.registerAdapter(IngredientAdapter());
  Hive.registerAdapter(ShoppingItemAdapter());
  Hive.registerAdapter(MealPlanItemAdapter());
  Hive.registerAdapter(RecipeAdapter());
  Hive.registerAdapter(ExpenseItemAdapter());
  
  // 5. Open ALL boxes
  await Hive.openBox<Ingredient>('fridgeBox');
  await Hive.openBox<ShoppingItem>('shoppingListBox');
  await Hive.openBox<MealPlanItem>('mealPlanBox');
  await Hive.openBox<Recipe>('recipeBox');
  await Hive.openBox<ExpenseItem>('expenseBox');
  
  // 6. Check Login State
  // final prefs = await SharedPreferences.getInstance();
  // final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  
  // 7. Run the app
  //runApp(MyApp(isLoggedIn: isLoggedIn));
  runApp(const MyApp(isLoggedIn: true));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FridgeProvider()),
        ChangeNotifierProvider(create: (context) => ShoppingListProvider()),
        ChangeNotifierProvider(create: (context) => MealPlanProvider()),
        ChangeNotifierProvider(create: (context) => RecipeProvider()),
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('bn', 'BD'),
          Locale('en', 'US'),
        ],
        locale: const Locale('bn', 'BD'),
        //home: isLoggedIn ? const HomeScreen() : const RegisterScreen(),
        home: const HomeScreen(),
      ),
    );
  }
}