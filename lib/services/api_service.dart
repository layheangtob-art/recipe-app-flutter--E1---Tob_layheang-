import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/meal.dart';
import '../models/category.dart';
import '../models/area.dart';

class ApiService {
  static const String baseUrl = 'https://meal-db-sandy.vercel.app';
  static const Map<String, String> headers = {
    'X-DB-NAME': 'd443dd4e-ac1d-4d5e-9885-cf05682f0ab9',
  };

  // Fetch all meals
  static Future<List<Meal>> fetchMeals() async {
    final response = await http.get(Uri.parse('$baseUrl/meals'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((meal) => Meal.fromJson(meal)).toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  // Fetch all categories
  static Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((category) => Category.fromJson(category)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Fetch all areas
  static Future<List<Area>> fetchAreas() async {
    final response = await http.get(Uri.parse('$baseUrl/areas'), headers: headers);
    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      // Handle both list and map responses
      if (jsonData is List) {
        return jsonData.map((area) => Area.fromJson(area)).toList();
      } else if (jsonData is Map && jsonData.isNotEmpty) {
        return jsonData.entries.map((entry) => Area(name: entry.value.toString())).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load areas');
    }
  }

  // Fetch meals by category
  static Future<List<Meal>> fetchMealsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$baseUrl/meals?category=$category'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      List<dynamic> mealsList;
      
      if (jsonData is List) {
        mealsList = jsonData;
      } else if (jsonData is Map && jsonData.containsKey('meals')) {
        mealsList = jsonData['meals'];
      } else {
        return [];
      }
      
      return mealsList.map((meal) => Meal.fromJson(meal)).toList();
    } else {
      throw Exception('Failed to load meals by category');
    }
  }

  // Fetch meals by area
  static Future<List<Meal>> fetchMealsByArea(String area) async {
    final response = await http.get(
      Uri.parse('$baseUrl/meals?area=$area'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      List<dynamic> mealsList;
      
      if (jsonData is List) {
        mealsList = jsonData;
      } else if (jsonData is Map && jsonData.containsKey('meals')) {
        mealsList = jsonData['meals'];
      } else {
        return [];
      }
      
      return mealsList.map((meal) => Meal.fromJson(meal)).toList();
    } else {
      throw Exception('Failed to load meals by area');
    }
  }

  // Fetch random meal - gets all meals and picks a random one
  static Future<Meal> fetchRandomMeal() async {
    try {
      final meals = await fetchMeals();
      if (meals.isEmpty) {
        throw Exception('No meals available');
      }
      final random = Random();
      return meals[random.nextInt(meals.length)];
    } catch (e) {
      throw Exception('Failed to load random meal: $e');
    }
  }

  // Fetch meal by ID
  static Future<Meal> fetchMealById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/meals/$id'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      final mealData = jsonData is Map && jsonData.containsKey('meals') 
        ? jsonData['meals'][0] 
        : jsonData;
      return Meal.fromJson(mealData);
    } else {
      throw Exception('Failed to load meal details');
    }
  }

  // Search meals by name
  static Future<List<Meal>> searchMealsByName(String name) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?name=$name'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      List<dynamic> meals;
      
      if (jsonData is List) {
        meals = jsonData;
      } else if (jsonData is Map && jsonData.containsKey('meals')) {
        meals = jsonData['meals'];
      } else {
        return [];
      }
      
      return meals.map((meal) => Meal.fromJson(meal)).toList();
    } else {
      throw Exception('Failed to search meals');
    }
  }
}