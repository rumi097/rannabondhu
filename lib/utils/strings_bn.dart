// lib/utils/strings_bn.dart
class AppStrings {

  // --- NEW: BDAPPS API KEYS ---
  // Replace these with the values from your bdapps portal
  static const String bdappsAppId = "APP_133555";
  static const String bdappsAppPassword = "438693ae31db844ee694fdf9a8c27753"; // <-- YOUR APP ID HERE// <-- YOUR SECRET PASSWORD HERE
  // --- END OF NEW ---
  // --- App ---
  static const String appTitle = "রান্নাবন্ধু";

  // --- Auth ---
  static const String registerTitle = "স্বাগতম!";
  static const String registerSubtitle = "শুরু করতে আপনার মোবাইল নম্বর দিন";
  static const String mobileNumber = "মোবাইল নম্বর";
  static const String mobileNumberHint = "01XXXXXXXXX";
  static const String sendOtp = "OTP পাঠান";
  static const String verifyOtp = "যাচাই করুন";
  static const String otpTitle = "OTP যাচাই";
  static const String otpSubtitle = "আপনার নম্বরে পাঠানো ৬-ডিজিটের কোডটি দিন";
  static const String otpCode = "OTP কোড";
  static const String invalidMobile = "সঠিক মোবাইল নম্বর দিন (১১ ডিজিট)";
  static const String invalidOtp = "সঠিক OTP দিন (৬ ডিজিট)";
  static const String otpSent = "OTP পাঠানো হয়েছে!";
  static const String verificationSuccess = "যাচাই সফল হয়েছে!";
  static const String verificationFailed = "ভুল বা মেয়াদ উত্তীর্ণ OTP";

  // --- Navigation ---
  static const String navHome = "রান্নাঘর";
  static const String navRecipes = "রেসিপি";
  static const String navPlanner = "পরিকল্পনা";
  static const String navShoppingList = "বাজারের তালিকা";
  static const String navLedger = "হিসাব খাতা";

  // --- Fridge / Rannaghor ---
  static const String fridgeTitle = "আমার রান্নাঘর";
  static const String fridgeIsEmpty = "আপনার রান্নাঘর খালি। কিছু যোগ করুন!";
  static const String expiresOn = "মেয়াদ শেষ হবে:"; // <-- KEPT FOR THE LIST
  static const String addIngredient = "নতুন উপকরণ";
  static const String ingredientName = "উপকরণের নাম";
  static const String ingredientNameHint = "যেমন: ডিম, আলু, চাল";
  static const String quantity = "পরিমাণ";
  static const String unit = "একক";
  static const String unitHint = "যেমন: টি, কেজি, লিটার";
  static const String expiryDate = "মেয়াদের তারিখ";
  static const String selectDate = "তারিখ নির্বাচন করুন";
  static const String add = "যোগ করুন";
  static const String cancel = "বাতিল";
  static const String fieldRequired = "এটি অবশ্যই পূরণ করতে হবে";
  static const String invalidNumber = "সঠিক সংখ্যা দিন";
  static const String quantityOptional = "পরিমাণ (ঐচ্ছিক)";
  static const String unitOptional = "একক (ঐচ্ছিক)";
  static const String expiryDateOptional = "মেয়াদের তারিখ (ঐচ্ছিক)"; // <-- KEPT FOR THE DIALOG
  static const String noExpiryDate = "মেয়াদ নেই";
  
  // --- Price Strings ---
  static const String takarPoriman = "টাকার পরিমাণ";
  static const String takarPorimanRequired = "টাকার পরিমাণ";
  static const String takarPorimanHint = "যেমন: ১২০০";
  static const String priceOptional = "টাকার পরিমাণ (ঐচ্ছিক)"; // Use the same string
  static const String priceHint = takarPorimanHint;

  // --- Categories ---
  static const String category = "বিভাগ";
  static const String categoryVegetable = "শাকসবজি";
  static const String categoryFruit = "ফল";
  static const String categoryFish = "মাছ";
  static const String categoryMeat = "মাংস";
  static const String categoryDairy = "দুগ্ধজাত";
  static const String categorySpice = "মসলা";
  static const String categoryGrocery = "মুদি";
  static const String categoryBill = "বিল";
  static const String categoryOther = "অন্যান্য";
  static const List<String> categories = [
    categoryGrocery, categoryVegetable, categoryFruit, categoryFish, 
    categoryMeat, categoryDairy, categorySpice, categoryBill, categoryOther,
  ];

