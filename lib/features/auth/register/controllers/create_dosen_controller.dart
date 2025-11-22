import 'package:flutter/material.dart';
import 'package:pass_pens/core/config/supabase_config.dart';

class CreateDosenController {
  final BuildContext context;
  final Map<String, dynamic> biodata;
  final TextEditingController emailC;
  final TextEditingController passC;
  final TextEditingController confirmC;
  final Function(bool) onLoadingChange;

  CreateDosenController({
    required this.context,
    required this.biodata,
    required this.emailC,
    required this.passC,
    required this.confirmC,
    required this.onLoadingChange,
  });

  bool isValidEmailDosen(String email) {
    return email.endsWith("@lecturer.pens.ac.id");
  }

  Future<void> createAccount() async {
    final client = SupabaseConfig.client;

    final email = emailC.text.trim();
    final pass = passC.text.trim();
    final confirm = confirmC.text.trim();

    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field harus diisi")));
      return;
    }

    if (!isValidEmailDosen(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gunakan email: nama@lecturer.pens.ac.id"),
        ),
      );
      return;
    }

    if (pass != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Kata sandi tidak sama")));
      return;
    }

    onLoadingChange(true);

    try {
      final user = await client
          .from('users')
          .insert({
            'nama': biodata['nama'],
            'email': email,
            'pass_hash': pass,
            'role': 'dsn',
          })
          .select()
          .maybeSingle();

      if (user == null) throw "Insert user gagal";

      final userId = user['id'];

      final dosen = await client
          .from('dosen')
          .insert({
            'user_id': userId,
            'nip': biodata['nip'],
            'status': 'active',
            'email_recovery': biodata['email_recovery'],
            'phone': biodata['phone'],
            'nama': biodata['nama'],
          })
          .select()
          .maybeSingle();

      if (dosen == null) throw "Insert dosen gagal";

      final dosenId = dosen['id'];

      final List<String> listProdi = List<String>.from(biodata['prodi']);

      for (final prodiName in listProdi) {
        var prodi = await client
            .from('prodi')
            .select()
            .eq('nama', prodiName)
            .maybeSingle();

        prodi ??= await client
            .from('prodi')
            .insert({'nama': prodiName})
            .select()
            .single();

        await client.from('dosen_prodi').insert({
          'dosen_id': dosenId,
          'prodi_id': prodi['id'],
        });
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Akun dosen berhasil dibuat!")),
      );

      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      onLoadingChange(false);
    }
  }
}
