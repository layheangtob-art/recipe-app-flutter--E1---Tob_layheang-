class Category {
  final String id;
  final String name;
  final String image;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? json['idCategory']?.toString() ?? '',
      name: json['category'] ?? json['strCategory'] ?? 'Unknown Category',
      image: json['categoryThumb'] ?? json['strCategoryThumb'] ?? '',
      description: json['categoryDescription'] ?? json['strCategoryDescription'] ?? 'No description',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': name,
      'categoryThumb': image,
      'categoryDescription': description,
    };
  }
}
