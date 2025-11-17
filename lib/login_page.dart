import 'package:flutter/material.dart';
import 'utils/supabase_config.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ==========================
  // VALIDASI EMAIL PENS
  // ==========================
  bool isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z]+\.((student)|(lecture))\.pens\.ac\.id$',
    );
    return regex.hasMatch(email);
  }

  // ==========================
  // LOGIN KE SUPABASE
  // ==========================
  Future<void> login() async {
    final client = SupabaseConfig.client;

    String email = emailController.text.trim();
    String pass = passwordController.text.trim();

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Email harus format PENS:\nnama@prodi.student/lecture.pens.ac.id",
          ),
        ),
      );
      return;
    }

    try {
      // CEK USER
      final data = await client
          .from("users")
          .select()
          .eq("email", email)
          .eq("pass_hash", pass)
          .maybeSingle();

      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email atau password salah")),
        );
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Berhasil!")));

      // TODO: Pindah ke dashboard nanti
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER BIRU
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25),
              width: double.infinity,
              color: const Color(0xFF0D4C73),
              child: Column(
                children: const [
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

            const SizedBox(height: 30),

            // ICON LOGIN
            Image.asset("assets/icon_login.png", width: 200, height: 200),

            const SizedBox(height: 20),

            const Text(
              "Enter Your PENS Email and Password",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("PENS Email"),
                  const SizedBox(height: 5),

                  // EMAIL FIELD
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText:
                          "users@prodi(student).student/lecture.pens.ac.id",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text("Password"),
                  const SizedBox(height: 5),

                  // PASSWORD FIELD
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "***",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: login,
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // LINK REGISTER
                  Center(
                    child: Column(
                      children: [
                        const Text("Masih belum punya akun?"),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Daftar akun disini",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // FOOTER
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,
              color: const Color(0xFF0D4C73),
              child: const Text(
                "Electronic Engineering\nPolytechnic Institute of Surabaya",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
