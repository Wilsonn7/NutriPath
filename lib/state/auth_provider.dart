import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../core/services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  final SupabaseService _supabaseService = SupabaseService();

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initialize();
  }

  /// Initialize auth state - check if user is already logged in
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _supabaseService.getCurrentUser();
      if (user != null) {
        // Load user profile from Supabase
        await _loadUserProfile(user.id);
      }
    } catch (e) {
      _errorMessage = 'Error initializing auth: $e';
      print('Auth initialization error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load user profile from Supabase database
  Future<void> _loadUserProfile(String userId) async {
    try {
      final profile = await _supabaseService.getUserProfile(userId);
      if (profile != null) {
        _currentUser = UserModel(
          id: profile['id'] ?? userId,
          email: profile['email'] ?? '',
          name: profile['name'] ?? '',
          photoUrl: profile['photo_url'] as String?,
          weight: (profile['weight'] as num?)?.toDouble() ?? 0,
          targetWeight: (profile['target_weight'] as num?)?.toDouble() ?? 0,
          height: (profile['height'] as num?)?.toDouble() ?? 0,
          age: (profile['age'] as num?)?.toInt() ?? 0,
          gender: profile['gender'] ?? '',
          activityLevel: profile['activity_level'] ?? '',
        );
      }
    } catch (e) {
      print('Error loading user profile: $e');
      _errorMessage = 'Error loading user profile: $e';
    }
  }

  /// Register new user with Supabase
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required double weight,
    required double targetWeight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final normalizedEmail = email.trim().toLowerCase();

      // Sign up with Supabase Auth
      final response = await _supabaseService.signUp(
        email: normalizedEmail,
        password: password,
      );

      if (response.user != null) {
        // Create user profile in database
        await _supabaseService.createUserProfile(
          userId: response.user!.id,
          email: normalizedEmail,
          name: name,
          weight: weight,
          targetWeight: targetWeight,
          height: height,
          age: age,
          gender: gender,
          activityLevel: activityLevel,
        );

        // Set current user
        _currentUser = UserModel(
          id: response.user!.id,
          email: normalizedEmail,
          name: name,
          photoUrl: null,
          weight: weight,
          targetWeight: targetWeight,
          height: height,
          age: age,
          gender: gender,
          activityLevel: activityLevel,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      print('Auth error: ${e.message}');
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      print('Registration error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Login user with Supabase
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final normalizedEmail = email.trim().toLowerCase();

      // Sign in with Supabase Auth
      final response = await _supabaseService.signIn(
        email: normalizedEmail,
        password: password,
      );

      if (response.user != null) {
        // Load user profile
        await _loadUserProfile(response.user!.id);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      print('Login error: ${e.message}');
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Update user profile
  Future<String?> uploadProfilePhoto(File photoFile) async {
    final user = _currentUser;
    if (user == null) return null;
    return await _supabaseService.uploadProfilePhoto(userId: user.id, file: photoFile);
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.updateUserProfile(
        userId: updatedUser.id,
        name: updatedUser.name,
        photoUrl: updatedUser.photoUrl,
        weight: updatedUser.weight,
        targetWeight: updatedUser.targetWeight,
        height: updatedUser.height,
        age: updatedUser.age,
        gender: updatedUser.gender,
        activityLevel: updatedUser.activityLevel,
      );

      _currentUser = updatedUser;
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = 'Update failed: ${e.message}';
    } catch (e) {
      _errorMessage = 'Update failed: $e';
      print('Update profile error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _supabaseService.signOut();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      print('Logout error: $e');
    }
    notifyListeners();
  }
}

