/// Dataset makanan Indonesia dengan kandungan nutrisi
/// Sumber: Database gizi standar Indonesia
class FoodDatabase {
  static const List<Map<String, dynamic>> foods = [
    // Nasi & Karbohidrat
    {
      'name': 'Nasi Putih (1 piring)',
      'calories': 206,
      'protein': 4.3,
      'fat': 0.3,
      'carbs': 45,
      'sugar': 0.1,
    },
    {
      'name': 'Nasi Merah (1 piring)',
      'calories': 216,
      'protein': 5.0,
      'fat': 1.8,
      'carbs': 43,
      'sugar': 0.6,
    },
    {
      'name': 'Roti Tawar (2 iris)',
      'calories': 160,
      'protein': 5.6,
      'fat': 2.1,
      'carbs': 28,
      'sugar': 2.4,
    },
    {
      'name': 'Oatmeal (1 mangkuk)',
      'calories': 150,
      'protein': 5.0,
      'fat': 3.0,
      'carbs': 27,
      'sugar': 1.0,
    },

    // Ayam
    {
      'name': 'Ayam Panggang (100g)',
      'calories': 165,
      'protein': 31.0,
      'fat': 3.6,
      'carbs': 0,
      'sugar': 0,
    },
    {
      'name': 'Ayam Goreng (1 potong)',
      'calories': 280,
      'protein': 25.0,
      'fat': 20.0,
      'carbs': 0,
      'sugar': 0,
    },
    {
      'name': 'Ayam Rebus (100g)',
      'calories': 165,
      'protein': 31.0,
      'fat': 3.6,
      'carbs': 0,
      'sugar': 0,
    },

    // Ikan
    {
      'name': 'Ikan Bakar (100g)',
      'calories': 150,
      'protein': 28.0,
      'fat': 3.1,
      'carbs': 0,
      'sugar': 0,
    },
    {
      'name': 'Tuna (100g)',
      'calories': 144,
      'protein': 30.0,
      'fat': 1.0,
      'carbs': 0,
      'sugar': 0,
    },
    {
      'name': 'Salmon (100g)',
      'calories': 208,
      'protein': 20.0,
      'fat': 13.0,
      'carbs': 0,
      'sugar': 0,
    },

    // Daging
    {
      'name': 'Daging Sapi Rebus (100g)',
      'calories': 215,
      'protein': 30.0,
      'fat': 10.0,
      'carbs': 0,
      'sugar': 0,
    },
    {
      'name': 'Daging Sapi Panggang (100g)',
      'calories': 240,
      'protein': 28.0,
      'fat': 13.0,
      'carbs': 0,
      'sugar': 0,
    },

    // Telur
    {
      'name': 'Telur Rebus (1 butir)',
      'calories': 155,
      'protein': 13.0,
      'fat': 11.0,
      'carbs': 1.1,
      'sugar': 0,
    },
    {
      'name': 'Telur Goreng (1 butir)',
      'calories': 200,
      'protein': 13.0,
      'fat': 16.0,
      'carbs': 1.1,
      'sugar': 0,
    },

    // Sayuran
    {
      'name': 'Bayam Rebus (100g)',
      'calories': 23,
      'protein': 2.7,
      'fat': 0.4,
      'carbs': 3.6,
      'sugar': 0.4,
    },
    {
      'name': 'Brokoli Rebus (100g)',
      'calories': 34,
      'protein': 2.8,
      'fat': 0.4,
      'carbs': 7.0,
      'sugar': 1.4,
    },
    {
      'name': 'Wortel Rebus (100g)',
      'calories': 41,
      'protein': 0.9,
      'fat': 0.2,
      'carbs': 10.0,
      'sugar': 4.7,
    },
    {
      'name': 'Tomat (100g)',
      'calories': 18,
      'protein': 0.9,
      'fat': 0.2,
      'carbs': 3.9,
      'sugar': 2.6,
    },

    // Buah
    {
      'name': 'Pisang (1 buah sedang)',
      'calories': 107,
      'protein': 1.3,
      'fat': 0.3,
      'carbs': 27,
      'sugar': 14.4,
    },
    {
      'name': 'Apel (1 buah medium)',
      'calories': 95,
      'protein': 0.5,
      'fat': 0.3,
      'carbs': 25,
      'sugar': 19.0,
    },
    {
      'name': 'Jeruk (1 buah sedang)',
      'calories': 47,
      'protein': 0.7,
      'fat': 0.3,
      'carbs': 12,
      'sugar': 9.3,
    },
    {
      'name': 'Mangga (1 buah sedang)',
      'calories': 135,
      'protein': 1.1,
      'fat': 0.6,
      'carbs': 35,
      'sugar': 31.0,
    },
    {
      'name': 'Papaya (100g)',
      'calories': 43,
      'protein': 0.6,
      'fat': 0.3,
      'carbs': 11,
      'sugar': 7.0,
    },

    // Susu & Yogurt
    {
      'name': 'Susu Sapi (200ml)',
      'calories': 128,
      'protein': 6.6,
      'fat': 4.8,
      'carbs': 9.6,
      'sugar': 7.2,
    },
    {
      'name': 'Yogurt Plain (100g)',
      'calories': 61,
      'protein': 3.5,
      'fat': 0.4,
      'carbs': 4.7,
      'sugar': 3.6,
    },

    // Kacang & Biji
    {
      'name': 'Kacang Panjang Rebus (100g)',
      'calories': 32,
      'protein': 2.1,
      'fat': 0.1,
      'carbs': 6.4,
      'sugar': 2.4,
    },
    {
      'name': 'Tahu (100g)',
      'calories': 76,
      'protein': 8.0,
      'fat': 4.8,
      'carbs': 1.6,
      'sugar': 0.3,
    },
    {
      'name': 'Tempe (100g)',
      'calories': 195,
      'protein': 19.3,
      'fat': 11.0,
      'carbs': 9.3,
      'sugar': 2.0,
    },

    // Makanan Siap Saji/Khas Indonesia
    {
      'name': 'Nasi Goreng (1 piring)',
      'calories': 450,
      'protein': 12.0,
      'fat': 18.0,
      'carbs': 55.0,
      'sugar': 3.0,
    },
    {
      'name': 'Gado-gado (1 porsi)',
      'calories': 320,
      'protein': 12.0,
      'fat': 18.0,
      'carbs': 30.0,
      'sugar': 5.0,
    },
    {
      'name': 'Soto Ayam (1 mangkuk)',
      'calories': 280,
      'protein': 15.0,
      'fat': 12.0,
      'carbs': 28.0,
      'sugar': 2.0,
    },
    {
      'name': 'Rendang Daging (100g)',
      'calories': 380,
      'protein': 22.0,
      'fat': 28.0,
      'carbs': 8.0,
      'sugar': 1.0,
    },
    {
      'name': 'Lumpia Goreng (3 pcs)',
      'calories': 240,
      'protein': 6.0,
      'fat': 12.0,
      'carbs': 28.0,
      'sugar': 1.0,
    },
    {
      'name': 'Martabak (1 buah)',
      'calories': 350,
      'protein': 10.0,
      'fat': 18.0,
      'carbs': 38.0,
      'sugar': 4.0,
    },
    {
      'name': 'Sate Ayam (5 tusuk)',
      'calories': 380,
      'protein': 28.0,
      'fat': 22.0,
      'carbs': 15.0,
      'sugar': 2.0,
    },

    // Minuman & Dessert
    {
      'name': 'Jus Jeruk (1 gelas 200ml)',
      'calories': 86,
      'protein': 1.2,
      'fat': 0.2,
      'carbs': 20.0,
      'sugar': 17.0,
    },
    {
      'name': 'Smoothie Pisang (1 gelas)',
      'calories': 240,
      'protein': 8.0,
      'fat': 4.0,
      'carbs': 42.0,
      'sugar': 24.0,
    },
    {
      'name': 'Es Krim (1 scoop)',
      'calories': 137,
      'protein': 2.4,
      'fat': 7.6,
      'carbs': 16.0,
      'sugar': 14.0,
    },

    // Camilan
    {
      'name': 'Keripik Singkong (30g)',
      'calories': 150,
      'protein': 1.5,
      'fat': 7.0,
      'carbs': 20.0,
      'sugar': 0.5,
    },
    {
      'name': 'Granola (30g)',
      'calories': 130,
      'protein': 4.0,
      'fat': 5.0,
      'carbs': 19.0,
      'sugar': 6.0,
    },
    {
      'name': 'Kacang Tanah Goreng (30g)',
      'calories': 170,
      'protein': 7.3,
      'fat': 14.6,
      'carbs': 6.0,
      'sugar': 1.0,
    },

    // Protein Tinggi
    {
      'name': 'Dada Ayam (100g)',
      'calories': 165,
      'protein': 31.0,
      'fat': 3.6,
      'carbs': 0,
      'sugar': 0,
    },
    {
      'name': 'Ikan Cod (100g)',
      'calories': 105,
      'protein': 20.0,
      'fat': 1.0,
      'carbs': 0,
      'sugar': 0,
    },
    {
      'name': 'Putih Telur (3 butir)',
      'calories': 51,
      'protein': 11.0,
      'fat': 0.0,
      'carbs': 0.7,
      'sugar': 0,
    },
    {
      'name': 'Greek Yogurt (100g)',
      'calories': 59,
      'protein': 10.0,
      'fat': 0.5,
      'carbs': 3.3,
      'sugar': 2.0,
    },

    // Rendah Kalori
    {
      'name': 'Salad Hijau (200g)',
      'calories': 32,
      'protein': 2.4,
      'fat': 0.3,
      'carbs': 6.0,
      'sugar': 1.2,
    },
    {
      'name': 'Sup Sayuran (1 mangkuk)',
      'calories': 85,
      'protein': 4.0,
      'fat': 2.0,
      'carbs': 14.0,
      'sugar': 3.0,
    },
  ];

