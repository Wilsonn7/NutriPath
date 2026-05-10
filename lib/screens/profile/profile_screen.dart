import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../state/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _weightCtrl;
  late TextEditingController _targetWeightCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _ageCtrl;
  late String _activityLevel;
  late String _gender;

  bool _isEditing = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _targetWeightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;

    _weightCtrl = TextEditingController(text: user.weight.toString());
    _targetWeightCtrl = TextEditingController(
      text: user.targetWeight.toString(),
    );
    _heightCtrl = TextEditingController(text: user.height.toString());
    _ageCtrl = TextEditingController(text: user.age.toString());
    _activityLevel = user.activityLevel;
    _gender = user.gender;
  }

  void _saveProfile() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser!;

    final updatedUser = user.copyWith(
      weight: double.tryParse(_weightCtrl.text) ?? user.weight,
      targetWeight:
          double.tryParse(_targetWeightCtrl.text) ?? user.targetWeight,
      height: double.tryParse(_heightCtrl.text) ?? user.height,
      age: int.tryParse(_ageCtrl.text) ?? user.age,
      gender: _gender,
      activityLevel: _activityLevel,
    );

    await auth.updateProfile(updatedUser);

    if (!mounted) return;
    setState(() {
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully! Goals recalculated.'),
        ),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();

    final safeAreaBottom = MediaQuery.of(context).viewPadding.bottom;
    const double navBarHeight = 150;
    final double bottomPadding = safeAreaBottom + navBarHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primary.withOpacity(0.2),
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate().scale(),
              const SizedBox(height: 16),
              Text(user.name, style: Theme.of(context).textTheme.titleLarge),
              Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Physical Info',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Weight (kg)',
                      _weightCtrl,
                      Icons.monitor_weight,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Target Weight (kg)',
                      _targetWeightCtrl,
                      Icons.track_changes,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField('Height (cm)', _heightCtrl, Icons.height),
                    const SizedBox(height: 16),
                    _buildTextField('Age', _ageCtrl, Icons.cake),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(
                          Icons.people_outline,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text('Female'),
                        ),
                      ],
                      onChanged: _isEditing
                          ? (val) {
                              if (val != null) setState(() => _gender = val);
                            }
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _activityLevel,
                      decoration: const InputDecoration(
                        labelText: 'Activity Level',
                        prefixIcon: Icon(
                          Icons.directions_run,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'sedentary',
                          child: Text('Sedentary'),
                        ),
                        DropdownMenuItem(
                          value: 'light',
                          child: Text('Lightly Active'),
                        ),
                        DropdownMenuItem(
                          value: 'moderate',
                          child: Text('Moderately Active'),
                        ),
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: 'very_active',
                          child: Text('Very Active'),
                        ),
                      ],
                      onChanged: _isEditing
                          ? (val) {
                              if (val != null) {
                                setState(() => _activityLevel = val);
                              }
                            }
                          : null,
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Text('Save Changes'),
                        ),
                      ).animate().fadeIn(),
                    ],
                  ],
                ),
              ).animate().slideY(begin: 0.1),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: AppTheme.danger),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(color: AppTheme.danger),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.danger),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
      ),
    );
  }
}
