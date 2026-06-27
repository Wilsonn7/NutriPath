import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../state/auth_provider.dart';
import '../../state/nutrition_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final nutrition = context.watch<NutritionProvider>();

    if (user == null) return const Center(child: CircularProgressIndicator());

    final double consumed = nutrition.totalCaloriesConsumed;
    final double goal = user.dailyCalorieGoal;
    final double percent = (consumed / goal).clamp(0.0, 1.0);
    final double remaining = (goal - consumed).clamp(0.0, double.infinity);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppTheme.primary,
            backgroundColor: AppTheme.surface,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, user).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                  const SizedBox(height: 32),
                  _buildMotivationRow(context, nutrition).animate().fadeIn(delay: 120.ms).slideY(begin: 0.1),
                  const SizedBox(height: 16),
                  _buildCalorieCard(context, consumed, goal, percent).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  const SizedBox(height: 16),
                  _buildReminderCard(context, nutrition.smartReminderMessage)
                      .animate()
                      .fadeIn(delay: 260.ms)
                      .slideY(begin: 0.15),
                  const SizedBox(height: 32),
                  _buildQuickStats(context, remaining, nutrition.totalSugarConsumed).animate().fadeIn(delay: 280.ms),
                  const SizedBox(height: 24),
                  Text(
                    'Macros Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 16),
                  _buildMacrosChart(nutrition).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Today\'s Log', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 8),
                  if (nutrition.dailyLog.isEmpty)
                    _buildEmptyLog(context).animate().fadeIn(delay: 600.ms)
                  else
                    ...nutrition.dailyLog.map((food) => _buildFoodLogTile(context, food)).toList().animate().fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationRow(BuildContext context, NutritionProvider nutrition) {
    return Row(
      children: [
        Expanded(
          child: _miniMetric(
            context,
            icon: LucideIcons.flame,
            label: 'Streak',
            value: '${nutrition.streakDays} hari',
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _miniMetric(
            context,
            icon: LucideIcons.trophy,
            label: 'Points',
            value: '${nutrition.points}',
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _miniMetric(BuildContext context, {required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
              Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.bellRing, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, double remainingCalories, double sugar) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sisa Kalori', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Text('${remainingCalories.round()} kcal', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Gula', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Text('${sugar.round()} g', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.accent)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user.name.split(' ')[0]}!',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            Text(
              'Let\'s reach your goals today',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            boxShadow: AppTheme.glowingShadow,
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.surfaceLight,
            backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                ? (user.photoUrl!.startsWith('http')
                    ? NetworkImage(user.photoUrl!)
                    : FileImage(File(user.photoUrl!)) as ImageProvider)
                : null,
            child: user.photoUrl == null || user.photoUrl!.isEmpty
                ? Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
        )
      ],
    );
  }

  Widget _buildCalorieCard(BuildContext context, double consumed, double goal, double percent) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.flame, color: AppTheme.accent, size: 20),
                    const SizedBox(width: 8),
                    Text('Calories', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      consumed.round().toString(),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 36),
                    ),
                    Text(' / ${goal.round()} kcal', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: percent >= 1.0 ? AppTheme.danger.withOpacity(0.1) : AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(percent * 100).round()}% of daily goal',
                    style: TextStyle(
                      color: percent >= 1.0 ? AppTheme.danger : AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 10,
                  color: AppTheme.surfaceLight.withOpacity(0.5),
                ),
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 10,
                  backgroundColor: Colors.transparent,
                  color: percent >= 1.0 ? AppTheme.danger : AppTheme.primary,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        percent >= 1.0 ? LucideIcons.alertTriangle : LucideIcons.target,
                        color: percent >= 1.0 ? AppTheme.danger : AppTheme.primary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosChart(NutritionProvider nutrition) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 200, 
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600);
                        String text;
                        switch (value.toInt()) {
                          case 0: text = 'Protein'; break;
                          case 1: text = 'Fat'; break;
                          case 2: text = 'Carbs'; break;
                          default: text = ''; break;
                        }
                        return SideTitleWidget(axisSide: meta.axisSide, child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            text,
                            style: style,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: AppTheme.surfaceLight.withOpacity(0.3), strokeWidth: 1, dashArray: [5, 5]);
                  },
                ),
                barGroups: [
                  _buildBarGroup(0, nutrition.totalProteinConsumed, AppTheme.purpleAccent, AppTheme.purpleGradient),
                  _buildBarGroup(1, nutrition.totalFatConsumed, AppTheme.danger, AppTheme.fireGradient),
                  _buildBarGroup(2, nutrition.totalCarbsConsumed, AppTheme.blueAccent, const LinearGradient(colors: [AppTheme.blueAccent, Color(0xFF93C5FD)])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color, LinearGradient gradient) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 24,
          gradient: gradient,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(2)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 200,
            color: AppTheme.surfaceLight.withOpacity(0.3),
          ),
        )
      ],
    );
  }

  Widget _buildEmptyLog(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.pizza, size: 32, color: AppTheme.textSecondary.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          Text('No food logged today', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Text('Tap the Scan tab to start tracking!', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFoodLogTile(BuildContext context, food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
              ]
            ),
            child: Icon(
              food.isScanned ? LucideIcons.scanLine : LucideIcons.utensilsCrossed,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildMacroChip('P: ${food.protein.round()}g', AppTheme.purpleAccent),
                    const SizedBox(width: 6),
                    _buildMacroChip('F: ${food.fat.round()}g', AppTheme.danger),
                    const SizedBox(width: 6),
                    _buildMacroChip('C: ${food.carbs.round()}g', AppTheme.blueAccent),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${food.calories.round()}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold),
              ),
              Text('kcal', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMacroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
