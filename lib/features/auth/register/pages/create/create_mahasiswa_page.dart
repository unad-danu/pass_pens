import 'package:flutter/material.dart';
import 'package:pass_pens/features/auth/login/login_page.dart';
import 'package:pass_pens/features/auth/register/controllers/create_mahasiswa_controller.dart';

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
  late final CreateMahasiswaController controller;

  @override
  void initState() {
    super.initState();
    controller = CreateMahasiswaController(
      context: context,
      biodata: widget.biodata,
      emailC: emailController,
      passC: passController,
      confirmC: confirmController,
      onLoadingChange: (v) => setState(() => isLoading = v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final domain = controller.prodiDomain(widget.biodata['prodi']);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: const Color(0xFF1B4F7D),
            child: const Column(
              children: [
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
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
                      hintText: "Enter again",
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
                      ),
                      onPressed: isLoading ? null : controller.createAccount,
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
