import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late SupabaseClient _client;

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  SupabaseClient get client => _client;

  /// Initialize Supabase with your credentials
  /// Get these from your Supabase project settings
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _instance._client = Supabase.instance.client;
  }

  // Auth Methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Stream<AuthState> getAuthStateChange() {
    return _client.auth.onAuthStateChange;
  }

  // User Profile Methods
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String name,
    String? photoUrl,
    required double weight,
    required double targetWeight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
  }) async {
    await _client.from('users').insert({
      'id': userId,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'weight': weight,
      'target_weight': targetWeight,
      'height': height,
      'age': age,
      'gender': gender,
      'activity_level': activityLevel,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<String?> uploadProfilePhoto({
  required String userId,
  required File file,
}) async {
  try {
    const bucketName = 'profile-photos';

    final fileBytes = await file.readAsBytes();

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final path = 'avatars/$userId/$fileName';

    // Upload file
    await _client.storage.from(bucketName).uploadBinary(
      path,
      fileBytes,
      fileOptions: const FileOptions(
        contentType: 'image/jpeg',
        upsert: true,
      ),
    );

    // Get public URL
    final publicUrl =
        _client.storage.from(bucketName).getPublicUrl(path);

    return publicUrl;
  } catch (e) {
    throw Exception(
      'Upload profile photo failed: $e',
    );
  }
}

  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? photoUrl,
    double? weight,
    double? targetWeight,
    double? height,
    int? age,
    String? gender,
    String? activityLevel,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (photoUrl != null) data['photo_url'] = photoUrl;
    if (weight != null) data['weight'] = weight;
    if (targetWeight != null) data['target_weight'] = targetWeight;
    if (height != null) data['height'] = height;
    if (age != null) data['age'] = age;
    if (gender != null) data['gender'] = gender;
    if (activityLevel != null) data['activity_level'] = activityLevel;

    await _client.from('users').update(data).eq('id', userId);
  }

  // Nutrition Log Methods
  Future<List<Map<String, dynamic>>> getNutritionLogs(String userId) async {
    final response = await _client
        .from('nutrition_logs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getDailyNutritionLogs(
    String userId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final response = await _client
        .from('nutrition_logs')
        .select()
        .eq('user_id', userId)
        .gte('created_at', startOfDay.toIso8601String())
        .lte('created_at', endOfDay.toIso8601String())
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addNutritionLog({
    required String userId,
    required String foodName,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    required double sugar,
    required double servingSize,
    String? foodImage,
  }) async {
    await _client.from('nutrition_logs').insert({
      'user_id': userId,
      'food_name': foodName,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'sugar': sugar,
      'serving_size': servingSize,
      'food_image': foodImage,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteNutritionLog(String logId) async {
    await _client.from('nutrition_logs').delete().eq('id', logId);
  }

  // User Stats Methods
  Future<void> updateUserStats({
    required String userId,
    required int streakDays,
    required int points,
    required String lastLogDate,
  }) async {
    await _client.from('user_stats').upsert({
      'user_id': userId,
      'streak_days': streakDays,
      'points': points,
      'last_log_date': lastLogDate,
    });
  }

  Future<Map<String, dynamic>?> getUserStats(String userId) async {
    final response = await _client
        .from('user_stats')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return response;
  }

  // Real-time subscription for nutrition logs
  RealtimeChannel subscribeToNutritionLogs(String userId) {
    final channel = _client.realtime.channel(
      'public:nutrition_logs:user_id=eq.$userId',
    );
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'nutrition_logs',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        // Handle real-time changes
      },
    ).subscribe();
    return channel;
    
  }
}
