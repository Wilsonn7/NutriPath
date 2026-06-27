/// Supabase configuration
/// Supabase credentials are configured for the current project.
class SupabaseConfig {
  /// Your Supabase project URL
  /// Format: https://[project-id].supabase.co
  static const String supabaseUrl = 'https://qjruqqheyyysbxlodplv.supabase.co';

  /// Your Supabase anonymous key (public key)
  /// Get from: Project Settings > API > Project API keys
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqcnVxcWhleXl5c2J4bG9kcGx2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxNzQ0MjMsImV4cCI6MjA5NDc1MDQyM30.2tX1OHBabeO59zwxk-bUNXwLvlElWPpN7aVz5sjUrqU';

  /// Optional: Enable debug logging
  static const bool debugMode = true;
}
