import 'dart:math';
import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../models/user_model.dart';
import '../core/config/app_config.dart';
import '../core/services/openai_food_service.dart';
import '../core/services/food_search_service.dart';
import '../core/services/supabase_service.dart';

class NutritionProvider extends ChangeNotifier {
  final List<FoodModel> _dailyLog = [];
  final List<FoodModel> _history = [];
  bool _isLoading = false;
  DateTime? _lastLogDate;
  int _streakDays = 0;
  int _points = 0;
  String? _activeUserId;
  String? _openAiKey;

  late OpenAIFoodService _openAIFoodService;
  late final Future<void> _openAIKeyLoad;
  final SupabaseService _supabaseService = SupabaseService();
  late FoodSearchService _foodSearchService;

  NutritionProvider() {
    _openAIFoodService = OpenAIFoodService(
      apiKey: '',
    ); // Initialize with empty key first
    _foodSearchService = FoodSearchService();
    _openAIKeyLoad = _loadStoredOpenAIKey();
  }

  Future<void> _ensureOpenAIKeyReady() async {
    await _openAIKeyLoad;
  }

  List<FoodModel> get dailyLog => _dailyLog;
  List<FoodModel> get history => _history;
  bool get isLoading => _isLoading;
  int get streakDays => _streakDays;
  int get points => _points;
  String? get activeEmail => _activeUserId;
  bool get isOpenAIConfigured => _openAIFoodService.isConfigured;

  double get totalCaloriesConsumed =>
      _dailyLog.fold(0, (sum, item) => sum + item.calories);
  double get totalProteinConsumed =>
      _dailyLog.fold(0, (sum, item) => sum + item.protein);
  double get totalFatConsumed =>
      _dailyLog.fold(0, (sum, item) => sum + item.fat);
  double get totalCarbsConsumed =>
      _dailyLog.fold(0, (sum, item) => sum + item.carbs);
  double get totalSugarConsumed =>
      _dailyLog.fold(0, (sum, item) => sum + item.sugar);

