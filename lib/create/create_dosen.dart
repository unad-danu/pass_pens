import 'package:flutter/material.dart';
import '../utils/supabase_config.dart';

class CreateDosenPage extends StatefulWidget {
  final Map<String, dynamic> biodata;

  const CreateDosenPage({super.key, required this.biodata});

  @override
  State<CreateDosenPage> createState() => _CreateDosenPageState();
}

class _CreateDosenPageState extends State<CreateDosenPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();

  bool isLoading = false;

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

    setState(() => isLoading = true);

    try {
      // ----------------------------------------------------------
      // 1. Insert ke tabel users
      // ----------------------------------------------------------
      final user = await client
          .from('users')
          .insert({
            'nama': widget.biodata['nama'],
            'email': email,
            'pass_hash': pass,
            'role': 'dsn',
          })
          .select()
          .maybeSingle();

      if (user == null) throw "Insert user gagal";

      final userId = user['id'];

      // ----------------------------------------------------------
      // 2. Insert ke tabel dosen (sekaligus simpan nama dosen)
      // ----------------------------------------------------------
      final dosen = await client
          .from('dosen')
          .insert({
            'user_id': userId,
            'nip': widget.biodata['nip'],
            'status': 'active',
            'email_recovery': widget.biodata['email_recovery'],
            'phone': widget.biodata['phone'],
            'nama': widget.biodata['nama'], // ← tambahan sesuai permintaan
          })
          .select()
          .maybeSingle();

      if (dosen == null) throw "Insert dosen gagal";

      final dosenId = dosen['id'];

      // ----------------------------------------------------------
      // 3. Insert ke dosen_prodi (buat prodi jika belum ada)
      // ----------------------------------------------------------
      final List<String> listProdi = List<String>.from(widget.biodata['prodi']);

      for (final prodiName in listProdi) {
        // 3a. Cek apakah prodi sudah ada
        var prodi = await client
            .from('prodi')
            .select()
            .eq('nama', prodiName)
            .maybeSingle();

        // 3b. Jika tidak ada → buat baru
        if (prodi == null) {
          prodi = await client
              .from('prodi')
              .insert({'nama': prodiName})
              .select()
              .single();
        }

        // 3c. Insert relasi dosen-prodi
        await client.from('dosen_prodi').insert({
          'dosen_id': dosenId,
          'prodi_id': prodi['id'],
        });
      }

      if (!mounted) return;

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
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25),
            width: double.infinity,
            color: const Color(0xFF0D4C73),
            child: const Column(
              children: [
                Text(
                  "PASS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "PENS Attendance Smart System",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Enter Account Name And Password",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text("Email PENS"),
                  TextField(
                    controller: emailC,
                    decoration: InputDecoration(
                      hintText: "nama@lecturer.pens.ac.id",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  const Text("Kata Sandi"),
                  TextField(
                    controller: passC,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Minimal 8 karakter",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  const Text("Konfirmasi Kata Sandi"),
                  TextField(
                    controller: confirmC,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Masukkan kembali kata sandi",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: isLoading ? null : createAccount,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "CREATE",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        color: const Color(0xFF0D4C73),
        child: const Text(
          "Electronic Engineering\nPolytechnic Institute of Surabaya",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}
