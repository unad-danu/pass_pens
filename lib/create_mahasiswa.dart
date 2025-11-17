import 'package:flutter/material.dart';
import 'package:pass_pens/login.dart';

// Halaman pilih prodi
class PilihProdiPage extends StatefulWidget {
  const PilihProdiPage({super.key});

  @override
  State<PilihProdiPage> createState() => _PilihProdiPageState();
}

class _PilihProdiPageState extends State<PilihProdiPage> {
  String? selectedProdi;

  // Nama lengkap -> singkatan prodi
  final Map<String, String> prodiDomain = {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Prodi")),
      body: Center(
        child: DropdownButton<String>(
          hint: const Text("Pilih Prodi"),
          value: selectedProdi,
          items: prodiDomain.keys.map((prodi) {
            return DropdownMenuItem<String>(value: prodi, child: Text(prodi));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedProdi = value);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CreateMahasiswaPage(biodata: {"prodi": value}),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

// Halaman create mahasiswa
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

  // Map nama lengkap -> singkatan
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

  void createAccount() {
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
            "Email mahasiswa tidak valid.\nGunakan email: nama@$domain.student.pens.ac.id",
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

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Akun mahasiswa berhasil dibuat!")),
      );

      // Langsung ke login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false, // hapus semua route sebelumnya
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final domain = prodiToDomain[widget.biodata['prodi']] ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: const Color(0xFF1B4F7D),
            child: Column(
              children: const [
                Text(
                  "PASS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
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

          // ================= FORM =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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

      // Footer tetap di bawah, tidak ikut naik saat keyboard muncul
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        color: const Color(0xFF1B4F7D),
        child: const Text(
          "Electronic Engineering\nPolytechnic Institute of Surabaya",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}
