import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_meals';

  // Add a meal to favorites
  static Future<void> addFavoriteMeal(Meal meal) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];

    // Convert meal to JSON and add if not already present
    final mealJson = jsonEncode(meal.toJson());
    if (!favorites.contains(mealJson)) {
      favorites.add(mealJson);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  // Remove a meal from favorites
  static Future<void> removeFavoriteMeal(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];

    // Remove the meal with matching ID
    favorites.removeWhere((mealJson) {
      final meal = Meal.fromJson(jsonDecode(mealJson));
      return meal.id == mealId;
    });

    await prefs.setStringList(_favoritesKey, favorites);
  }

  // Get all favorite meals
  static Future<List<Meal>> getFavoriteMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];

    return favorites.map((mealJson) {
      return Meal.fromJson(jsonDecode(mealJson));
    }).toList();
  }

  // Check if a meal is in favorites
  static Future<bool> isFavoriteMeal(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];

    return favorites.any((mealJson) {
      final meal = Meal.fromJson(jsonDecode(mealJson));
      return meal.id == mealId;
    });
  }

  // Clear all favorites
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }
}
