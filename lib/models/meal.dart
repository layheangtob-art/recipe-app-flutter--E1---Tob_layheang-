class Meal {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String image;
  final String? youtubeUrl;
  final String? sourceUrl;
  final List<String> ingredients;
  final List<String> measures;

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.image,
    this.youtubeUrl,
    this.sourceUrl,
    required this.ingredients,
    required this.measures,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    // Extract ingredients and measures
    final ingredients = <String>[];
    final measures = <String>[];

    // Handle both old format (numbered fields) and new format (array)
    if (json['ingredients'] is List) {
      // New API format with ingredients array
      final ingredientList = json['ingredients'] as List<dynamic>;
      for (var item in ingredientList) {
        if (item is Map<String, dynamic>) {
          final ingredient = item['ingredient'];
          final measure = item['measure'];
          if (ingredient != null && ingredient.toString().isNotEmpty) {
            ingredients.add(ingredient.toString());
            measures.add(measure?.toString() ?? '');
          }
        }
      }
    } else {
      // Old API format with numbered fields
      for (int i = 1; i <= 20; i++) {
        final ingredient = json['strIngredient$i'];
        final measure = json['strMeasure$i'];

        if (ingredient != null && ingredient.toString().isNotEmpty) {
          ingredients.add(ingredient.toString());
          measures.add(measure?.toString() ?? '');
        }
      }
    }

    return Meal(
      id: json['id']?.toString() ?? json['idMeal']?.toString() ?? '',
      name: json['meal'] ?? json['strMeal'] ?? 'Unknown Meal',
      category: json['category'] ?? json['strCategory'] ?? 'Unknown Category',
      area: json['area'] ?? json['strArea'] ?? 'Unknown Area',
      instructions: json['instructions'] ?? json['strInstructions'] ?? 'No instructions',
      image: json['mealThumb'] ?? json['strMealThumb'] ?? '',
      youtubeUrl: json['youtube'] ?? json['strYoutube'],
      sourceUrl: json['source'] ?? json['strSource'],
      ingredients: ingredients,
      measures: measures,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal': name,
      'category': category,
      'area': area,
      'instructions': instructions,
      'mealThumb': image,
      'youtube': youtubeUrl,
      'source': sourceUrl,
    };
  }
}
