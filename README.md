<div align="center">
	<img src="assets/icon/icon.png" alt="RannaBondhu" width="96" height="96" />
	<h1>RannaBondhu</h1>
	<p><strong>রান্নার সাথী</strong> – A Bangla-first smart kitchen & meal planning assistant.</p>
	<p>
		Fridge inventory · Shopping list · Meal planner · Recipes · Expense tracker · AI suggestions · Bangla localization
	</p>
</div>

---

## Overview
RannaBondhu is a Flutter application that helps users (primarily Bangla-speaking) manage daily cooking and kitchen logistics. It centralizes fridge tracking, meal planning, shopping list preparation, expense monitoring, and intelligent recipe suggestions. Data is stored locally using Hive for fast offline access. The UI and date formatting default to Bangla (`bn_BD`).

## Core Features
- Fridge Inventory: Track stored ingredients with Hive persistence.
- Shopping List: Create, update, and clear items needed for upcoming meals.
- Meal Planner: Plan meals using `MealPlanItem` models and schedule ahead.
- Recipes Management: Store, browse, and (future) AI-assisted suggestions (`ai_recipe_suggestion`).
- Expense Tracker: Monitor food-related spending with categorized `ExpenseItem`s and charts (`fl_chart`).
- Bangla Localization: Localized strings, date formats, and locale defaults.
- State Management: `provider` for modular reactive updates.
- Offline-First: Local Hive boxes per model – no remote dependency.
- Launcher Icon Generation: Managed through `flutter_launcher_icons` config.

## Tech Stack
- Flutter (>= 3.0.0)
- Dart SDK (>= 3.0.0 < 4.0.0)
- State: `provider`
- Local DB: `hive`, `hive_flutter`
- Localization: `intl`, `flutter_localizations`
- Persistence & Preferences: `shared_preferences`
- Charts: `fl_chart`
- Code Generation: `build_runner`, `hive_generator`

## Architecture
Layered by responsibility:
- `models/`: Data classes + generated Hive adapters (`*.g.dart`).
- `providers/`: `ChangeNotifier` classes wrapping business logic & box operations.
- `screens/`: UI flows (home, fridge, meal planner, expense tracker, AI search, etc.).
- `services/`: (Placeholder/expand) API or helper abstractions for external calls.
- `utils/`: Constants, themes, localized strings (`strings_bn.dart`, `app_theme.dart`).
- `widgets/`: Reusable presentation components.

App bootstrap (`main.dart`):
1. Initializes Flutter bindings.
2. Prepares Bangla date formatting.
3. Initializes Hive & registers adapters.
4. Opens all required boxes.
5. Builds a `MultiProvider` tree for state injection.
6. Launches `HomeScreen` (authentication flow TBD).

## Getting Started
### Prerequisites
- Install Flutter SDK: https://docs.flutter.dev/get-started/install
- Ensure `flutter` is on your PATH (`flutter --version`).

### Clone & Setup
```bash
git clone <repo-url>
cd rannabondhu
flutter pub get
```

### Run the App
```bash
flutter run
```
If multiple devices are connected:
```bash
flutter devices
flutter run -d <device_id>
```

### Generate/Update Hive Adapters
If you add or modify Hive models:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Generate Launcher Icons
Update `assets/icon/icon.png` then:
```bash
flutter pub run flutter_launcher_icons
```

### Run Tests
```bash
flutter test
```

## Project Structure (Excerpt)
```
lib/
	main.dart
	models/                # Ingredient, ShoppingItem, MealPlanItem, Recipe, ExpenseItem, AI suggestions
	providers/             # FridgeProvider, ShoppingListProvider, etc.
	screens/               # UI screens (home, fridge, planner, expense, AI search)
	services/              # Service layer (future expansion)
	utils/                 # Themes, localized strings
	widgets/               # Reusable widgets
assets/
	icon/                  # App icon source
```

## Localization
The default locale is Bangla (`Locale('bn','BD')`). To add more languages: 
1. Add locale entries to `supportedLocales` in `main.dart`.
2. Introduce translation maps (e.g., `strings_en.dart`).
3. Switch `locale` dynamically (future enhancement: user preference stored via `shared_preferences`).

## State Management Guidelines
- Each domain has a provider (e.g., `FridgeProvider`).
- Providers wrap Hive box access; mutate through provider methods rather than directly accessing boxes in widgets.
- Keep UI widgets dumb; push logic to providers.

## Data Persistence (Hive)
- Boxes opened at startup: `fridgeBox`, `shoppingListBox`, `mealPlanBox`, `recipeBox`, `expenseBox`.
- Each model has a registered adapter. When adding new fields: bump `typeId` only if adding a new adapter (do not reuse IDs); regenerate with build_runner.

## Roadmap / Potential Enhancements
- Authentication & user profiles.
- Cloud sync (e.g., Firebase / Supabase) while keeping offline-first design.
- Advanced AI recipe generation combining available fridge ingredients.
- Nutrition analysis integration.
- Push notifications for expiring ingredients or planned meals.
- Multi-language toggle in settings.

## Contributing
1. Fork & branch: `git checkout -b feature/your-feature`.
2. Write clean, focused commits.
3. Ensure adapters/tests updated where applicable.
4. Open a PR describing changes & any migration steps.

## Troubleshooting
- Stale build artifacts: `flutter clean && flutter pub get`.
- Adapter mismatch: Re-run build_runner.
- Icon not updating: Ensure correct path in `pubspec.yaml` and rerun icon generator.

## License
No explicit license provided yet. Add a `LICENSE` file before open sourcing.

## Acknowledgements
Built with Flutter & the Bangla developer community in mind.

---
> Tip: For additional Flutter guidance, see the official [documentation](https://docs.flutter.dev/) and [cookbook](https://docs.flutter.dev/cookbook).
# rannabondhu
