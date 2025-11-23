import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_config.dart';
import '../../core/endpoints.dart';
import '../../core/roles.dart';
import '../models/user.dart';
import '../models/mahasiswa.dart';
import '../models/dosen.dart';

class AuthService {
  final supabase = SupabaseConfig.client;

  /// LOGIN
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) return null;

      return await getUserWithProfile(user.id);
    } catch (_) {
      return null;
    }
  }

  /// REGISTER (email + password)
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> extraProfile,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) return null;

      final String role = extraProfile['role'];

      // SIMPAN ke tabel users (role)
      await supabase.from(Endpoints.users).insert({
        "id": user.id,
        "email": email,
        "role": role,
      });

      // SIMPAN biodata
      if (role == "mahasiswa") {
        await supabase.from(Endpoints.mahasiswa).insert({
          "id": user.id,
          "nama": extraProfile["nama"],
          "nrp": extraProfile["nrp"],
          "prodi": extraProfile["prodi"],
          "angkatan": extraProfile["angkatan"],
          "email_recovery": extraProfile["email_recovery"],
          "phone": extraProfile["phone"],
        });
      } else {
        await supabase.from(Endpoints.dosen).insert({
          "id": user.id,
          "nama": extraProfile["nama"],
          "nip": extraProfile["nip"],
          "prodi_ajar": extraProfile["prodi_ajar"],
          "email_recovery": extraProfile["email_recovery"],
          "phone": extraProfile["phone"],
        });
      }

      return await getUserWithProfile(user.id);
    } catch (_) {
      return null;
    }
  }

  /// GET USER + PROFIL LENGKAP
  Future<UserModel?> getUserWithProfile(String userId) async {
    final data = await supabase
        .from(Endpoints.users)
        .select()
        .eq("id", userId)
        .maybeSingle();

    if (data == null) return null;

    final role = data["role"];

    Map<String, dynamic>? profile;

    if (role == "mahasiswa") {
      profile = await supabase
          .from(Endpoints.mahasiswa)
          .select()
          .eq("id", userId)
          .maybeSingle();
    } else {
      profile = await supabase
          .from(Endpoints.dosen)
          .select()
          .eq("id", userId)
          .maybeSingle();
    }

    return UserModel(
      id: data["id"],
      email: data["email"],
      role: role == "mahasiswa" ? UserRole.mahasiswa : UserRole.dosen,
      profile: profile,
    );
  }
}
