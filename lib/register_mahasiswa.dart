import 'package:flutter/material.dart';
import 'create_mahasiswa.dart';

class RegisterMahasiswa extends StatefulWidget {
  const RegisterMahasiswa({super.key});

  @override
  State<RegisterMahasiswa> createState() => _RegisterMahasiswaState();
}

class _RegisterMahasiswaState extends State<RegisterMahasiswa> {
  String? selectedProdi;
  String? selectedAngkatan;

  // Controller biodata
  final namaC = TextEditingController();
  final nrpC = TextEditingController();
  final telpC = TextEditingController();
  final recoveryC = TextEditingController();

  final List<String> listProdi = [
    "D3 Teknik Informatika",
    "D4 Teknik Informatika",
    "D4 Teknik Komputer",
    "D4 Sains Data Terapan",
    "D4 Teknologi Rekayasa Multimedia",
    "D4 Teknologi Rekayasa Internet",
    "D3 Multimedia Broadcasting",
    "D4 Teknologi Game",
    "D3 Teknik Elektronika Industri",
    "D4 Teknik Elektronika Industri",
    "D3 Teknik Elektronika",
    "D4 Teknik Elektronika",
    "D4 Teknik Mekatronika",
    "D4 Sistem Pembangkit Energi",
    "D3 Teknik Telekomunikasi",
    "D4 Teknik Telekomunikasi",
  ];

  // Generate list angkatan otomatis
  final List<String> listAngkatan = List.generate(
    8,
    (index) => (DateTime.now().year - index).toString(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: Column(
        children: [
          // ================= HEADER =================
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

          // ================ FORM ================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BACK + TITLE
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Enter Your Biodata",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  const Text("Nama Lengkap"),
                  TextField(
                    controller: namaC,
                    decoration: InputDecoration(
                      hintText: "nama lengkap",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  const Text("NRP"),
                  TextField(
                    controller: nrpC,
                    decoration: InputDecoration(
                      hintText: "Contoh : 3224600013",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  const Text("Prodi"),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: "Pilih prodi",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: selectedProdi,
                    items: listProdi
                        .map(
                          (prodi) => DropdownMenuItem(
                            value: prodi,
                            child: Text(prodi),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProdi = value;
                      });
                    },
                  ),
                  const SizedBox(height: 15),

                  const Text("Angkatan"),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: "Pilih angkatan",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: selectedAngkatan,
                    items: listAngkatan
                        .map(
                          (tahun) => DropdownMenuItem(
                            value: tahun,
                            child: Text(tahun),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedAngkatan = value;
                      });
                    },
                  ),
                  const SizedBox(height: 15),

                  const Text("Nomor Telepon"),
                  TextField(
                    controller: telpC,
                    decoration: InputDecoration(
                      hintText: "08XXXXXXX",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  const Text("E-mail Pemulihan"),
                  TextField(
                    controller: recoveryC,
                    decoration: InputDecoration(
                      hintText: "nama@gmail.com",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ================ BUTTON CONTINUE ================
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () {
                        if (namaC.text.isEmpty ||
                            nrpC.text.isEmpty ||
                            selectedProdi == null ||
                            selectedAngkatan == null ||
                            telpC.text.isEmpty ||
                            recoveryC.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Semua field biodata harus diisi"),
                            ),
                          );
                          return;
                        }

                        // ========== DATA DIKIRIM KE CreateMahasiswaPage ==========
                        final biodataMahasiswa = {
                          "nama": namaC.text.trim(),
                          "nrp": nrpC.text.trim(),
                          "prodi": selectedProdi,
                          "angkatan": selectedAngkatan,
                          "telepon": telpC.text.trim(),
                          "email_pemulihan": recoveryC.text.trim(),
                        };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CreateMahasiswaPage(biodata: biodataMahasiswa),
                          ),
                        );
                      },
                      child: const Text(
                        "Continue",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "By clicking continue, you agree to our Terms of Service and Privacy Policy",
                    style: TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ================= FOOTER =================
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
