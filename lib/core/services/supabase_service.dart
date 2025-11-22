import '../../core/config/supabase_config.dart';

class SupabaseService {
  final supabase = SupabaseConfig.client;

  Future<bool> loginCheckUser(String email, String pass) async {
    final data = await supabase
        .from("users")
        .select()
        .eq("email", email)
        .eq("pass_hash", pass)
        .maybeSingle();

    return data != null;
  }
}
