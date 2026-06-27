import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../state/auth_provider.dart';
import '../../state/nutrition_provider.dart';
import '../../models/food_model.dart';

enum SearchInsightTab { search, insight }

class SearchInsightScreen extends StatefulWidget {
  const SearchInsightScreen({super.key});

  @override
  State<SearchInsightScreen> createState() => _SearchInsightScreenState();
}

class _SearchInsightScreenState extends State<SearchInsightScreen> {
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _sugarCtrl = TextEditingController();

  List<FoodModel> _results = [];
  bool _hasSearched = false;
  bool _isSearching = false;
  SearchInsightTab _selectedTab = SearchInsightTab.search;

  Future<void> _search() async {
    final calories = double.tryParse(_caloriesCtrl.text);

    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan target kalori (harus > 0). Protein, lemak, gula opsional.'),
        ),
      );
      return;
    }

    final protein = double.tryParse(_proteinCtrl.text);
    final fat = double.tryParse(_fatCtrl.text);
    final sugar = double.tryParse(_sugarCtrl.text);

    setState(() {
      _hasSearched = true;
      _isSearching = true;
      _results = [];
    });

    try {
      final results = await context
          .read<NutritionProvider>()
          .searchFoodRecommendations(calories, sugar, fat, protein);
      if (!mounted) return;
      setState(() {
        _results = results;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error mencari rekomendasi: ${error.toString()}')),
        );
        setState(() {
          _results = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final nutrition = context.watch<NutritionProvider>();
    final remainingCalories = user != null ? user.dailyCalorieGoal - nutrition.totalCaloriesConsumed : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTabSelector(context),
              const SizedBox(height: 24),
              if (_selectedTab == SearchInsightTab.search) _buildSearchContent(context),
              if (_selectedTab == SearchInsightTab.insight) _buildInsightContent(context, user, nutrition, remainingCalories),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedTab == SearchInsightTab.search ? AppTheme.primary : AppTheme.surface,
              foregroundColor: _selectedTab == SearchInsightTab.search ? Colors.white : AppTheme.textSecondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: _selectedTab == SearchInsightTab.search ? 4 : 0,
            ),
            onPressed: () => setState(() => _selectedTab = SearchInsightTab.search),
            child: const Text('Search'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedTab == SearchInsightTab.insight ? AppTheme.primary : AppTheme.surface,
              foregroundColor: _selectedTab == SearchInsightTab.insight ? Colors.white : AppTheme.textSecondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: _selectedTab == SearchInsightTab.insight ? 4 : 0,
            ),
            onPressed: () => setState(() => _selectedTab = SearchInsightTab.insight),
            child: const Text('Insight'),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Find food by nutrition', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('Enter your target macros and we will find the closest match.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(32)),
          child: Column(
            children: [
              TextFormField(
                controller: _caloriesCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Calories (kcal) *',
                  prefixIcon: Icon(Icons.local_fire_department, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Protein (g)'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _fatCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Fat (g)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sugarCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sugar (g)'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search),
                  label: const Text('Find Recommendations'),
                ),
              ),
            ],
          ),
        ).animate().slideY(begin: 0.1),
        const SizedBox(height: 32),
        if (_hasSearched)
          _isSearching
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recommendations', style: Theme.of(context).textTheme.titleLarge).animate().fadeIn(),
                    const SizedBox(height: 16),
                    if (_results.isEmpty)
                      const Text('No recommendations found for these values.')
                    else
                      ..._results.map((food) => _buildRecommendationCard(food)).toList().animate().fadeIn(delay: 200.ms),
                  ],
                ),
      ],
    );
  }

  Widget _buildInsightContent(BuildContext context, dynamic user, NutritionProvider nutrition, double remainingCalories) {
    if (user == null) {
      return Center(
        child: Text('Login terlebih dahulu untuk melihat insight.', style: Theme.of(context).textTheme.bodyLarge),
      );
    }

    return Column(
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
                  Text('Daily Feedback', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 12),
                  Text(insightText, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.9))),
                ],
              ),
            );
          },
        ).animate().slideY(begin: 0.1).fadeIn(),
        const SizedBox(height: 24),
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
                child: Text('Rekomendasi makanan akan ditampilkan berdasarkan analisis AI. Jika AI tidak tersedia, rekomendasi default akan ditampilkan.', style: Theme.of(context).textTheme.bodyMedium),
              );
            }

            final recommendations = snapshot.data ?? [];
            if (recommendations.isNotEmpty && remainingCalories > 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rekomendasi Makanan', style: Theme.of(context).textTheme.titleLarge).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  Text('AI akan menganalisis catatan makananmu hari ini dan memberikan rekomendasi makanan yang sesuai dengan kebutuhan nutrisi serta sisa kalori.', style: Theme.of(context).textTheme.bodyMedium).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 16),
                  ...recommendations.map((food) => _buildInsightRecommendationCard(context, food)).toList().animate().fadeIn(delay: 300.ms),
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
                    Expanded(child: Text('You have reached or exceeded your calorie limit for today. Focus on hydration!', style: Theme.of(context).textTheme.bodyMedium)),
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
              child: Text('Rekomendasi makanan sedang dianalisis oleh AI. Pastikan AI tersedia dan data konsumsi harian tersedia.', style: Theme.of(context).textTheme.bodyMedium),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(FoodModel food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surfaceLight.withOpacity(0.5), borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(food.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Text('${food.calories.round()} kcal', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildMacroBadge('Protein', '${food.protein.round()}g', Colors.blue),
          _buildMacroBadge('Fat', '${food.fat.round()}g', Colors.red),
          _buildMacroBadge('Carbs', '${food.carbs.round()}g', Colors.amber),
        ]),
      ]),
    );
  }

  Widget _buildMacroBadge(String label, String value, Color color) {
    return Column(children: [Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)), Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))]);
  }

  Widget _buildInsightRecommendationCard(BuildContext context, FoodModel food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.restaurant_menu, color: AppTheme.primary)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(food.name, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 4), Text('${food.calories.round()} kcal • P: ${food.protein.round()}g', style: Theme.of(context).textTheme.bodyMedium)])),
        IconButton(icon: const Icon(Icons.add_circle, color: AppTheme.primary), onPressed: () { context.read<NutritionProvider>().addFood(food, saveToHistory: false); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added suggestion to log!'))); }),
      ]),
    );
  }
}
