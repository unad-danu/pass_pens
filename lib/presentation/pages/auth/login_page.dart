import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/register_page.dart';
import '../../widgets/main_navigation.dart';
import '../../widgets/custom_appbar.dart';
import '../admin/admin_dashboard_page.dart';

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

  // ===================== LOGIN SUPABASE (VERSI PERMINTAANMU) =====================
  Future<void> login() async {
    String email = emailController.text.trim().toLowerCase();
    final String pass = passController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      showAlert("Data tidak lengkap", "Email dan password harus diisi.");
      return;
    }

    // Ambil prefix sebelum @
    final prefix = email.split('@')[0];

    // ========= AUTO DOMAIN MAHASISWA =========
    // Jika user hanya input "ce12345" tanpa domain
    final mahasiswaPrefixes = [
      "ce",
      "it",
      "elka",
      "telkom",
      "jkt",
      "mj",
      "jt",
      "te",
      "ti",
    ];

    // Jika tidak ada '@'
    if (!email.contains("@")) {
      // Jika mahasiswa (prefix mulai dari singkatan prodi)
      if (mahasiswaPrefixes.any((p) => prefix.startsWith(p))) {
        email = "$prefix@$prefix.student.pens.ac.id";
      }
      // Jika dosen
      else {
        email = "$email@lecturer.pens.ac.id";
      }
    }

    setState(() => loading = true);

    try {
      // LOGIN Supabase
      final auth = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: pass,
      );

      final user = auth.user;
      if (user == null) throw Exception("Login gagal!");

      // AMBIL ROLE DARI TABEL USERS
      final data = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id_auth', user.id)
          .maybeSingle();

      if (data == null) throw Exception("Role user tidak ditemukan!");

      final role = data['role'];

      // MASUK KE MAIN NAVIGATION / ADMIN
      if (role == "adm") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
        );
      } else if (role == "mhs" || role == "mahasiswa") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigation(role: "mahasiswa"),
          ),
        );
      } else if (role == "dsn" || role == "dosen") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigation(role: "dosen"),
          ),
        );
      } else {
        showAlert("Error", "Role tidak dikenali: $role");
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
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(),

      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                    const SizedBox(height: 20),

                    Container(
                      height: 150,
                      width: 150,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      clipBehavior: Clip.hardEdge,
                      child: Image.asset(
                        'assets/icon_login.png',
                        fit: BoxFit.cover,
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
                        hintText: "Your PENS email address",
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

            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              width: double.infinity,
              color: const Color(0xFF0B5E86),
              child: const Text(
                "Electronic Engineering\nPolytechnic Institute of Surabaya",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
