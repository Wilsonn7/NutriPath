import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();
  String? _selectedPhotoPath;
  String? _loadedUserId;
  late TextEditingController _weightCtrl;
  late TextEditingController _targetWeightCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _birthDateCtrl;
  late TextEditingController _ageCtrl;
  DateTime? _birthDate;
  late String _activityLevel;
  late String _gender;

  bool _isEditing = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _targetWeightCtrl.dispose();
    _heightCtrl.dispose();
    _birthDateCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _selectedPhotoPath = null;
    _weightCtrl = TextEditingController();
    _targetWeightCtrl = TextEditingController();
    _heightCtrl = TextEditingController();
    _birthDateCtrl = TextEditingController();
    _ageCtrl = TextEditingController();
    _activityLevel = 'moderate';
    _gender = 'Male';
  }

  void _syncUserControllers(AuthProvider auth) {
    final user = auth.currentUser;
    if (user == null || _loadedUserId == user.id) return;

    _loadedUserId = user.id;
    _selectedPhotoPath = user.photoUrl;
    _weightCtrl.text = user.weight.toString();
    _targetWeightCtrl.text = user.targetWeight.toString();
    _heightCtrl.text = user.height.toString();
    _ageCtrl.text = user.age.toString();
    _birthDateCtrl.text = '';
    _activityLevel = user.activityLevel;
    _gender = user.gender;
  }

  void _saveProfile() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser!;
    String? photoUrl = _selectedPhotoPath;

    if (_selectedPhotoPath != null && !_selectedPhotoPath!.startsWith('http')) {
      try {
        final file = File(_selectedPhotoPath!);
        if (await file.exists()) {
          photoUrl = await auth.uploadProfilePhoto(file);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload foto profil: ${e.toString()}')),
        );
        return;
      }
    }

    final updatedUser = user.copyWith(
      weight: double.tryParse(_weightCtrl.text) ?? user.weight,
      targetWeight:
          double.tryParse(_targetWeightCtrl.text) ?? user.targetWeight,
      height: double.tryParse(_heightCtrl.text) ?? user.height,
      age: int.tryParse(_ageCtrl.text) ?? user.age,
      gender: _gender,
      activityLevel: _activityLevel,
      photoUrl: photoUrl,
    );

    await auth.updateProfile(updatedUser);

    if (!mounted) return;
    setState(() {
      _isEditing = false;
    });
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    final age = today.year - birthDate.year;
    final hasHadBirthdayThisYear = (today.month > birthDate.month) ||
        (today.month == birthDate.month && today.day >= birthDate.day);
    return hasHadBirthdayThisYear ? age : age - 1;
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _birthDate = picked;
      _birthDateCtrl.text = '${picked.day}/${picked.month}/${picked.year}';
      _ageCtrl.text = _calculateAge(picked).toString();
    });
  }


  Future<void> _pickProfileImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (pickedFile == null) return;

    setState(() {
      _selectedPhotoPath = pickedFile.path;
    });
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Choose Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickProfileImage(ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take a Photo'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickProfileImage(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
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
    final auth = context.watch<AuthProvider>();
    _syncUserControllers(auth);
    final user = auth.currentUser;
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
              GestureDetector(
                onTap: _isEditing ? _showPhotoOptions : null,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primary.withOpacity(0.2),
                      backgroundImage: _selectedPhotoPath != null && _selectedPhotoPath!.isNotEmpty
                          ? (_selectedPhotoPath!.startsWith('http')
                              ? NetworkImage(_selectedPhotoPath!)
                              : FileImage(File(_selectedPhotoPath!)) as ImageProvider)
                          : null,
                      child: _selectedPhotoPath == null || _selectedPhotoPath!.isEmpty
                          ? Text(
                              user.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    if (_isEditing)
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.glowingShadow,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.camera_alt, size: 18, color: AppTheme.primary),
                      ),
                  ],
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
                    TextFormField(
                      controller: _birthDateCtrl,
                      readOnly: true,
                      onTap: _isEditing ? _selectBirthDate : null,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.cake, color: AppTheme.textSecondary),
                        suffixIcon: Icon(Icons.calendar_month),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.timelapse, color: AppTheme.textSecondary),
                      ),
                    ),
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
