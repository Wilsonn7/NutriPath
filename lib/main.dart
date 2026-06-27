import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/config/supabase_config.dart';
import 'core/services/supabase_service.dart';
import 'state/auth_provider.dart';
import 'state/nutrition_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  try {
    await SupabaseService.initialize(
      supabaseUrl: SupabaseConfig.supabaseUrl,
      supabaseAnonKey: SupabaseConfig.supabaseAnonKey,
    );
  } catch (e) {
    print('Error initializing Supabase: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
      ],
      child: const NutriPathApp(),
    ),
  );
}

class NutriPathApp extends StatelessWidget {
  const NutriPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriPath',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isAuthenticated) {
            return const MainWrapper();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
