import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../state/auth_provider.dart';
import '../../state/nutrition_provider.dart';
import '../../models/food_model.dart';

class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final nutrition = context.watch<NutritionProvider>();

    if (user == null) return const SizedBox.shrink();

    final remainingCalories = user.dailyCalorieGoal - nutrition.totalCaloriesConsumed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insight'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<String>(
              future: nutrition.getAIInsight(user),
              builder: (context, snapshot) {
                final insightText = snapshot.connectionState == ConnectionState.waiting
                    ? 'Mengambil insight dari AI...'
                    : snapshot.hasError
                        ? 'Insight AI tidak tersedia saat ini. Coba lagi nanti.'
                        : snapshot.data ?? 'Tidak ada insight tersedia.';

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Daily Feedback',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        insightText,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                );
              },
            ).animate().slideY(begin: 0.1).fadeIn(),
            const SizedBox(height: 32),
            FutureBuilder<List<FoodModel>>(
              future: nutrition.getFoodRecommendations(remainingCalories),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.accent.withOpacity(0.5), width: 2),
                    ),
                    child: Text(
                      'Rekomendasi makanan akan ditampilkan berdasarkan analisis AI. Jika AI tidak tersedia, rekomendasi default akan ditampilkan.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                final recommendations = snapshot.data ?? [];
                if (recommendations.isNotEmpty && remainingCalories > 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekomendasi Makanan',
                        style: Theme.of(context).textTheme.titleLarge,
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 8),
                      Text(
                        'AI akan menganalisis catatan makananmu hari ini dan memberikan rekomendasi makanan yang sesuai dengan kebutuhan nutrisi serta sisa kalori.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 16),
                      ...recommendations.map((food) => _buildRecommendationCard(context, food)).toList().animate().fadeIn(delay: 300.ms),
                    ],
                  );
                }

                if (remainingCalories <= 0) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.danger.withOpacity(0.5), width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'You have reached or exceeded your calorie limit for today. Focus on hydration!',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms);
                }

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.5), width: 2),
                  ),
                  child: Text(
                    'Rekomendasi makanan sedang dianalisis oleh AI. Pastikan AI tersedia dan data konsumsi harian tersedia.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              },
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, FoodModel food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.restaurant_menu, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${food.calories.round()} kcal • P: ${food.protein.round()}g',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.primary),
            onPressed: () {
              context.read<NutritionProvider>().addFood(food, saveToHistory: false);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added suggestion to log!')));
            },
          ),
        ],
      ),
    );
  }
}
