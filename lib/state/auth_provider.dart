import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/storage/app_local_storage.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, String> _passwordByEmail = {};
  final Map<String, UserModel> _usersByEmail = {};
  final AppLocalStorage _storage = AppLocalStorage();

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    final users = await _storage.readUsers();
    users.forEach((email, value) {
      if (value is! Map<String, dynamic>) return;
      final map = value;
      final user = UserModel(
        id: map['id'] as String,
        email: map['email'] as String,
        name: map['name'] as String,
        weight: (map['weight'] as num).toDouble(),
        targetWeight: (map['targetWeight'] as num).toDouble(),
        height: (map['height'] as num).toDouble(),
        age: (map['age'] as num).toInt(),
        gender: map['gender'] as String,
        activityLevel: map['activityLevel'] as String,
      );
      _usersByEmail[email] = user;
      _passwordByEmail[email] = (map['password'] as String?) ?? '';
    });

    final sessionEmail = await _storage.readSessionEmail();
    if (sessionEmail != null && _usersByEmail.containsKey(sessionEmail)) {
      _currentUser = _usersByEmail[sessionEmail];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persistUsers() async {
    final map = <String, dynamic>{};
    for (final entry in _usersByEmail.entries) {
      final user = entry.value;
      map[entry.key] = {
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'weight': user.weight,
        'targetWeight': user.targetWeight,
        'height': user.height,
        'age': user.age,
        'gender': user.gender,
        'activityLevel': user.activityLevel,
        'password': _passwordByEmail[entry.key] ?? '',
      };
    }
    await _storage.writeUsers(map);
  }

  // Mock Register
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

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final normalizedEmail = email.trim().toLowerCase();
    if (_usersByEmail.containsKey(normalizedEmail)) {
      _errorMessage = 'Email sudah terdaftar.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: normalizedEmail,
      name: name,
      weight: weight,
      targetWeight: targetWeight,
      height: height,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
    );
    _usersByEmail[normalizedEmail] = newUser;
    _passwordByEmail[normalizedEmail] = password;
    await _persistUsers();

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Mock Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final normalizedEmail = email.trim().toLowerCase();
    final savedPassword = _passwordByEmail[normalizedEmail];
    final user = _usersByEmail[normalizedEmail];
    if (savedPassword == null || user == null || savedPassword != password) {
      _errorMessage = 'Email atau password salah.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _currentUser = user;
    await _storage.writeSessionEmail(normalizedEmail);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Update Profile
  Future<void> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _currentUser = updatedUser;
    _usersByEmail[updatedUser.email.toLowerCase()] = updatedUser;
    await _persistUsers();

    _isLoading = false;
    notifyListeners();
  }

  // Logout
  void logout() {
    _storage.writeSessionEmail(null);
    _currentUser = null;
    notifyListeners();
  }
}