  // --- AI Search Screen ---
  static const String suggestionsTitle = "AI রেসিপি অনুসন্ধান";
  static const String aiSearchPrompt = "আজ কি রান্না করতে চান?";
  static const String aiSearchHint = "যেমন: ডিম ভাজি, চিকেন কারি...";
  static const String aiSearchButton = "অনুসন্ধান";
  static const String aiUseFridge = "আমার রান্নাঘরের উপকরণ ব্যবহার করুন";
  static const String aiGenerating = "AI আপনার জন্য রেসিপি তৈরি করছে...";
  static const String saveRecipe = "রেসিপি সংরক্ষণ করুন";
  static const String recipeSaved = "রেসিপি সংরক্ষণ করা হয়েছে!";

  // --- Saved Recipes ---
  static const String localRecipesTitle = "সংরক্ষিত রেসিপি";
  static const String noRecipesFound = "কোনো রেসিপি সংরক্ষণ করা নেই।";
  static const String ingredients = "উপকরণ";
  static const String steps = "প্রস্তুত প্রণালী";
  static const String addMyRecipe = "আমার রেসিপি যোগ করুন";
  static const String newRecipeTitle = "নতুন রেসিপি";
  static const String recipeTitle = "রেসিপির নাম";
  static const String recipeDesc = "সংক্ষিপ্ত বিবরণ";
  static const String ingredientsHint = "প্রতি লাইনে একটি উপকরণ লিখুন";
  static const String stepsHint = "প্রতি লাইনে একটি ধাপ লিখুন";

  // --- Shopping List ---
  static const String shoppingListTitle = "বাজারের তালিকা";
  static const String shoppingListEmpty = "আপনার বাজারের তালিকা খালি।";
  static const String addMissingItems = "ঘাটতি উপকরণ যোগ করুন";
  static const String itemsAddedToShoppingList = "উপকরণ তালিকায় যোগ করা হয়েছে!";
  static const String clearCheckedItems = "চেক করা আইটেম মুছুন";
  static const String addCustomItem = "নতুন আইটেম যোগ";
  static const String itemName = "আইটেমের নাম";
  static const String itemNameHint = "যেমন: চাল, ডাল, লবণ";
  static const String addToKitchen = "রান্নাঘরে যোগ করুন";
  static const String addingToKitchen = "যোগ করা হচ্ছে...";
  static const String addExpenseTitle = "খরচ যোগ করুন";
  static const String addExpenseBody = "আপনি যে আইটেমগুলো চেক করেছেন সেগুলোর মোট দাম কত?";
  static const String totalCost = "মোট খরচ (৳)";

  // --- NEW: Restock Dialog ---
  static const String restockItem = "আইটেম পুনরায় স্টক করুন";
  static const String restockQuantity = "কত পরিমাণ যুক্ত করতে চান?";
  // --- END OF NEW ---

  // --- Meal Planner ---
  static const String mealPlannerTitle = "খাবারের পরিকল্পনা";
  static const String mealPlannerEmpty = "আজকের জন্য কোনো পরিকল্পনা নেই।";
  static const String addToMealPlan = "পরিকল্পনায় যোগ করুন";
  // ... (rest of meal planner strings)
  static const String breakfast = "সকালের নাস্তা";
  static const String lunch = "দুপুরের খাবার";
  static const String dinner = "রাতের খাবার";
  static const String selectMealType = "খাবারের ধরণ নির্বাচন করুন";
  static const String mealAdded = "পরিকল্পনায় যোগ করা হয়েছে!";
  static const String addCustomPlan = "নতুন প্ল্যান যোগ";
  static const String mealName = "খাবারের নাম";
  static const String mealNameHint = "যেমন: ভাত, মাছ, সবজি";

  // --- Ledger Screen ---
  static const String ledgerTitle = "হিসাব খাতা";
  static const String todaysSpending = "আজকের খরচ";
  static const String thisWeeksSpending = "এই সপ্তাহের খরচ";
  static const String thisMonthsSpending = "এই মাসের খরচ";
  static const String spendingByCategory = "বিভাগ অনুযায়ী খরচ";
  static const String recentTransactions = "সাম্প্রতিক খরচ";
  static const String noExpenses = "এখনো কোনো খরচ যোগ করা হয়নি।";
  static const String addExpense = "নতুন খরচ যোগ";
  static const String expenseName = "খরচের নাম";
  static const String expenseNameHint = "যেমন: গ্যাস সিলিন্ডার, বাজারের কুলি";
  static const String resetLedger = "নতুন হিসাব শুরু করুন"; // <-- NEW
  static const String resetLedgerConfirmTitle = "হিসাব রিসেট করুন"; // <-- NEW
  static const String resetLedgerConfirmBody = "আপনি কি নিশ্চিত? এটি আপনার সমস্ত খরচের হিসাব মুছে ফেলবে। এটি ফেরত আনা যাবে না।"; // <-- NEW
  static const String reset = "রিসেট"; // <-- NEW
  static const String cost = takarPorimanRequired; // <-- Use new string
  static const String costHint = takarPorimanHint; // <-- Use new string
}