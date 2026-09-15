// lib/utils/env.dart
class Env {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static bool get isValid => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}