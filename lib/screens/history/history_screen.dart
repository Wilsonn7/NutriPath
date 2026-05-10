import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../state/nutrition_provider.dart';
import '../../models/food_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NutritionProvider>();
    final grouped = provider.groupedHistoryByDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: grouped.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_toggle_off, size: 60, color: AppTheme.textSecondary.withOpacity(0.6)),
                    const SizedBox(height: 12),
                    const Text('Belum ada data riwayat scan.'),
                    const SizedBox(height: 6),
                    Text(
                      'Lakukan scan makanan terlebih dahulu.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              children: grouped.entries.map((entry) {
                return _buildDateSection(context, entry.key, entry.value);
              }).toList(),
            ),
    );
  }

  Widget _buildDateSection(BuildContext context, String dateKey, List<FoodModel> items) {
    final date = DateTime.parse('$dateKey 00:00:00');
    final total = items.fold<double>(0.0, (sum, item) => sum + item.calories);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat('EEEE, d MMM yyyy').format(date),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text('${total.round()} kcal', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((f) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppTheme.surfaceLight,
                  child: Icon(f.isScanned ? Icons.document_scanner : Icons.restaurant, color: AppTheme.primary, size: 18),
                ),
                title: Text(f.name),
                subtitle: Text('P:${f.protein.round()}g  F:${f.fat.round()}g  C:${f.carbs.round()}g  Gula:${f.sugar.round()}g'),
                trailing: Text('${f.calories.round()} kcal'),
              )),
        ],
      ),
    );
  }
}

