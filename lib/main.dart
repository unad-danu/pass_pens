import 'package:flutter/material.dart';
import 'app.dart';
import 'core/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await SupabaseConfig.init();

  runApp(const MyApp());
}
