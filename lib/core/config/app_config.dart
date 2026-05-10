import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  static Future<String?> getGoogleApiKey() async {
    try {
      final jsonString = await rootBundle.loadString('assets/config.json');
      final config = jsonDecode(jsonString) as Map<String, dynamic>;
      // ✅ Sesuaikan dengan nama key di config.json kamu
      final key = config['GoogleApiKey'] as String?;
      print('DEBUG AppConfig: key loaded = $key');
      return (key != null && key.isNotEmpty) ? key : null;
    } catch (e) {
      print('DEBUG AppConfig ERROR: $e');
      return null;
    }
  }
}