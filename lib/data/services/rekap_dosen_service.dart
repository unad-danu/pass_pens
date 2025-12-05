import 'package:supabase_flutter/supabase_flutter.dart';

class RekapDosenService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getRekapMatkul() async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return [];

    // ================================
    // 1. Ambil user.id dari tabel users
    // ================================
    final userRow = await supabase
        .from('users')
        .select('id')
        .eq('id_auth', authUser.id)
        .maybeSingle();

    if (userRow == null) return [];

    final int userId = userRow['id'] as int;

    // ================================
    // 2. Ambil dosen.id dari tabel dosen
    // ================================
    final dosenRow = await supabase
        .from('dosen')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (dosenRow == null) return [];

    final int dosenId = dosenRow['id'] as int;

    // ================================
    // 3. Ambil jadwal (mengikuti struktur halaman jadwal dosen)
    // ================================
    final jadwal = await supabase
        .from("jadwal")
        .select("""
          id,
          pertemuan,
          matkul ( kode_mk, nama_mk ),
          kelas:kelas_id ( nama_kelas )
        """)
        .eq("dosen_id", dosenId);

    if (jadwal.isEmpty) return [];

    final jadwalIds = jadwal.map((e) => e["id"] as int).toList();

    // ================================
    // 4. Ambil absensi sesuai jadwal
    // ================================
    final absensi = await supabase
        .from("absensi")
        .select("jadwal_id, pertemuan, status")
        .inFilter("jadwal_id", jadwalIds);

    // ================================
    // 5. Hitung rekap
    // ================================
    final Map<int, Map<int, Map<String, int>>> rekap = {};

    for (var a in absensi) {
      final jId = a["jadwal_id"] as int?;
      final p = a["pertemuan"] as int?;
      final s = a["status"] as String?;

      if (jId == null || p == null || s == null) continue;

      rekap[jId] ??= {};
      rekap[jId]![p] ??= {"hadir": 0, "tidak hadir": 0};

      if (s == "hadir" || s == "tidak hadir") {
        rekap[jId]![p]![s] = (rekap[jId]![p]![s] ?? 0) + 1;
      }
    }

    // ================================
    // 6. Bentuk output akhir
    // ================================
    final result = jadwal.map((j) {
      final int jid = j["id"];
      final dataRekap = rekap[jid] ?? {};

      int totalHadir = 0;
      int totalAlpha = 0;

      for (var r in dataRekap.values) {
        totalHadir += r["hadir"] ?? 0;
        totalAlpha += r["tidak hadir"] ?? 0;
      }

      return {
        "jadwal_id": jid,
        "matkul": "${j["matkul"]["kode_mk"]} - ${j["matkul"]["nama_mk"]}",
        "kode_mk": j["matkul"]["kode_mk"],
        "nama_mk": j["matkul"]["nama_mk"],
        "kelas": j["kelas"]["nama_kelas"],
        "pertemuan": j["pertemuan"],
        "hadir": totalHadir,
        "alpha": totalAlpha,
        "rekap": dataRekap,
      };
    }).toList();

    return result;
  }
}
