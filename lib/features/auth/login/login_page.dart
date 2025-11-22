import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_controller.dart';
import 'widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: const Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(child: LoginForm()),
      ),
    );
  }
}
