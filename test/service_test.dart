import 'package:test/test.dart';
import '../lib/core/services/openai_food_service.dart';

void main() {
  test('OpenAIFoodService initialization', () {
    final service = OpenAIFoodService(apiKey: 'test-key');
    expect(service.isConfigured, true);
  });

  test('OpenAIFoodService with empty key', () {
    final service = OpenAIFoodService(apiKey: '');
    expect(service.isConfigured, false);
  });
}