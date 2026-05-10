import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../state/nutrition_provider.dart';
import '../../models/food_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _sugarCtrl = TextEditingController();

  List<FoodModel> _results = [];
  bool _hasSearched = false;
  bool _isSearching = false;

  Future<void> _search() async {
    final calories = double.tryParse(_caloriesCtrl.text);

    // Hanya calories yang wajib. Sisanya opsional.
    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Masukkan target kalori (harus > 0). Protein, lemak, gula opsional.',
          ),
        ),
      );
      return;
    }

    // Parse optional fields
    final protein = double.tryParse(_proteinCtrl.text);
    final fat = double.tryParse(_fatCtrl.text);
    final sugar = double.tryParse(_sugarCtrl.text);

    setState(() {
      _hasSearched = true;
      _isSearching = true;
      _results = [];
    });

    try {
      // Kirim ke dataset search untuk pencarian rekomendasi makanan
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
          SnackBar(
            content: Text('Error mencari rekomendasi: ${error.toString()}'),
          ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutritional Search'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Find food by nutrition',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your target macros and we will find the closest match.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _caloriesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Calories (kcal) *',
                      prefixIcon: Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _proteinCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Protein (g)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _fatCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Fat (g)',
                          ),
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
                        Text(
                          'Recommendations',
                          style: Theme.of(context).textTheme.titleLarge,
                        ).animate().fadeIn(),
                        const SizedBox(height: 16),
                        if (_results.isEmpty)
                          const Text(
                            'No recommendations found for these values.',
                          )
                        else
                          ..._results
                              .map((food) => _buildRecommendationCard(food))
                              .toList()
                              .animate()
                              .fadeIn(delay: 200.ms),
                      ],
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(FoodModel food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                food.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${food.calories.round()} kcal',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroBadge(
                'Protein',
                '${food.protein.round()}g',
                Colors.blue,
              ),
              _buildMacroBadge('Fat', '${food.fat.round()}g', Colors.red),
              _buildMacroBadge('Carbs', '${food.carbs.round()}g', Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
