import 'package:flutter/material.dart';
import '../create/create_dosen.dart';

class RegisterDosen extends StatefulWidget {
  const RegisterDosen({super.key});

  @override
  State<RegisterDosen> createState() => _RegisterDosenState();
}

class _RegisterDosenState extends State<RegisterDosen> {
  final namaC = TextEditingController();
  final nipC = TextEditingController();
  final phoneC = TextEditingController();
  final emailRecoveryC = TextEditingController();

  TextEditingController prodiController = TextEditingController();
  Set<String> selectedProdi = {};

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // HEADER
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

          // FORM (scrollable)
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
                      const Text(
                        "Enter Your Biodata",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Nama
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

                  // NIP
                  const Text("NIP"),
                  TextField(
                    controller: nipC,
                    decoration: InputDecoration(
                      hintText: "Contoh : 123456",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Prodi multi-select
                  const Text("Prodi yang Diajar"),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setSheetState) {
                              return Container(
                                padding: const EdgeInsets.all(15),
                                height:
                                    MediaQuery.of(context).size.height * 0.75,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Pilih Prodi",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    Expanded(
                                      child: ListView(
                                        children: listProdi.map((prodi) {
                                          return CheckboxListTile(
                                            title: Text(prodi),
                                            value: selectedProdi.contains(
                                              prodi,
                                            ),
                                            onChanged: (checked) {
                                              setSheetState(() {});
                                              setState(() {
                                                if (checked == true) {
                                                  selectedProdi.add(prodi);
                                                } else {
                                                  selectedProdi.remove(prodi);
                                                }
                                                prodiController.text =
                                                    selectedProdi.join(", ");
                                              });
                                            },
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                          );
                                        }).toList(),
                                      ),
                                    ),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Selesai"),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: prodiController,
                        decoration: InputDecoration(
                          hintText: "Pilih prodi",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Phone
                  const Text("Nomor Telepon"),
                  TextField(
                    controller: phoneC,
                    decoration: InputDecoration(
                      hintText: "08XXXXXX",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Email Recovery
                  const Text("E-mail Pemulihan"),
                  TextField(
                    controller: emailRecoveryC,
                    decoration: InputDecoration(
                      hintText: "nama@gmail.com",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () {
                        if (selectedProdi.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Silahkan pilih prodi terlebih dahulu",
                              ),
                            ),
                          );
                          return;
                        }

                        if (namaC.text.isEmpty ||
                            nipC.text.isEmpty ||
                            phoneC.text.isEmpty ||
                            emailRecoveryC.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Semua field harus diisi"),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateDosenPage(
                              biodata: {
                                "nama": namaC.text.trim(),
                                "nip": nipC.text.trim(),
                                "phone": phoneC.text.trim(),
                                "email_recovery": emailRecoveryC.text.trim(),
                                "prodi": selectedProdi.toList(),
                              },
                            ),
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

      // FOOTER
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        width: double.infinity,
        color: const Color(0xFF0D4C73),
        child: const Text(
          "Electronic Engineering\nPolytechnic Institute of Surabaya",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
