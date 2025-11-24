import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_config.dart';
import '../../core/endpoints.dart';
import '../models/user.dart';
import '../models/mahasiswa.dart';
import '../models/dosen.dart';

class AuthService {
  final supabase = SupabaseConfig.client;

  bool isValidMahasiswa(String email) {
    final e = email.toLowerCase();
    return RegExp(r'^[a-z0-9]+@[a-z]+\.student\.pens\.ac\.id$').hasMatch(e);
  }

  bool isValidDosen(String email) {
    return email.toLowerCase().endsWith("@lecturer.pens.ac.id");
  }

  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> extraProfile,
  }) async {
    try {
      final String role = extraProfile['role'];

      if (role == "mahasiswa" && !isValidMahasiswa(email)) {
        throw Exception("Email mahasiswa tidak valid!");
      }
      if (role == "dosen" && !isValidDosen(email)) {
        throw Exception("Email dosen tidak valid!");
      }

      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception("SIGNUP gagal! Tidak ada user!");
      }

      final user = response.user!;
      print("SIGNUP SUCCESS: ${user.email}");

      await supabase.from('users').insert({
        'id': user.id,
        'nama': extraProfile['nama'],
        'email': email,
        'role': role,
        'status': 'aktif',
      });

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
    } catch (e) {
      print("SIGNUP ERROR: $e");
      rethrow;
    }
  }

  Future<UserModel?> getUserWithProfile(String userId) async {
    try {
      final userRes = await supabase
          .from(Endpoints.users)
          .select()
          .eq("id", userId)
          .maybeSingle();

      if (userRes == null) return null;

      final role = userRes["role"];

      if (role == "mahasiswa") {
        final mhs = await supabase
            .from(Endpoints.mahasiswa)
            .select()
            .eq("id", userId)
            .maybeSingle();

        return UserModel(
          id: userRes["id"],
          email: userRes["email"],
          role: role,
          mahasiswa: mhs != null
              ? MahasiswaModel.fromMap(mhs as Map<String, dynamic>)
              : null,
          dosen: null,
        );
      }

      if (role == "dosen") {
        final dsn = await supabase
            .from(Endpoints.dosen)
            .select()
            .eq("id", userId)
            .maybeSingle();

        return UserModel(
          id: userRes["id"],
          email: userRes["email"],
          role: role,
          mahasiswa: null,
          dosen: dsn != null
              ? DosenModel.fromMap(dsn as Map<String, dynamic>)
              : null,
        );
      }

      return null;
    } catch (e) {
      print("GET USER PROFILE ERROR: $e");
      rethrow;
    }
  }
}
