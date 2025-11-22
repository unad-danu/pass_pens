import 'package:flutter/material.dart';
import 'package:pass_pens/core/config/supabase_config.dart';
import 'package:pass_pens/features/auth/login/login_page.dart';

class CreateMahasiswaController {
  final BuildContext context;
  final Map<String, dynamic> biodata;
  final TextEditingController emailC;
  final TextEditingController passC;
  final TextEditingController confirmC;
  final Function(bool) onLoadingChange;

  CreateMahasiswaController({
    required this.context,
    required this.biodata,
    required this.emailC,
    required this.passC,
    required this.confirmC,
    required this.onLoadingChange,
  });

  final Map<String, String> prodiToDomain = {
    "D3 Teknik Informatika": "it",
    "D4 Teknik Informatika": "it",
    "D4 Teknik Komputer": "ce",
    "D4 Sains Data Terapan": "ds",
    "D4 Teknologi Rekayasa Multimedia": "met",
    "D4 Teknologi Rekayasa Internet": "iet",
    "D3 Multimedia Broadcasting": "mmb",
    "D4 Teknologi Game": "gt",
    "D3 Teknik Elektronika Industri": "iee",
    "D4 Teknik Elektronika Industri": "iee",
    "D3 Teknik Elektronika": "ee",
    "D4 Teknik Elektronika": "ee",
    "D4 Teknik Mekatronika": "me",
    "D4 Sistem Pembangkit Energi": "pg",
    "D3 Teknik Telekomunikasi": "te",
    "D4 Teknik Telekomunikasi": "te",
  };

  String prodiDomain(String? prodi) => prodiToDomain[prodi] ?? "";

  bool isValidEmailMahasiswa(String email) {
    final domain = prodiDomain(biodata['prodi']);
    return email.endsWith("@$domain.student.pens.ac.id");
  }

  Future<void> createAccount() async {
    final supabase = SupabaseConfig.client;

    final email = emailC.text.trim();
    final pass = passC.text.trim();
    final confirm = confirmC.text.trim();

    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field harus diisi")));
      return;
    }

    if (!isValidEmailMahasiswa(email)) {
      final domain = prodiDomain(biodata['prodi']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gunakan email: nama@$domain.student.pens.ac.id"),
        ),
      );
      return;
    }

    if (pass != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password tidak sama")));
      return;
    }

    onLoadingChange(true);

    try {
      int? prodiId = biodata['prodi_id'];

      if (prodiId == null) {
        final existing = await supabase
            .from('prodi')
            .select()
            .eq('nama', biodata['prodi'])
            .maybeSingle();

        if (existing != null) {
          prodiId = existing['id'];
        } else {
          final inserted = await supabase
              .from('prodi')
              .insert({'nama': biodata['prodi']})
              .select()
              .single();
          prodiId = inserted['id'];
        }
      }

      final user = await supabase
          .from('users')
          .insert({
            'nama': biodata['nama'],
            'email': email,
            'pass_hash': pass,
            'role': 'mhs',
            'status': 'aktif',
            'email_recovery': biodata['email_pemulihan'],
          })
          .select()
          .single();

      await supabase.from('mahasiswa').insert({
        'user_id': user['id'],
        'nrp': biodata['nrp'],
        'nama': biodata['nama'],
        'email': email,
        'phone': biodata['telepon'],
        'email_recovery': biodata['email_pemulihan'],
        'angkatan': int.parse(biodata['angkatan']),
        'prodi': biodata['prodi'],
        'prodi_id': prodiId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Akun mahasiswa berhasil dibuat!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal membuat akun: $e")));
    }

    onLoadingChange(false);
  }
}
