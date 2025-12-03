import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AbsensiService {
  final supabase = Supabase.instance.client;

  // ===============================
  // PRESENSI ONLINE (MAHASISWA)
  // ===============================
  Future<void> presensiOnline({
    required int mhsId,
    required int jadwalId,
  }) async {
    final pertemuan = await _getPertemuanAktif(jadwalId);

    await supabase.from("absensi").insert({
      "mhs_id": mhsId,
      "jadwal_id": jadwalId,
      "tipe": "online",
      "status": "hadir",
      "pertemuan": pertemuan,
      "foto_url": null,
      "lat": null,
      "lng": null,
    });
  }

  // ===============================
  // PRESENSI OFFLINE (MAHASISWA)
  // ===============================
  Future<void> presensiOffline({
    required int mhsId,
    required int jadwalId,
    required File foto,
    required double lat,
    required double lng,
  }) async {
    final pertemuan = await _getPertemuanAktif(jadwalId);

    final filePath =
        "absensi/$jadwalId/$mhsId-${DateTime.now().millisecondsSinceEpoch}.jpg";

    await supabase.storage.from("foto-presensi").upload(filePath, foto);

    final fotoUrl = supabase.storage
        .from("foto-presensi")
        .getPublicUrl(filePath);

    await supabase.from("absensi").insert({
      "mhs_id": mhsId,
      "jadwal_id": jadwalId,
      "tipe": "offline",
      "status": "hadir",
      "pertemuan": pertemuan,
      "foto_url": fotoUrl,
      "lat": lat,
      "lng": lng,
    });
  }

  // ===============================
  // BUKA PRESENSI (DOSEN)
  // ===============================
  Future<bool> bukaPresensi({
    required int jadwalId,
    required String tipe,
  }) async {
    try {
      // 1. Ambil informasi jadwal yg ingin dibuka
      final jadwal = await supabase
          .from("jadwal")
          .select("hari, jam_mulai, jam_selesai, kelas, semester, dosen_id")
          .eq("id", jadwalId)
          .maybeSingle();

      if (jadwal == null) return false;

      final hari = jadwal["hari"];
      final jamMulai = jadwal["jam_mulai"];
      final jamSelesai = jadwal["jam_selesai"];
      final kelas = jadwal["kelas"];
      final semester = jadwal["semester"];
      final dosenId = jadwal["dosen_id"];

      // ===============================
      // CEK 1: DOSEN SEDANG MENGAJAR?
      // ===============================
      final cekJadwalDosen = await supabase
          .from("jadwal")
          .select("id")
          .eq("dosen_id", dosenId)
          .eq("hari", hari)
          .or("jam_mulai < '$jamSelesai' AND jam_selesai > '$jamMulai'")
          .limit(1);

      final dosenSedangMengajar = cekJadwalDosen.isNotEmpty;

      // Jika dosen sedang mengajar → BOLEH langsung buka
      if (dosenSedangMengajar) {
        return await _insertPresensi(jadwalId, tipe);
      }

      // ======================================
      // CEK 2: MAHASISWA PUNYA JADWAL LAIN?
      // ======================================
      final cekBentrokMhs = await supabase
          .from("jadwal")
          .select("id")
          .eq("kelas", kelas)
          .eq("semester", semester)
          .eq("hari", hari)
          .neq("id", jadwalId)
          .or("jam_mulai < '$jamSelesai' AND jam_selesai > '$jamMulai'")
          .limit(1);

      if (cekBentrokMhs.isNotEmpty) {
        return false; // mahasiswa ada jadwal lain → tidak boleh buka
      }

      // Tidak bentrok → boleh buka
      return await _insertPresensi(jadwalId, tipe);
    } catch (e) {
      return false;
    }
  }

  // Insert presensi
  Future<bool> _insertPresensi(int jadwalId, String tipe) async {
    final now = DateTime.now();
    final autoClose = now.add(const Duration(hours: 1));

    await supabase.from("presensi").insert({
      "jadwal_id": jadwalId,
      "tipe": tipe,
      "pertemuan": await _getPertemuanAktif(jadwalId),
      "opened_at": now.toIso8601String(),
      "auto_close_at": autoClose.toIso8601String(),
    });

    return true;
  }

  // ===============================
  // PERINGKATAN
  // ===============================
  Future<int> _getPertemuanAktif(int jadwalId) async {
    final data = await supabase
        .from("jadwal")
        .select("pertemuan")
        .eq("id", jadwalId)
        .maybeSingle();

    if (data == null || data["pertemuan"] == null) {
      return 1;
    }

    return data["pertemuan"] as int;
  }
}
