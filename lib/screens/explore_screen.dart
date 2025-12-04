import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import 'meal_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedArea;

  const ExploreScreen({
    super.key,
    this.selectedCategory,
    this.selectedArea,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<List<Category>> _categoriesFuture;
  List<Meal> _filteredMeals = [];
  String? _selectedCategory;
  String? _selectedArea;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = ApiService.fetchCategories();
    _selectedCategory = widget.selectedCategory;
    _selectedArea = widget.selectedArea;

    // Load initial filtered meals if a category or area was passed
    if (_selectedCategory != null) {
      _fetchFilteredMeals(category: _selectedCategory);
    } else if (_selectedArea != null) {
      _fetchFilteredMeals(area: _selectedArea);
    }
  }

  Future<void> _fetchFilteredMeals({String? category, String? area}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Meal> meals;
      if (category != null) {
        meals = await ApiService.fetchMealsByCategory(category);
        setState(() {
          _selectedCategory = category;
          _selectedArea = null;
        });
      } else if (area != null) {
        meals = await ApiService.fetchMealsByArea(area);
        setState(() {
          _selectedArea = area;
          _selectedCategory = null;
        });
      } else {
        meals = [];
      }

      setState(() {
        _filteredMeals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore Meals',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 8,
        shadowColor: Colors.blueAccent.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Category>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final categories = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((category) {
                        final isSelected = _selectedCategory == category.name;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(category.name),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                _fetchFilteredMeals(category: category.name);
                              } else {
                                setState(() {
                                  _filteredMeals = [];
                                  _selectedCategory = null;
                                });
                              }
                            },
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            selectedColor: Colors.orange,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? Colors.orange : Colors.orange.withOpacity(0.3),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Filtered Meals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredMeals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              const Text(
                                'Select a category to see meals',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredMeals.length,
                          itemBuilder: (context, index) {
                            final meal = _filteredMeals[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MealDetailScreen(meal: meal),
                                ),
                              ),
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                elevation: 8,
                                shadowColor: Colors.blueAccent.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.orange.withOpacity(0.05),
                                        Colors.blueAccent.withOpacity(0.05),
                                      ],
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        meal.image,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(
                                      meal.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              meal.category,
                                              style: const TextStyle(fontSize: 11, color: Colors.orange),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blueAccent.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              meal.area,
                                              style: const TextStyle(fontSize: 11, color: Colors.blueAccent),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}