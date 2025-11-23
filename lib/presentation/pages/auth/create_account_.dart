import 'package:flutter/material.dart';
import '../../../core/validators.dart';
import '../../../core/helpers.dart';
import '../../../data/services/auth_services.dart';
import '../../../routes/app_routes.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool loading = false;
  final AuthService _auth = AuthService();

  Map<String, dynamic> data = {};

  @override
  void dispose() {
    emailC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      data = args;
    }
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final extraProfile = {
      "name": data["nama"],
      "role": data["role"],
      "phone": data["phone"],
      ...data, // sekarang aman karena data sudah Map<String, dynamic>
    };

    final user = await _auth.signUpWithEmail(
      email: emailC.text.trim(),
      password: passwordC.text.trim(),
      extraProfile: extraProfile,
    );

    setState(() => loading = false);

    if (user == null) {
      Helpers.showSnackBar(context, "Gagal membuat akun, coba lagi!");
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      user.role.name == "mahasiswa"
          ? AppRoutes.homeMahasiswa
          : AppRoutes.homeDosen,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Akun")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailC,
                decoration: const InputDecoration(labelText: "Email Akun"),
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordC,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Daftar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
