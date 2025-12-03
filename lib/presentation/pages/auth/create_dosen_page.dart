import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../../../core/supabase_config.dart';
import '../../widgets/custom_appbar.dart';

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
      ).showSnackBar(const SnackBar(content: Text("Password tidak sama")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final authRes = await client.auth.signUp(email: email, password: pass);

      if (authRes.user == null) {
        throw "Gagal membuat akun Auth Supabase";
      }

      final authUid = authRes.user!.id;

      final insertedUser = await client
          .from('users')
          .insert({
            'id_auth': authUid,
            'nama': widget.biodata['nama'],
            'email': email,
            'role': 'dsn',
            'status': 'aktif',
            'email_recovery': widget.biodata['email_recovery'],
          })
          .select()
          .single();

      final userId = insertedUser['id'];

      final insertedDosen = await client
          .from('dosen')
          .insert({
            'user_id': userId,
            'nip': widget.biodata['nip'],
            'nama': widget.biodata['nama'],
            'email': email,
            'phone': widget.biodata['phone'],
            'email_recovery': widget.biodata['email_recovery'],
            'status': 'active',
          })
          .select()
          .single();

      final dosenId = insertedDosen['id'];

      final rawProdi = widget.biodata['prodi'];
      final List<String> listProdi = rawProdi is List
          ? List<String>.from(rawProdi)
          : [rawProdi.toString()];

      for (final prodiName in listProdi) {
        final existingProdi = await client
            .from('prodi')
            .select()
            .eq('nama', prodiName.trim())
            .maybeSingle();

        final prodi =
            existingProdi ??
            await client
                .from('prodi')
                .insert({'nama': prodiName.trim()})
                .select()
                .single();

        await client.from('dosen_prodi').insert({
          'dosen_id': dosenId,
          'prodi_id': prodi['id'],
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Akun dosen berhasil dibuat!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
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

      appBar: const CustomAppBar(role: "guest", showBack: false),

      body: Column(
        children: [
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
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
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

                  const Text("Password"),
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

                  const Text("Konfirmasi Password"),
                  TextField(
                    controller: confirmC,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Masukkan kembali password",
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
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
