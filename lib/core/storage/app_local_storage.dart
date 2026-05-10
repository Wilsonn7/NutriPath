import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalStorage {
  static const _keyOpenAI = 'openai_api_key';
  static const _keyUsers = 'users';
  static const _keySessionEmail = 'session_email';

  Future<String?> readOpenAIKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyOpenAI);
  }

  Future<void> writeOpenAIKey(String? key) async {
    final prefs = await SharedPreferences.getInstance();
    if (key == null || key.isEmpty) {
      await prefs.remove(_keyOpenAI);
    } else {
      await prefs.setString(_keyOpenAI, key);
    }
  }

  Future<Map<String, dynamic>> readNutritionByEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('nutrition_$email');
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> writeNutritionByEmail(String email, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nutrition_$email', jsonEncode(data));
  }

  Future<Map<String, dynamic>> readUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUsers);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> writeUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsers, jsonEncode(users));
  }

  Future<String?> readSessionEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySessionEmail);
  }

  Future<void> writeSessionEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null || email.isEmpty) {
      await prefs.remove(_keySessionEmail);
    } else {
      await prefs.setString(_keySessionEmail, email);
    }
  }
}