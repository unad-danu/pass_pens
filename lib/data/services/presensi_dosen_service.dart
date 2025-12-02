import 'package:supabase_flutter/supabase_flutter.dart';

class PresensiDosenService {
  final supabase = Supabase.instance.client;

  /// Buka presensi untuk jadwal tertentu
  Future<bool> bukaPresensi(int jadwalId) async {
    try {
      final res = await supabase
          .from('jadwal')
          .update({
            'is_open': true,
            'dibuka_pada': DateTime.now().toIso8601String(),
          })
          .eq('id', jadwalId);

      return true;
    } catch (e) {
      print('Error buka presensi: $e');
      return false;
    }
  }

  /// Tutup presensi
  Future<bool> tutupPresensi(int jadwalId) async {
    try {
      await supabase
          .from('jadwal')
          .update({'is_open': false})
          .eq('id', jadwalId);

      return true;
    } catch (e) {
      print('Error tutup presensi: $e');
      return false;
    }
  }

  /// Cek status presensi
  Future<bool> getStatusPresensi(int jadwalId) async {
    final res = await supabase
        .from('jadwal')
        .select('is_open')
        .eq('id', jadwalId)
        .single();

    return res['is_open'] == true;
  }
}
