import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://odupjjclwqjxovnllbld.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9kdXBqamNsd3FqeG92bmxsYmxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyNjA0MDMsImV4cCI6MjA3ODgzNjQwM30.8cQJyZXzXdO4YKV2s8CnjYt2KRzDMsWYiDEZ5PaTv4Q',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