  /// Cari makanan dari dataset berdasarkan target nutrisi
  static List<Map<String, dynamic>> searchByNutrition({
    required double targetCalories,
    double? targetProtein,
    double? targetFat,
    double? targetSugar,
    int limit = 5,
  }) {
    // Hitung skor kesesuaian untuk setiap makanan
    final scored = foods.map((food) {
      double score = 0.0;

      // Kalori: prioritas utama (tolerance ±15%)
      final caloriesDiff = (food['calories'] - targetCalories).abs();
      final caloriesScore =
          1.0 - (caloriesDiff / (targetCalories * 0.15)).clamp(0.0, 1.0);
      score += caloriesScore * 0.5; // 50% weight

      // Protein (jika ditentukan)
      if (targetProtein != null && targetProtein > 0) {
        final proteinDiff = (food['protein'] - targetProtein).abs();
        final proteinScore =
            1.0 -
            (proteinDiff / (targetProtein > 0 ? targetProtein * 0.3 : 10))
                .clamp(0.0, 1.0);
        score += proteinScore * 0.2; // 20% weight
      }

      // Lemak (jika ditentukan)
      if (targetFat != null && targetFat > 0) {
        final fatDiff = (food['fat'] - targetFat).abs();
        final fatScore =
            1.0 -
            (fatDiff / (targetFat > 0 ? targetFat * 0.3 : 10)).clamp(0.0, 1.0);
        score += fatScore * 0.15; // 15% weight
      }

      // Gula (jika ditentukan)
      if (targetSugar != null && targetSugar > 0) {
        final sugarDiff = (food['sugar'] - targetSugar).abs();
        final sugarScore =
            1.0 -
            (sugarDiff / (targetSugar > 0 ? targetSugar * 0.3 : 10)).clamp(
              0.0,
              1.0,
            );
        score += sugarScore * 0.15; // 15% weight
      }

      return {...food, '_score': score};
    }).toList();

    // Urutkan berdasarkan skor kesesuaian
    scored.sort((a, b) => (b['_score'] as num).compareTo(a['_score'] as num));

    // Ambil top hasil
    return scored.take(limit).toList();
  }
}
