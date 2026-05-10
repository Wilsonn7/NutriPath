import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../state/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _targetWeightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = 'Male';
  String _activityLevel = 'moderate';

  final _formKey = GlobalKey<FormState>();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<AuthProvider>().register(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
            name: _nameCtrl.text,
            weight: double.parse(_weightCtrl.text),
            targetWeight: double.parse(_targetWeightCtrl.text),
            height: double.parse(_heightCtrl.text),
            age: int.parse(_ageCtrl.text),
            gender: _gender,
            activityLevel: _activityLevel,
          );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil dibuat. Silakan login.')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        final error = context.read<AuthProvider>().errorMessage ?? 'Registrasi gagal.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text(
                  'Join NutriPath and transform your health',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full Name
                      _buildTextField(
                        controller: _nameCtrl,
                        label: 'Full Name',
                        icon: LucideIcons.user,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ).animate().slideX(delay: 300.ms, begin: 0.2),
                      const SizedBox(height: 16),

                      // Email
                      _buildTextField(
                        controller: _emailCtrl,
                        label: 'Email Address',
                        icon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ).animate().slideX(delay: 350.ms, begin: 0.2),
                      const SizedBox(height: 16),

                      // Password
                      _buildTextField(
                        controller: _passwordCtrl,
                        label: 'Password',
                        icon: LucideIcons.lock,
                        obscureText: true,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ).animate().slideX(delay: 400.ms, begin: 0.2),
                      const SizedBox(height: 16),

                      // ✅ Current Weight & Target Weight — font label diperkecil
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _weightCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Current Weight (kg)',
                                prefixIcon: const Icon(LucideIcons.scale, color: AppTheme.textSecondary),
                                labelStyle: const TextStyle(fontSize: 11),
                                floatingLabelStyle: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primary,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 16,
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ).animate().slideX(delay: 450.ms, begin: 0.2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _targetWeightCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Target Weight (kg)',
                                prefixIcon: const Icon(LucideIcons.target, color: AppTheme.textSecondary),
                                labelStyle: const TextStyle(fontSize: 11),
                                floatingLabelStyle: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primary,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 16,
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ).animate().slideX(delay: 450.ms, begin: 0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Height
                      _buildTextField(
                        controller: _heightCtrl,
                        label: 'Height (cm)',
                        icon: LucideIcons.ruler,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ).animate().slideX(delay: 450.ms, begin: 0.2),
                      const SizedBox(height: 16),

                      // ✅ Age — baris sendiri
                      _buildTextField(
                        controller: _ageCtrl,
                        label: 'Age',
                        icon: LucideIcons.calendar,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ).animate().slideX(delay: 500.ms, begin: 0.2),
                      const SizedBox(height: 16),

                      // ✅ Gender — baris sendiri (tidak digabung Age)
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(LucideIcons.users, color: AppTheme.textSecondary),
                        ),
                        icon: const Icon(LucideIcons.chevronDown, color: AppTheme.textSecondary),
                        dropdownColor: AppTheme.surface,
                        items: ['Male', 'Female'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _gender = val);
                        },
                      ).animate().slideX(delay: 500.ms, begin: 0.2),
                      const SizedBox(height: 16),

                      // Activity Level
                      DropdownButtonFormField<String>(
                        value: _activityLevel,
                        decoration: const InputDecoration(
                          labelText: 'Activity Level',
                          prefixIcon: Icon(LucideIcons.activity, color: AppTheme.textSecondary),
                        ),
                        icon: const Icon(LucideIcons.chevronDown, color: AppTheme.textSecondary),
                        dropdownColor: AppTheme.surface,
                        items: const [
                          DropdownMenuItem(value: 'sedentary', child: Text('Sedentary')),
                          DropdownMenuItem(value: 'light', child: Text('Lightly Active')),
                          DropdownMenuItem(value: 'moderate', child: Text('Moderately Active')),
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                          DropdownMenuItem(value: 'very_active', child: Text('Very Active')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _activityLevel = val);
                        },
                      ).animate().slideX(delay: 550.ms, begin: 0.2),
                      const SizedBox(height: 32),

                      // Sign Up Button
                      auth.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: AppTheme.primary),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppTheme.glowingShadow,
                              ),
                              child: ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ).animate().scale(delay: 600.ms),
                    ],
                  ),
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
      ),
      validator: validator,
    );
  }
}