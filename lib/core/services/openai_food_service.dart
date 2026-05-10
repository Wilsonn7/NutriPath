// openai_food_service.dart — FIXED VERSION

import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/food_model.dart';
import '../../models/user_model.dart';

class OpenAIFoodService {
  final String _apiKey;
  late final GenerativeModel _model;

  OpenAIFoodService({required String apiKey}) : _apiKey = apiKey {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // ✅ FIX 1: gemini-pro sudah deprecated
      apiKey: _apiKey,
    );
  }

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> _sendContent(Iterable<Content> contents) async {
    try {
      final response = await _model.generateContent(contents);
      return response.text ?? '';
    } catch (e) {
      throw Exception('Error calling Google AI: $e');
    }
  }

  Future<String> _sendPrompt(String prompt) async {
    return await _sendContent([Content.text(prompt)]);
  }

  // =========================
  // ANALYZE IMAGE
  // =========================
  Future<Map<String, dynamic>?> analyzeNutrition(String imagePath) async {
    if (!isConfigured) return null;

    final imageBytes = await File(imagePath).readAsBytes();
    final pathLower = imagePath.toLowerCase();
    final mimeType = pathLower.endsWith('.png') ? 'image/png' : 'image/jpeg';

    const prompt = '''
Kamu adalah ahli nutrisi. Analisis gambar makanan ini dan kembalikan HANYA satu objek JSON tanpa teks tambahan, tanpa markdown, tanpa backtick:
{"name": "nama makanan", "calories": 0, "protein": 0, "fat": 0, "carbs": 0, "sugar": 0}
''';

    final imageContent = Content.data(mimeType, imageBytes);
    final textContent = Content.text(prompt);

    final text = await _sendContent([imageContent, textContent]);
    return _extractJson(text);
  }

  // =========================
  // INSIGHT
  // =========================
  Future<String> generateInsight(
    UserModel user,
    List<FoodModel> dailyLog,
  ) async {
    if (!isConfigured) throw Exception("API key kosong");

    final foods = dailyLog.isNotEmpty
        ? dailyLog
              .map(
                (f) =>
                    "- ${f.name}: ${f.calories.round()} kcal, P ${f.protein.round()}g, F ${f.fat.round()}g, C ${f.carbs.round()}g, S ${f.sugar.round()}g",
              )
              .join("\n")
        : 'Tidak ada catatan konsumsi hari ini.';

    final totalCalories = dailyLog.fold<double>(0, (s, f) => s + f.calories);
    final totalProtein = dailyLog.fold<double>(0, (s, f) => s + f.protein);
    final totalFat = dailyLog.fold<double>(0, (s, f) => s + f.fat);
    final totalCarbs = dailyLog.fold<double>(0, (s, f) => s + f.carbs);
    final totalSugar = dailyLog.fold<double>(0, (s, f) => s + f.sugar);

    final prompt =
        '''
Kamu adalah seorang ahli nutrisi. Analisis konsumsi harian berikut dan beri insight singkat serta rekomendasi perbaikan pola makan:

$foods

Total hari ini:
- Kalori: ${totalCalories.round()} kcal
- Protein: ${totalProtein.round()} g
- Lemak: ${totalFat.round()} g
- Karbohidrat: ${totalCarbs.round()} g
- Gula: ${totalSugar.round()} g

Target kalori harian: ${user.dailyCalorieGoal.round()} kcal

Berikan feedback singkat dalam bahasa Indonesia.
''';

    return await _sendPrompt(prompt);
  }

  // =========================
  // RECOMMENDATION
  // =========================
  Future<List<FoodModel>> searchFoodRecommendations(
    double calories,
    double? sugar,
    double? fat,
    double? protein, {
    List<FoodModel>? dailyLog,
  }) async {
    if (!isConfigured) {
      print('DEBUG: AI service tidak dikonfigurasi');
      return [];
    }

    final dailyLogText = (dailyLog != null && dailyLog.isNotEmpty)
        ? 'Catatan konsumsi hari ini:\n${dailyLog.map((f) => '- ${f.name}: ${f.calories.round()} kcal, P ${f.protein.round()}g, F ${f.fat.round()}g, C ${f.carbs.round()}g').join('\n')}\n\n'
        : '';

    // Buat daftar prioritas nutrisi yang ditentukan user
    final nutrients = <String>[];
    if (protein != null && protein > 0)
      nutrients.add('Protein: ${protein.round()}g');
    if (fat != null && fat > 0) nutrients.add('Lemak: ${fat.round()}g');
    if (sugar != null && sugar > 0) nutrients.add('Gula: ${sugar.round()}g');

    final nutrientRequirement = nutrients.isNotEmpty
        ? 'Nutrisi khusus: ${nutrients.join(', ')}\n'
        : 'Nutrisi fleksibel (user tidak menentukan detail).\n';

    final prompt =
        '''Kamu adalah ahli nutrisi profesional berpengalaman. Cari dan rekomendasikan makanan Indonesia yang paling sesuai dengan target nutrisi berikut:

${dailyLogText}Target Kalori: ${calories.round()} kcal
$nutrientRequirement
Prioritas:
1. Makanan yang kalorinya PALING MENDEKATI ${calories.round()} kcal (toleransi ±10%)
2. Jika ada target nutrisi spesifik (protein/lemak/gula), prioritaskan makanan yang mendekati target tersebut
3. Berikan 5 rekomendasi makanan yang berbeda
4. Setiap makanan harus makanan nyata, mudah ditemukan, dan umum dimakan di Indonesia
5. Sertakan perkiraan nutrisi yang akurat berdasarkan porsi standar

PENTING: Kembalikan HANYA JSON ARRAY dalam format ini, TANPA markdown, backtick, atau teks lain:
[{"name":"Nasi Goreng","calories":450,"protein":15,"fat":18,"carbs":55,"sugar":3},{"name":"Ayam Panggang","calories":350,"protein":45,"fat":12,"carbs":5,"sugar":1},...]''';

    try {
      final text = await _sendPrompt(prompt);
      print('DEBUG: Raw AI response: $text');

      // Parser yang robust menangani markdown
      final list = _extractJsonList(text);
      print('DEBUG: Parsed ${list.length} makanan dari AI');

      if (list.isEmpty) return [];

      return list
          .map(
            (item) => FoodModel(
              id: '${(item['name'] as String? ?? 'food').replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}',
              name: item['name'] as String? ?? 'Makanan',
              calories: _toDouble(item['calories']),
              protein: _toDouble(item['protein']),
              fat: _toDouble(item['fat']),
              carbs: _toDouble(item['carbs']),
              sugar: _toDouble(item['sugar']),
              consumedAt: DateTime.now(),
            ),
          )
          .toList();
    } catch (e) {
      print('ERROR searchFoodRecommendations: $e');
      return [];
    }
  }

  // =========================
  // PARSER — ROBUST
  // =========================

  /// ✅ FIX 3: Bersihkan markdown sebelum parse JSON object
  Map<String, dynamic> _extractJson(String text) {
    final cleaned = _stripMarkdown(text);
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
    if (match == null) {
      print('DEBUG _extractJson: tidak ada JSON ditemukan di: $cleaned');
      throw Exception("JSON tidak valid");
    }
    try {
      return jsonDecode(match.group(0)!) as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Gagal parse JSON: $e");
    }
  }

  /// ✅ FIX 3: Bersihkan markdown sebelum parse JSON array
  /// Tidak lempar exception jika tidak ada array — return [] saja
  List<Map<String, dynamic>> _extractJsonList(String text) {
    final cleaned = _stripMarkdown(text);
    final match = RegExp(r'\[[\s\S]*\]').firstMatch(cleaned);
    if (match == null) {
      print('DEBUG _extractJsonList: tidak ada JSON array di: $cleaned');
      return [];
    }
    try {
      final decoded = jsonDecode(match.group(0)!);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    } catch (e) {
      print('DEBUG _extractJsonList parse error: $e');
      return [];
    }
  }

  /// Hapus markdown code block (```json ... ``` atau ``` ... ```)
  String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'```json\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    return (value as num).toDouble();
  }
}
