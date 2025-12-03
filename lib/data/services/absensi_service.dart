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

  Future<bool> bukaPresensi(
    int jadwalId, {
    required String tipePresensi,
  }) async {
    try {
      final jadwal = await supabase
          .from("jadwal")
          .select("""
          hari,
          jam_mulai,
          jam_selesai,
          dosen_id,
          kelas_mk:kelas_id ( semester )
        """)
          .eq("id", jadwalId)
          .maybeSingle();

      if (jadwal == null) return false;

      // Ambil jam_mulai & jam_selesai string
      final jamMulaiStr = jadwal["jam_mulai"]; // example: "08:50:00"
      final jamSelesaiStr = jadwal["jam_selesai"];

      // Split string
      final mulaiParts = jamMulaiStr.split(":");
      final selesaiParts = jamSelesaiStr.split(":");

      // Ambil waktu hari ini
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Buat DateTime yang benar
      final jamMulai = DateTime(
        today.year,
        today.month,
        today.day,
        int.parse(mulaiParts[0]),
        int.parse(mulaiParts[1]),
        int.parse(mulaiParts[2]),
      );

      final jamSelesai = DateTime(
        today.year,
        today.month,
        today.day,
        int.parse(selesaiParts[0]),
        int.parse(selesaiParts[1]),
        int.parse(selesaiParts[2]),
      );

      // Hitung expired
      late DateTime expiredAt;

      if (now.isAfter(jamMulai) && now.isBefore(jamSelesai)) {
        // Dalam jam kuliah → expired sesuai jadwal
        expiredAt = jamSelesai;
      } else {
        // Luar jam kuliah → expired 1 jam
        expiredAt = now.add(const Duration(hours: 1));
      }

      // Tutup semua presensi lain
      await supabase
          .from("jadwal")
          .update({"is_open": false})
          .eq("is_open", true);

      // Buka presensi
      await supabase
          .from("jadwal")
          .update({
            "is_open": true,
            "last_opened_at": now.toIso8601String(),
            "expired_at": expiredAt.toIso8601String(),
            "tipe_presensi": tipePresensi,
          })
          .eq("id", jadwalId);

      return true;
    } catch (e) {
      print("ERROR buka presensi: $e");
      return false;
    }
  }

  Future<bool> tutupPresensi(int jadwalId) async {
    try {
      await supabase
          .from('jadwal')
          .update({'is_open': false, 'expired_at': null})
          .eq('id', jadwalId);

      return true;
    } catch (_) {
      return false;
    }
  }

  // ===============================
  // PERINGKATAN / PERTEMUAN
  // ===============================
  Future<int> _getPertemuanAktif(int jadwalId) async {
    final data = await supabase
        .from("jadwal")
        .select("pertemuan")
        .eq("id", jadwalId)
        .maybeSingle();

    return data?["pertemuan"] ?? 1;
  }
}
