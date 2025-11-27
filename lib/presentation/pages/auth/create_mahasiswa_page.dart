import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_config.dart';
import 'login_page.dart';
import '../../widgets/custom_appbar.dart';

class CreateMahasiswaPage extends StatefulWidget {
  final Map<String, dynamic> biodata;

  const CreateMahasiswaPage({super.key, required this.biodata});

  @override
  State<CreateMahasiswaPage> createState() => _CreateMahasiswaPageState();
}

class _CreateMahasiswaPageState extends State<CreateMahasiswaPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmController = TextEditingController();
  bool isLoading = false;

  final supabase = SupabaseConfig.client;

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

  bool isValidMahasiswaEmail(String email) {
    final domain = prodiToDomain[widget.biodata['prodi']] ?? "";
    return email.endsWith("@$domain.student.pens.ac.id");
  }

  Future<void> createAccount() async {
    final email = emailController.text.trim();
    final pass = passController.text.trim();
    final confirm = confirmController.text.trim();

    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field harus diisi")));
      return;
    }

    if (!isValidMahasiswaEmail(email)) {
      final domain = prodiToDomain[widget.biodata['prodi']] ?? "";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Email tidak valid.\nGunakan: nama@$domain.student.pens.ac.id",
          ),
        ),
      );
      return;
    }

    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password dan konfirmasi tidak sama")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. SIGN UP AUTH (DAPAT UUID)
      final authRes = await supabase.auth.signUp(email: email, password: pass);

      if (authRes.user == null) {
        throw "Gagal membuat akun Supabase Auth";
      }

      final String authUid = authRes.user!.id; // UUID

      // 2. INSERT KE TABEL USERS (ID AUTO INCREMENT)
      final insertedUser = await supabase
          .from('users')
          .insert({
            'id_auth': authUid,
            'nama': widget.biodata['nama'],
            'email': email,
            'role': 'mhs',
            'status': 'aktif',
            'email_recovery': widget.biodata['email_recovery'],
          })
          .select()
          .single();

      final int userId = insertedUser['id']; // INTEGER!!

      // 3. GET / INSERT PRODI
      final prodiName = widget.biodata['prodi'];
      int? prodiId = widget.biodata['prodi_id'];

      if (prodiId == null) {
        final check = await supabase
            .from('prodi')
            .select()
            .eq('nama', prodiName)
            .maybeSingle();

        if (check != null) {
          prodiId = check['id'];
        } else {
          final inserted = await supabase
              .from('prodi')
              .insert({'nama': prodiName})
              .select()
              .single();
          prodiId = inserted['id'];
        }
      }

      // 4. INSERT KE MAHASISWA (PAKAI userId INTEGER)
      await supabase.from('mahasiswa').insert({
        'user_id': userId,
        'nrp': widget.biodata['nrp'],
        'nama': widget.biodata['nama'],
        'email': email,
        'phone': widget.biodata['phone'],
        'email_recovery': widget.biodata['email_recovery'],
        'angkatan': int.parse(widget.biodata['angkatan']),
        'prodi': prodiName,
        'prodi_id': prodiId,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Akun berhasil dibuat!")));

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

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final domain = prodiToDomain[widget.biodata['prodi']] ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,

      // ==========================
      //     CUSTOM APP BAR
      // ==========================
      appBar: const CustomAppBar(role: "mhs"),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==========================
                  //      TOMBOL BACK DI BODY
                  // ==========================
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "PENS Email",
                      hintText: "name@$domain.student.pens.ac.id",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Enter Your Password",
                      hintText: "minimum 8 characters",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm Your Password",
                      hintText: "Enter Your Password Again",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: isLoading ? null : createAccount,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("CREATE"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        width: double.infinity,
        color: const Color(0xFF1B4F7D),
        child: const Text(
          "Electronic Engineering\nPolytechnic Institute of Surabaya",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
