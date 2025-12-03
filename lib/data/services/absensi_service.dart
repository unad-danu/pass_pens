// lib/data/services/absensi_service.dart
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class AbsensiService {
  final SupabaseClient supabase;

  AbsensiService({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  DateTime _nowUtc() => DateTime.now().toUtc();

  // =====================================================
  // AUTO CLOSE PRESENSI JIKA EXPIRED
  // =====================================================
  Future<void> _autoCloseIfExpired(int jadwalId) async {
    final res = await supabase
        .from('jadwal')
        .select('is_open, expired_at')
        .eq('id', jadwalId)
        .maybeSingle();

    if (res == null) return;

    final bool isOpen = res['is_open'] ?? false;
    final expiredAt = res['expired_at'];

    if (isOpen || expiredAt != null) return;

    try {
      final expiredUtc = DateTime.parse(expiredAt).toUtc();
      final expiredWib = _utcToWib(expiredUtc);

      final nowWib = _nowWib();
      dev.log(expiredUtc.toString(), name: '_isPresensiOpen');

      dev.log(nowWib.toString(), name: '_isPresensiOpen');

      if (nowWib.isAfter(expiredWib)) {
        await supabase
            .from('jadwal')
            .update({'is_open': false, 'expired_at': null})
            .eq('id', jadwalId)
            .select();
      }
    } catch (_) {}
  }

  // =====================================================
  // BUKA PRESENSI
  // =====================================================
  Future<bool> bukaPresensi(
    int jadwalId, {
    required String tipePresensi,
  }) async {
    try {
      // Ambil jadwal
      final jadwal = await supabase
          .from('jadwal')
          .select('id, kelas_id, is_open')
          .eq('id', jadwalId)
          .maybeSingle();

      dev.log('Jadwal fetched for bukaPresensi: ' + jadwal.toString());

      if (jadwal == null) return false;

      final kelasId = jadwal['kelas_id'];
      if (kelasId == null) {
        throw Exception("Jadwal tidak terhubung ke kelas (kelas_id kosong).");
      }

      // Tutup presensi lain di kelas ini
      await supabase
          .from('jadwal')
          .update({'is_open': false, 'expired_at': null})
          .eq('kelas_id', kelasId)
          .neq('id', jadwalId)
          .select();

      final now = _nowUtc();
      final expiredAt = now.add(const Duration(hours: 1)).toIso8601String();
      final nowWib = _nowWib();
      final expiredWib = nowWib.add(const Duration(hours: 1));

      // Update presensi baru
      final updated = await supabase
          .from('jadwal')
          .update({
            'is_open': true,
            'tipe_presensi': tipePresensi,

            // simpan ke DB dalam UTC
            'last_opened_at': _wibToUtc(nowWib).toIso8601String(),
            'expired_at': _wibToUtc(expiredWib).toIso8601String(),
          })
          .eq('id', jadwalId)
          .select()
          .maybeSingle();

      // Cek apakah update benar-benar terjadi
      if (updated == null) {
        print("UPDATE GAGAL — kemungkinan karena policy RLS.");
        return false;
      }

      // Insert notification
      await supabase.from('notifications').insert({
        'jadwal_id': jadwalId,
        'role': 'mhs',
        'title': 'Presensi dibuka',
        'subtitle':
            'Presensi $tipePresensi dibuka oleh dosen — akan tutup otomatis dalam 1 jam.',
        'highlight': true,
      });

      print("Presensi berhasil dibuka → $updated");
      return true;
    } catch (e) {
      print("ERROR bukaPresensi: $e");
      return false;
    }
  }

  // =====================================================
  // TUTUP PRESENSI
  // =====================================================
  Future<bool> tutupPresensi(int jadwalId) async {
    await supabase
        .from('jadwal')
        .update({'is_open': false, 'expired_at': null})
        .eq('id', jadwalId)
        .select();

    await supabase.from('notifications').insert({
      'jadwal_id': jadwalId,
      'role': 'mhs',
      'title': 'Presensi ditutup',
      'subtitle': 'Presensi telah ditutup oleh dosen.',
      'highlight': false,
    });

    return true;
  }

  // =====================================================
  // CEK STATUS PRESENSI OPEN
  // =====================================================
  Future<bool> _isPresensiOpen(int jadwalId) async {
    // Pastikan auto-close diproses dulu dengan WIB
    await _autoCloseIfExpired(jadwalId);

    // Ambil data terbaru
    final data = await supabase
        .from('jadwal')
        .select('is_open, expired_at')
        .eq('id', jadwalId)
        .maybeSingle();

    if (data == null) return false;

    final bool isOpen = data['is_open'] ?? false;
    final expiredAt = data['expired_at'];

    if (!isOpen || expiredAt == null) return false;

    // Kalau expired_at null, open
    if (expiredAt != null && isOpen) return true;

    try {
      final expiredUtc = DateTime.parse(expiredAt).toUtc();
      final expiredWib = _utcToWib(expiredUtc);

      return _nowWib().isBefore(expiredWib);
    } catch (_) {
      return true;
    }
  }

  // =====================================================
  // UPLOAD FOTO (storage API terbaru)
  // =====================================================
  Future<String> _uploadFoto(
    File foto, {
    required int mhsId,
    required int jadwalId,
  }) async {
    final ext = p.extension(foto.path).replaceFirst('.', '');
    final filename =
        'absensi/${jadwalId}_${mhsId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    final bytes = await foto.readAsBytes();

    // Upload API baru (tanpa .error)
    await supabase.storage
        .from('absensi')
        .uploadBinary(filename, bytes, fileOptions: FileOptions(upsert: true));

    // Public URL API baru
    final publicUrl = supabase.storage.from('absensi').getPublicUrl(filename);

    return publicUrl;
  }

  // =====================================================
  // PRESENSI ONLINE
  // =====================================================
  Future<bool> presensiOnline({
    required int mhsId,
    required int jadwalId,
  }) async {
    final open = await _isPresensiOpen(jadwalId);
    if (!open) throw Exception("Presensi tidak aktif atau sudah ditutup.");

    await supabase.from('absensi').insert({
      'mhs_id': mhsId,
      'jadwal_id': jadwalId,
      'tipe': 'online',
      // 'dibuat': _nowUtc().toIso8601String(),
      'status': 'hadir',
      'valid': true,
      'distance_valid': true,
    });

    return true;
  }

  // =====================================================
  // PRESENSI OFFLINE
  // =====================================================
  Future<bool> presensiOffline({
    required int mhsId,
    required int jadwalId,
    required File foto,
    required double lat,
    required double lng,
    double latDosenFromCaller = 0,
    double lngDosenFromCaller = 0,
    double radiusMeters = 50,
  }) async {
    final open = await _isPresensiOpen(jadwalId);
    if (!open) throw Exception("Presensi tidak aktif atau sudah ditutup.");

    double? latDosen;
    double? lngDosen;

    if (latDosenFromCaller != 0 && lngDosenFromCaller != 0) {
      latDosen = latDosenFromCaller;
      lngDosen = lngDosenFromCaller;
    } else {
      final q = await supabase
          .from('jadwal')
          .select(
            'dosen_id, dosen:dosen_id (id), dosen_location:dosen_id (lat, lng)',
          )
          .eq('id', jadwalId)
          .maybeSingle();

      latDosen = q?['dosen_location']?['lat'];
      lngDosen = q?['dosen_location']?['lng'];
    }

    if (latDosen == null || lngDosen == null) {
      latDosen = 0;
      lngDosen = 0;
    }

    ///
    /// HITUNG JARAK (Haversine)
    ///
    double distanceMeters = 0;

    if (latDosen != 0 && lngDosen != 0) {
      const R = 6371000.0;
      double toRad(double v) => v * pi / 180.0;

      final dLat = toRad(latDosen - lat);
      final dLng = toRad(lngDosen - lng);

      final a =
          sin(dLat / 2) * sin(dLat / 2) +
          cos(toRad(lat)) *
              cos(toRad(latDosen)) *
              sin(dLng / 2) *
              sin(dLng / 2);

      final c = 2 * atan2(sqrt(a), sqrt(1 - a));

      distanceMeters = R * c;
    } else {
      distanceMeters = double.infinity;
    }

    final distanceValid = distanceMeters <= radiusMeters;

    // Upload foto
    final fotoUrl = await _uploadFoto(foto, mhsId: mhsId, jadwalId: jadwalId);

    // Insert absensi
    await supabase.from('absensi').insert({
      'mhs_id': mhsId,
      'jadwal_id': jadwalId,
      'tipe': 'offline',
      'foto_url': fotoUrl,
      'lat': lat,
      'lng': lng,
      'dibuat': _nowUtc().toIso8601String(),
      'status': distanceValid ? 'hadir' : 'tidak hadir',
      'valid': distanceValid,
      'jarak': distanceMeters,
      'distance_valid': distanceValid,
    });

    return true;
  }

  DateTime _nowWib() => DateTime.now().toUtc().add(const Duration(hours: 7));
  DateTime _utcToWib(DateTime utc) => utc.add(const Duration(hours: 7));
  DateTime _wibToUtc(DateTime wib) => wib.subtract(const Duration(hours: 7));
}
