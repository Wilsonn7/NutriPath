class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final double weight; // kg
  final double targetWeight; // kg
  final double height; // cm
  final int age;
  final String gender; // 'male', 'female'
  final String activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.weight,
    required this.targetWeight,
    required this.height,
    required this.age,
    required this.gender,
    required this.activityLevel,
  });

  // Calculate BMR using Mifflin-St Jeor Equation
  double get bmr {
    double bmrValue = (10 * weight) + (6.25 * height) - (5 * age);
    if (gender.toLowerCase() == 'male') {
      bmrValue += 5;
    } else {
      bmrValue -= 161;
    }
    return bmrValue;
  }

  // Calculate Daily Calorie Needs
  double get dailyCalorieGoal {
    double multiplier = 1.2; // Sedentary by default
    switch (activityLevel.toLowerCase()) {
      case 'light':
        multiplier = 1.375;
        break;
      case 'moderate':
        multiplier = 1.55;
        break;
      case 'active':
        multiplier = 1.725;
        break;
      case 'very_active':
        multiplier = 1.9;
        break;
    }
    final maintenance = bmr * multiplier;
    final diff = targetWeight - weight;
    // If target is lower, create deficit; if higher, add surplus.
    final adjustment = diff < 0 ? -300.0 : (diff > 0 ? 300.0 : 0.0);
    return (maintenance + adjustment).clamp(1200.0, 4500.0);
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    double? weight,
    double? targetWeight,
    double? height,
    int? age,
    String? gender,
    String? activityLevel,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      height: height ?? this.height,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }
}
