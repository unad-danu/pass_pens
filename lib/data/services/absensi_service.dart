import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AbsensiService {
  final supabase = Supabase.instance.client;

  // ===============================
  // PRESENSI ONLINE
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
  // PRESENSI OFFLINE (foto + lokasi)
  // ===============================
  Future<void> presensiOffline({
    required int mhsId,
    required int jadwalId,
    required File foto,
    required double lat,
    required double lng,
  }) async {
    final pertemuan = await _getPertemuanAktif(jadwalId);

    // Upload foto ke Supabase Storage
    final filePath =
        "absensi/$jadwalId/$mhsId-${DateTime.now().millisecondsSinceEpoch}.jpg";

    final uploaded = await supabase.storage
        .from("foto-presensi")
        .upload(filePath, foto);

    final fotoUrl = supabase.storage
        .from("foto-presensi")
        .getPublicUrl(filePath);

    // Insert ke tabel absensi
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
  // BUKA PRESENSI (Online / Offline)
  // ===============================
  Future<bool> bukaPresensi(int jadwalId, String tipe) async {
    try {
      final pertemuan = await _getPertemuanAktif(jadwalId);

      // Insert into 'presensi' table to open attendance
      await supabase.from('presensi').insert({
        'jadwal_id': jadwalId,
        'tipe': tipe.toLowerCase(), // "online" or "offline"
        'pertemuan': pertemuan,
        // Add other fields if needed, e.g., created_at will be auto-handled
      });

      return true;
    } catch (e) {
      // Handle error, perhaps log it
      return false;
    }
  }

  // ===============================
  // Ambil pertemuan aktif
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