  Future<void> syncForUser(String? userId) async {
    if (userId == _activeUserId) return;

    _activeUserId = userId;
    _dailyLog.clear();
    _history.clear();
    _streakDays = 0;
    _points = 0;
    _lastLogDate = null;

    if (userId == null) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Load all nutrition logs for user
      final logs = await _supabaseService.getNutritionLogs(userId);
      for (final logData in logs) {
        final food = FoodModel(
          id: logData['id'] ?? '',
          name: logData['food_name'] ?? 'Unknown',
          calories: (logData['calories'] as num?)?.toDouble() ?? 0,
          protein: (logData['protein'] as num?)?.toDouble() ?? 0,
          fat: (logData['fat'] as num?)?.toDouble() ?? 0,
          carbs: (logData['carbs'] as num?)?.toDouble() ?? 0,
          sugar: (logData['sugar'] as num?)?.toDouble() ?? 0,
          consumedAt: DateTime.tryParse(logData['created_at'] ?? '') ?? DateTime.now(),
          imageUrl: logData['food_image'],
          isScanned: (logData['is_scanned'] as bool?) ?? false,
        );
        _history.add(food);
      }

      // Load user stats
      final stats = await _supabaseService.getUserStats(userId);
      if (stats != null) {
        _streakDays = (stats['streak_days'] as num?)?.toInt() ?? 0;
        _points = (stats['points'] as num?)?.toInt() ?? 0;
        final lastDate = stats['last_log_date'] as String?;
        if (lastDate != null && lastDate.isNotEmpty) {
          _lastLogDate = DateTime.tryParse(lastDate);
        }
      }

      _rebuildDailyLog();
    } catch (e) {
      print('Error syncing nutrition data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mock AI Scan
  Future<FoodModel?> scanFood(String imagePath) async {
    _isLoading = true;
    notifyListeners();

    await _ensureOpenAIKeyReady();

    FoodModel scannedFood;
    try {
      final aiResult = await _openAIFoodService.analyzeNutrition(imagePath);
      if (aiResult != null) {
        scannedFood = FoodModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: (aiResult['name'] as String?) ?? 'Makanan',
          calories: (aiResult['calories'] as num?)?.toDouble() ?? 0.0,
          protein: (aiResult['protein'] as num?)?.toDouble() ?? 0.0,
          fat: (aiResult['fat'] as num?)?.toDouble() ?? 0.0,
          carbs: (aiResult['carbs'] as num?)?.toDouble() ?? 0.0,
          sugar: (aiResult['sugar'] as num?)?.toDouble() ?? 0.0,
          consumedAt: DateTime.now(),
          imageUrl: imagePath,
          isScanned: true,
        );
      } else {
        scannedFood = _mockScannedFood(imagePath);
      }
    } catch (_) {
      // If API fails, keep app usable with fallback mock analysis.
      scannedFood = _mockScannedFood(imagePath);
    }

    _isLoading = false;
    notifyListeners();
    return scannedFood;
  }

  void addFood(FoodModel food, {bool saveToHistory = true}) {
    _dailyLog.add(food);
    if (saveToHistory) {
      _history.add(food);
    }
    _updateGamification(food.consumedAt);
    _persistNutritionData(food);
    notifyListeners();
  }

  void _updateGamification(DateTime loggedAt) {
    final logDate = DateTime(loggedAt.year, loggedAt.month, loggedAt.day);
    if (_lastLogDate == null) {
      _streakDays = 1;
      _points += 10;
      _lastLogDate = logDate;
      return;
    }

    final last = DateTime(
      _lastLogDate!.year,
      _lastLogDate!.month,
      _lastLogDate!.day,
    );
    final diff = logDate.difference(last).inDays;
    if (diff == 1) {
      _streakDays += 1;
      _points += 15;
    } else if (diff == 0) {
      _points += 5;
    } else if (diff > 1) {
      _streakDays = 1;
      _points += 10;
    }
    _lastLogDate = logDate;
  }

  // AI Insights Generation
  Future<String> getAIInsight(UserModel user) async {
    try {
      return await _openAIFoodService.generateInsight(user, _dailyLog);
    } catch (_) {
      return _generateFallbackInsight(user);
    }
  }

  Future<List<FoodModel>> searchFoodRecommendations(
    double calories,
    double? sugar,
    double? fat,
    double? protein, {
    List<FoodModel>? dailyLog,
  }) async {
    try {
      print(
        'DEBUG: Searching dataset for calories=$calories, protein=$protein, fat=$fat, sugar=$sugar',
      );
      final results = await _foodSearchService.searchFoodRecommendations(
        calories,
        sugar: sugar,
        fat: fat,
        protein: protein,
      );
      print('DEBUG: Dataset returned ${results.length} recommendations');
      return results;
    } catch (e) {
      print('Error in searchFoodRecommendations: $e');
      return [];
    }
  }

  List<FoodModel> _getDefaultRecommendations(double targetCalories) {
    final cal = targetCalories.clamp(100, 800).round();
    return [
      FoodModel(
        id: 'default-1',
        name: 'Ayam Panggang dengan Nasi Merah',
        calories: (cal * 0.25).toDouble(),
        protein: 20.0,
        fat: 8.0,
        carbs: 35.0,
        sugar: 1.0,
        consumedAt: DateTime.now(),
      ),
      FoodModel(
        id: 'default-2',
        name: 'Salad Sayuran dan Telur Rebus',
        calories: (cal * 0.2).toDouble(),
        protein: 12.0,
        fat: 6.0,
        carbs: 12.0,
        sugar: 3.0,
        consumedAt: DateTime.now(),
      ),
      FoodModel(
        id: 'default-3',
        name: 'Smoothie Buah Segar',
        calories: (cal * 0.2).toDouble(),
        protein: 8.0,
        fat: 2.0,
        carbs: 40.0,
        sugar: 18.0,
        consumedAt: DateTime.now(),
      ),
      FoodModel(
        id: 'default-4',
        name: 'Ikan Bakar dengan Sayuran',
        calories: (cal * 0.22).toDouble(),
        protein: 25.0,
        fat: 7.0,
        carbs: 8.0,
        sugar: 2.0,
        consumedAt: DateTime.now(),
      ),
      FoodModel(
        id: 'default-5',
        name: 'Oatmeal dengan Yoghurt',
        calories: (cal * 0.13).toDouble(),
        protein: 10.0,
        fat: 3.0,
        carbs: 42.0,
        sugar: 8.0,
        consumedAt: DateTime.now(),
      ),
    ];
  }

  Future<String> _generateFallbackInsight(UserModel user) async {
    final calories = totalCaloriesConsumed.round();
    final protein = totalProteinConsumed.round();
    final carbs = totalCarbsConsumed.round();
    final fat = totalFatConsumed.round();
    final sugar = totalSugarConsumed.round();
    final goal = user.dailyCalorieGoal.round();
    final status = calories >= goal
        ? 'kamu sudah mencapai atau melebihi target kalori harian'
        : 'kamu masih berada di bawah target kalori harian';

    return 'Berdasarkan catatan hari ini, total kalori kamu adalah $calories kcal dengan protein $protein g, karbohidrat $carbs g, lemak $fat g, dan gula $sugar g. $status. Untuk memperbaiki pola makan, pertimbangkan untuk menambahkan lebih banyak protein jika asupan protein rendah dan memilih karbohidrat kompleks untuk energi yang lebih stabil.';
  }

  Map<String, List<FoodModel>> get groupedHistoryByDate {
    final map = <String, List<FoodModel>>{};
    final sorted = [..._history]
      ..sort((a, b) => b.consumedAt.compareTo(a.consumedAt));
    for (final item in sorted) {
      final d = item.consumedAt;
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []);
      map[key]!.add(item);
    }
    return map;
  }

  String get smartReminderMessage {
    final now = DateTime.now();
    if (_dailyLog.isEmpty && now.hour >= 12) {
      return 'Belum ada makanan tercatat hari ini. Coba scan makan siang kamu.';
    }
    if (_dailyLog.length < 2 && now.hour >= 18) {
      return 'Jangan lupa update konsumsi malam kamu agar tracking tetap konsisten.';
    }
    return 'Kerja bagus! Tetap konsisten mencatat gizi harian.';
  }

