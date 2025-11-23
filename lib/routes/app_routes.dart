import 'package:flutter/material.dart';

// AUTH
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/auth/register_mahasiswa_page.dart';
import '../presentation/pages/auth/register_dosen_page.dart';
import '../presentation/pages/auth/create_dosen_page.dart';
import '../presentation/pages/auth/create_mahasiswa_page.dart';

// HOME
import '../presentation/pages/home_mahasiswa_page.dart';
import '../presentation/pages/home_dosen_page.dart';

// MENU & OTHER
import '../presentation/pages/profile_page.dart';
import '../presentation/pages/notification_page.dart';

class AppRoutes {
  // AUTH
  static const String login = '/login';
  static const String register = '/register';
  static const String registerMahasiswa = '/register-mahasiswa';
  static const String registerDosen = '/register-dosen';
  static const String createMahasiswa = '/create-mahasiswa';
  static const String createDosen = '/create-dosen';

  // HOME
  static const String homeMahasiswa = '/home-mahasiswa';
  static const String homeDosen = '/home-dosen';

  // MENU & OTHER
  static const String profile = '/profile';
  static const String notification = '/notification';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    registerMahasiswa: (_) => const RegisterMahasiswa(),
    registerDosen: (_) => const RegisterDosenPage(),
    homeMahasiswa: (_) => const HomeMahasiswa(),
    homeDosen: (_) => const HomeDosenPage(),
    profile: (_) => const ProfilePage(),
    notification: (_) => const NotificationPage(),

    // Dummy untuk route berbasis onGenerate
    createMahasiswa: (_) => const SizedBox(),
    createDosen: (_) => const SizedBox(),
  };

  static Route<dynamic>? onGenerate(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case createMahasiswa:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => CreateMahasiswaPage(biodata: args),
          );
        }
        return _errorRoute("Parameter createMahasiswa tidak valid");

      case createDosen:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => CreateDosenPage(biodata: args),
          );
        }
        return _errorRoute("Parameter createDosen tidak valid");
    }

    return null;
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Route Error")),
        body: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
