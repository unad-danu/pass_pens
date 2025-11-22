import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../login_controller.dart';
import '../../register/pages/register_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LoginController>(context);

    return Column(
      children: [
        // HEADER
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
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "users@prodi(student).student/lecture.pens.ac.id",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text("Password"),
              const SizedBox(height: 5),
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

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final pass = passwordController.text.trim();

                    if (!controller.isValidEmail(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Email harus format PENS:\nnama@prodi.student/lecture.pens.ac.id",
                          ),
                        ),
                      );
                      return;
                    }

                    final success = await controller.login(email, pass);

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Login Berhasil!")),
                      );
                      // TODO: Navigate to home
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Email atau password salah"),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Center(
                child: Column(
                  children: [
                    const Text("Masih belum punya akun?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
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
      ],
    );
  }
}
