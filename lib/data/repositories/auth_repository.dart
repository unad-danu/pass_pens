import '../../core/services/supabase_service.dart';

class AuthRepository {
  final SupabaseService _service = SupabaseService();

  Future<bool> login(String email, String password) async {
    try {
      final result = await _service.loginCheckUser(email, password);
      return result;
    } catch (e) {
      return false;
    }
  }
}
