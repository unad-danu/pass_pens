import 'package:supabase_flutter/supabase_flutter.dart';

class AuthUserMapper {
  static final SupabaseClient supabase = Supabase.instance.client;

  /// Mengubah UUID auth → user.id (INTEGER)
  static Future<int> getUserIdInt() async {
    final uuid = supabase.auth.currentUser?.id;

    if (uuid == null) {
      throw Exception("User belum login");
    }

    final data = await supabase
        .from("users")
        .select("id")
        .eq("id_auth", uuid)
        .maybeSingle();

    if (data == null) {
      throw Exception(
        "User dengan id_auth $uuid tidak ditemukan di tabel users",
      );
    }

    return data["id"] as int;
  }
}
