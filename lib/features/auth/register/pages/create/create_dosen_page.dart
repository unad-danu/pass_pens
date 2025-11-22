import 'package:flutter/material.dart';
import 'package:pass_pens/features/auth/register/controllers/create_dosen_controller.dart';

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

  late final CreateDosenController controller;

  @override
  void initState() {
    super.initState();
    controller = CreateDosenController(
      context: context,
      biodata: widget.biodata,
      emailC: emailC,
      passC: passC,
      confirmC: confirmC,
      onLoadingChange: (value) => setState(() => isLoading = value),
    );
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
                      onPressed: isLoading ? null : controller.createAccount,
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
