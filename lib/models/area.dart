class Area {
  final String name;

  Area({required this.name});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      name: json['strArea'] ?? 'Unknown Area',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strArea': name,
    };
  }
}
