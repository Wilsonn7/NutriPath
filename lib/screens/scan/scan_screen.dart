import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../state/nutrition_provider.dart';
import '../../models/food_model.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  FoodModel? _scannedResult;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _scannedResult = null;
      });
      _scanFood();
    }
  }

  Future<void> _scanFood() async {
    if (_image == null) return;
    
    final provider = context.read<NutritionProvider>();
    final result = await provider.scanFood(_image!.path);
    
    if (mounted) {
      setState(() {
        _scannedResult = result;
      });
    }
  }

  void _saveToLog(bool saveToHistory) {
    if (_scannedResult != null) {
      context.read<NutritionProvider>().addFood(_scannedResult!, saveToHistory: saveToHistory);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saveToHistory ? 'Saved to Log and History!' : 'Saved to Log only!'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      setState(() {
        _image = null;
        _scannedResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<NutritionProvider>().isLoading;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AI Nutrition Scan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                    boxShadow: AppTheme.softShadow,
                    image: _image != null
                        ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.surfaceLight.withOpacity(0.5),
                              ),
                              child: const Icon(LucideIcons.camera, size: 48, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 24),
                            Text('Take a photo or upload from gallery\nto analyze nutrition.', 
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ).animate().fadeIn()
                      : null,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : () => _pickImage(ImageSource.camera),
                        icon: const Icon(LucideIcons.camera),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surfaceLight,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : () => _pickImage(ImageSource.gallery),
                        icon: const Icon(LucideIcons.image),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surfaceLight,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ).animate().slideY(begin: 0.2),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(LucideIcons.info, size: 16, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Catatan: Hasil pemindaian bersifat perkiraan dan mungkin tidak selalu akurat. Objek yang tertumpuk atau tersembunyi mungkin tidak terdeteksi.',
                        textAlign: TextAlign.justify,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70, height: 1.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (isLoading)
                  Column(
                    children: [
                      const CircularProgressIndicator(color: AppTheme.primary),
                      const SizedBox(height: 16),
                      Text('AI is analyzing your food...', style: Theme.of(context).textTheme.bodyLarge)
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(duration: 1200.ms, color: AppTheme.primary),
                    ],
                  )
                else if (_scannedResult != null)
                  _buildResultCard().animate().fadeIn().slideY(begin: 0.2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final smartSummary = _smartLabelSummary(_scannedResult!);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: AppTheme.glowingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.sparkles, color: AppTheme.accent),
              const SizedBox(width: 8),
              Text('Analysis Result', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _scannedResult!.name,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 28),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: smartSummary
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: s.$2.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: s.$2.withOpacity(0.35)),
                      ),
                      child: Text(
                        s.$1,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: s.$2),
                      ),
                    ))
                .toList(),
          ),
          const Divider(color: AppTheme.surfaceLight, height: 32),
          _buildMacroRow('Calories', '${_scannedResult!.calories.round()} kcal', LucideIcons.flame, AppTheme.accent),
          const SizedBox(height: 16),
          _buildMacroRow('Protein', '${_scannedResult!.protein.round()} g', LucideIcons.dumbbell, AppTheme.purpleAccent),
          const SizedBox(height: 16),
          _buildMacroRow('Fat', '${_scannedResult!.fat.round()} g', LucideIcons.droplets, AppTheme.danger),
          const SizedBox(height: 16),
          _buildMacroRow('Carbs', '${_scannedResult!.carbs.round()} g', LucideIcons.wheat, AppTheme.blueAccent),
          const SizedBox(height: 32),
          Text('Would you like to save this to your log?', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _saveToLog(false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Log Only', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.glowingShadow,
                  ),
                  child: ElevatedButton(
                    onPressed: () => _saveToLog(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Log & History', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary)),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  List<(String, Color)> _smartLabelSummary(FoodModel food) {
    final labels = <(String, Color)>[];
    if (food.protein >= 20) {
      labels.add(('High Protein', AppTheme.primary));
    }
    if (food.sugar <= 8) {
      labels.add(('Low Sugar', Colors.lightGreenAccent));
    } else if (food.sugar >= 18) {
      labels.add(('High Sugar', AppTheme.danger));
    }
    if (food.fat <= 10) {
      labels.add(('Low Fat', Colors.cyanAccent));
    } else if (food.fat >= 20) {
      labels.add(('High Fat', Colors.orangeAccent));
    }
    if (labels.isEmpty) {
      labels.add(('Balanced', AppTheme.primary));
    }
    return labels;
  }
}
