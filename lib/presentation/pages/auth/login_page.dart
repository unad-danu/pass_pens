import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/register_page.dart';

// Pakai prefix agar tidak tabrakan
import '../home_mahasiswa_page.dart' as mhs;
import '../home_dosen_page.dart' as dsn;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool _obscurePass = true;
  bool loading = false;

  // ===================== POPUP ALERT =====================
  void showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ===================== LOGIN SUPABASE =====================
  Future<void> login() async {
    final email = emailController.text.trim().toLowerCase();
    final pass = passController.text.trim();

    // Validasi format email PENS
    final RegExp pensRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z]+\.student\.pens\.ac\.id$',
    );

    if (!pensRegex.hasMatch(email)) {
      showAlert(
        "Email Tidak Valid",
        "Format email harus: nama@jurusan.student.pens.ac.id",
      );
      return;
    }
    if (pass.isEmpty) {
      showAlert("Password Kosong", "Silakan isi password Anda.");
      return;
    }

    setState(() => loading = true);

    try {
      // Login Supabase
      final auth = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: pass,
      );

      final user = auth.user;
      if (user == null) throw Exception("Login gagal!");

      // Ambil role user dari tabel profiles
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('email', email)
          .maybeSingle();

      if (profile == null) throw Exception("Role tidak ditemukan!");

      final String role = profile['role'];

      // Arahkan sesuai role
      if (role == "dosen") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const dsn.HomeDosenPage()),
        );
      } else if (role == "mahasiswa") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const mhs.HomeMahasiswa()),
        );
      } else {
        throw Exception("Role tidak valid!");
      }
    } catch (e) {
      showAlert("Login Gagal", e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  bool get canLogin =>
      emailController.text.trim().isNotEmpty &&
      passController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() {}));
    passController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // ============ HEADER ============ //
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: const Color(0xFF0B5E86),
              child: Column(
                children: const [
                  Text(
                    "PASS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "PENS Attendance Smart System",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            // ============ BODY ============ //
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Icon circle
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      "Enter Your PENS Email and Password",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "PENS Email",
                        hintText: "nama@jurusan.student.pens.ac.id",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextField(
                      controller: passController,
                      obscureText: _obscurePass,
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "••••••••••",
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canLogin
                              ? Colors.black
                              : Colors.grey,
                        ),
                        onPressed: loading || !canLogin ? null : login,
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "LOGIN",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Column(
                      children: [
                        const Text(
                          "Masih belum punya akun?",
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          ),
                          child: const Text(
                            "Daftar akun disini",
                            style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ============ FOOTER ============ //
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              color: const Color(0xFF0B5E86),
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
