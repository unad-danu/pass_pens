import 'package:flutter/material.dart';

// ---------------------- AUTH ----------------------
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/auth/register_mahasiswa_page.dart';
import '../presentation/pages/auth/register_dosen_page.dart';
import '../presentation/pages/auth/create_dosen_page.dart';
import '../presentation/pages/auth/create_mahasiswa_page.dart';

// ---------------------- HOME ----------------------
import '../presentation/pages/home_mahasiswa_page.dart';
import '../presentation/pages/home_dosen_page.dart';

// ---------------------- MENU ----------------------
import '../presentation/pages/profile_page.dart';
import '../presentation/pages/notification_page.dart';

// ---------------------- REKAP ----------------------
import '../presentation/pages/rekap_matkul_mahasiswa_page.dart';
import '../presentation/pages/rekap_matkul_dosen_page.dart';

// ---------------------- ADMIN ----------------------
import '../presentation/pages/admin/admin_dashboard_page.dart';
import '../presentation/pages/admin/admin_kelola_matkul_page.dart';
import '../presentation/pages/admin/admin_kelola_dosen_page.dart';
import '../presentation/pages/admin/admin_kelola_jadwal_page.dart';
import '../presentation/pages/admin/admin_kelola_kelas_page.dart';
import '../presentation/pages/admin/admin_kelola_ruangan_page.dart';
import '../presentation/pages/admin/admin_assign_matkul_page.dart';

class AppRoutes {
  // =====================================================
  //                      AUTH
  // =====================================================
  static const String login = '/login';
  static const String register = '/register';
  static const String registerMahasiswa = '/register-mahasiswa';
  static const String registerDosen = '/register-dosen';
  static const String createMahasiswa = '/create-mahasiswa';
  static const String createDosen = '/create-dosen';

  // =====================================================
  //                      HOME
  // =====================================================
  static const String homeMahasiswa = '/home-mahasiswa';
  static const String homeDosen = '/home-dosen';

  // =====================================================
  //                      MENU
  // =====================================================
  static const String profile = '/profile';
  static const String notification = '/notification';
  static const String rekapDosen = '/rekap-dosen';
  static const String rekapMahasiswa = '/rekap-mahasiswa';

  // =====================================================
  //                      ADMIN
  // =====================================================
  static const String adminDashboard = '/admin/dashboard';
  static const String adminKelolaMatkul = '/admin/kelola-matkul';
  static const String adminKelolaDosen = '/admin/kelola-dosen';
  static const String adminKelolaJadwal = '/admin/kelola-jadwal';
  static const String adminKelolaKelas = '/admin/kelola-kelas';
  static const String adminKelolaRuang = '/admin/kelola-ruang';

  // Assign Matkul
  static const String adminAssignMatkul = '/admin/assign-matkul';

  // =====================================================
  //                   STATIC ROUTES
  // =====================================================
  static Map<String, WidgetBuilder> routes = {
    // AUTH
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    registerMahasiswa: (_) => const RegisterMahasiswa(),
    registerDosen: (_) => const RegisterDosenPage(),

    // HOME
    homeMahasiswa: (_) => const HomeMahasiswa(),
    homeDosen: (_) => const HomeDosenPage(),

    // MENU
    rekapDosen: (_) => const RekapMatkulDosenPage(),
    // rekapMahasiswa: (_) => const RekapMatkulMahasiswaPage(),

    // ADMIN
    adminDashboard: (_) => const AdminDashboardPage(),
    adminKelolaMatkul: (_) => const AdminKelolaMatkulPage(),
    adminKelolaDosen: (_) => const AdminKelolaDosenPage(),
    adminKelolaJadwal: (_) => const AdminKelolaJadwalPage(),
    adminKelolaKelas: (_) => const AdminKelolaKelasPage(),
    adminKelolaRuang: (_) => const AdminKelolaRuanganPage(),

    // ASSIGN
    adminAssignMatkul: (_) => const AdminAssignMatkulPage(),
  };

  // =====================================================
  //              ROUTES WITH PARAMETERS (SAFE)
  // =====================================================
  static Route<dynamic>? onGenerate(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // PROFILE (FIXED)
      case profile:
        return MaterialPageRoute(
          builder: (_) => ProfilePage(
            role: (args is String) ? args : "", // default non-null
          ),
        );

      // NOTIFICATION (FIXED)
      case notification:
        return MaterialPageRoute(
          builder: (_) => NotificationPage(
            role: (args is String) ? args : "", // default non-null
          ),
        );

      // CREATE MAHASISWA
      case createMahasiswa:
        return MaterialPageRoute(
          builder: (_) => CreateMahasiswaPage(
            biodata: (args is Map<String, dynamic>) ? args : {},
          ),
        );

      // CREATE DOSEN
      case createDosen:
        return MaterialPageRoute(
          builder: (_) => CreateDosenPage(
            biodata: (args is Map<String, dynamic>) ? args : {},
          ),
        );
    }

    return null;
  }

  // =====================================================
  //                     ERROR PAGE
  // =====================================================
  static Route<dynamic> _error(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Route Error")),
        body: Center(
          child: Text(
            message,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
