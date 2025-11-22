import 'package:flutter/material.dart';
import 'package:pass_pens/features/auth/register/widgets/form_mahasiswa.dart';

class RegisterMahasiswaPage extends StatelessWidget {
  const RegisterMahasiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.white, body: FormMahasiswa());
  }
}