  Future<List<FoodModel>> getFoodRecommendations(double targetCalories) async {
    if (targetCalories <= 0) {
      return [];
    }
    return await searchFoodRecommendations(
      targetCalories,
      null,
      null,
      null,
      dailyLog: _dailyLog,
    );
  }

  Future<void> _setOpenAIKey(String? key, {bool saveToPrefs = false}) async {
    _openAiKey = key;
    _createNewServiceWithKey(_openAiKey);
    // Note: No longer saving to preferences, only config file
  }

  Future<bool> _reloadOpenAIKeyFromConfig() async {
    final configKey = await AppConfig.getGoogleApiKey();
    if (configKey != null && configKey.isNotEmpty && configKey != _openAiKey) {
      await _setOpenAIKey(configKey, saveToPrefs: true);
      print('DEBUG: Reloaded OpenAI key from config.json.');
      return true;
    }
    return false;
  }

  Future<void> _loadStoredOpenAIKey() async {
    print('DEBUG: Loading OpenAI key from config...');

    // Load from config.json
    final configKey = await AppConfig.getGoogleApiKey();
    if (configKey != null && configKey.isNotEmpty) {
      _openAiKey = configKey;
      _createNewServiceWithKey(_openAiKey);
      print('DEBUG: OpenAI key loaded from config.json.');
      return;
    }

    print('DEBUG: No OpenAI key configured.');
  }

  Future<void> testAIConnection() async {
    await _ensureOpenAIKeyReady();
    print('=== AI CONNECTION TEST ===');
    print('API Key loaded: ${_openAiKey != null && _openAiKey!.isNotEmpty}');
    print('AI Service configured: ${_openAIFoodService.isConfigured}');

    if (_openAIFoodService.isConfigured) {
      try {
        print('Testing AI call...');
        final testResults = await _openAIFoodService.searchFoodRecommendations(
          500,
          10,
          20,
          30,
        );
        print('AI returned ${testResults.length} results:');
        for (var food in testResults) {
          print('- ${food.name}: ${food.calories.round()} kcal');
        }
      } catch (e) {
        print('AI call failed: $e');
        if (e.toString().contains('API key not valid')) {
          print(
            'DEBUG: Invalid API key detected. Trying fallback from config.json...',
          );
          final reloaded = await _reloadOpenAIKeyFromConfig();
          if (reloaded) {
            try {
              final retryResults = await _openAIFoodService
                  .searchFoodRecommendations(500, 10, 20, 30);
              print(
                'AI returned ${retryResults.length} results after config key fallback.',
              );
              return;
            } catch (e2) {
              print('AI call still failed after config key fallback: $e2');
            }
          }
        }
      }
    } else {
      print('AI Service not configured - using defaults');
      final defaults = _getDefaultRecommendations(500);
      print('Default recommendations: ${defaults.length}');
      for (var food in defaults) {
        print('- ${food.name}: ${food.calories.round()} kcal');
      }
    }
    print('=== END TEST ===');
  }

  String? getStoredOpenAIKey() {
    return _openAiKey;
  }

  void _createNewServiceWithKey(String? apiKey) {
    _openAIFoodService = OpenAIFoodService(apiKey: apiKey ?? '');
  }

  FoodModel _mockScannedFood(String imagePath) {
    final random = Random();
    return FoodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Scanned Food ${random.nextInt(100)}',
      calories: 150.0 + random.nextInt(300),
      protein: 5.0 + random.nextInt(25),
      fat: 2.0 + random.nextInt(20),
      carbs: 10.0 + random.nextInt(40),
      sugar: 1.0 + random.nextInt(15),
      consumedAt: DateTime.now(),
      imageUrl: imagePath,
      isScanned: true,
    );
  }

  void _rebuildDailyLog() {
    _dailyLog.clear();
    final now = DateTime.now();
    for (final item in _history) {
      final sameDay =
          item.consumedAt.year == now.year &&
          item.consumedAt.month == now.month &&
          item.consumedAt.day == now.day;
      if (sameDay) {
        _dailyLog.add(item);
      }
    }
  }

  Future<void> _persistNutritionData(FoodModel food) async {
    final userId = _activeUserId;
    if (userId == null) return;

    try {
      // Add nutrition log to Supabase
      await _supabaseService.addNutritionLog(
        userId: userId,
        foodName: food.name,
        calories: food.calories,
        protein: food.protein,
        fat: food.fat,
        carbs: food.carbs,
        sugar: food.sugar,
        servingSize: 1.0,
        foodImage: food.imageUrl,
      );

      // Update user stats
      await _supabaseService.updateUserStats(
        userId: userId,
        streakDays: _streakDays,
        points: _points,
        lastLogDate: _lastLogDate?.toIso8601String() ?? '',
      );
    } catch (e) {
      print('Error persisting nutrition data: $e');
    }
  }
}
