import 'package:flutter/material.dart';

class CreateMahasiswaPage extends StatefulWidget {
  final Map<String, dynamic> biodata;

  const CreateMahasiswaPage({super.key, required this.biodata});

  @override
  State<CreateMahasiswaPage> createState() => _CreateMahasiswaPageState();
}

class _CreateMahasiswaPageState extends State<CreateMahasiswaPage> {
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final confirmC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Header
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
                  // Back + Title
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Email
                  const Text("E-mail"),
                  TextField(
                    controller: emailC,
                    decoration: InputDecoration(
                      hintText: "example@gmail.com",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password
                  const Text("Password"),
                  TextField(
                    controller: passwordC,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Minimal 8 karakter",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Confirm
                  const Text("Confirm Password"),
                  TextField(
                    controller: confirmC,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Ulangi password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () {
                        if (emailC.text.isEmpty ||
                            passwordC.text.isEmpty ||
                            confirmC.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Semua field harus diisi"),
                            ),
                          );
                          return;
                        }

                        if (passwordC.text != confirmC.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password tidak sama"),
                            ),
                          );
                          return;
                        }

                        final dataAkhir = {
                          ...widget
                              .biodata, // <-- ambil biodata dari halaman sebelumnya
                          "email": emailC.text,
                          "password": passwordC.text,
                        };

                        // Sementara arahkan kembali
                        Navigator.pop(context, dataAkhir);
                      },
                      child: const Text(
                        "Complete Registration",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Footer
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
