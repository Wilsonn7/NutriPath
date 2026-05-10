class FoodModel {
  final String id;
  final String name;
  final double calories;
  final double protein; // in grams
  final double fat; // in grams
  final double carbs; // in grams
  final double sugar; // in grams
  final DateTime consumedAt;
  final String? imageUrl;
  final bool isScanned;

  FoodModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.sugar,
    required this.consumedAt,
    this.imageUrl,
    this.isScanned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'sugar': sugar,
      'consumedAt': consumedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'isScanned': isScanned,
    };
  }

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      protein: map['protein'],
      fat: map['fat'],
      carbs: map['carbs'],
      sugar: map['sugar'],
      consumedAt: DateTime.parse(map['consumedAt']),
      imageUrl: map['imageUrl'],
      isScanned: map['isScanned'] ?? false,
    );
  }
}
