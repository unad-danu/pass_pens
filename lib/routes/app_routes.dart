import 'package:flutter/material.dart';

// AUTH
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/auth/register_mahasiswa_page.dart';
import '../presentation/pages/auth/register_dosen_page.dart';

// HOME
import '../presentation/pages/home_mahasiswa_page.dart';
import '../presentation/pages/home_dosen_page.dart';

// MENU & OTHER
import '../presentation/pages/profile_page.dart';
import '../presentation/pages/notification_page.dart';

// MATKUL & PRESENSI
import '../presentation/pages/detail_matkul_mahasiswa_page.dart';
import '../presentation/pages/detail_matkul_dosen_page.dart';
import '../presentation/pages/presensi_mahasiswa_page.dart';
import '../presentation/pages/presensi_dosen_page.dart';
import '../presentation/pages/rekap_matkul_mahasiswa_page.dart';
import '../presentation/pages/rekap_matkul_dosen_page.dart';

class AppRoutes {
  // AUTH
  static const String login = '/login';
  static const String register = '/register';
  static const String registerMahasiswa = '/register-mahasiswa';
  static const String registerDosen = '/register-dosen';

  // HOME
  static const String homeMahasiswa = '/home-mahasiswa';
  static const String homeDosen = '/home-dosen';

  // PROFILE & NOTIF
  static const String profile = '/profile';
  static const String notification = '/notification';

  // MATKUL & PRESENSI
  static const String detailMatkulMahasiswa = '/detail-matkul-mhs';
  static const String detailMatkulDosen = '/detail-matkul-dsn';
  static const String presensiMahasiswa = '/presensi-mahasiswa';
  static const String presensiDosen = '/presensi-dosen';
  static const String rekapMhs = '/rekap-mhs';
  static const String rekapDosen = '/rekap-dosen';

  static Map<String, WidgetBuilder> routes = {
    // AUTH
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    registerMahasiswa: (_) => const RegisterMahasiswaPage(),
    registerDosen: (_) => const RegisterDosenPage(),

    // HOME
    homeMahasiswa: (_) => const HomeMahasiswaPage(),
    homeDosen: (_) => const HomeDosenPage(),

    // PROFILE & NOTIF
    profile: (_) => const ProfilePage(),
    notification: (_) => const NotificationPage(),

    // PRESENSI
    presensiMahasiswa: (_) =>
        const PresensiMahasiswaPage(matkul: '', latKelas: 0, lonKelas: 0),
    presensiDosen: (_) => const PresensiDosenPage(matkul: ''),

    // REKAP
    rekapMhs: (_) => const RekapMatkulMahasiswaPage(namaMatkul: ''),
    rekapDosen: (_) => const RekapMatkulDosenPage(namaMatkul: ''),
  };

  static Route<dynamic>? onGenerate(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case detailMatkulMahasiswa:
        final data = args as Map;
        return MaterialPageRoute(
          builder: (_) => DetailMatkulMahasiswaPage(
            namaMatkul: data['nama'],
            ruangan: data['ruangan'],
            jam: data['jam'],
            latitude: data['lat'],
            longitude: data['lon'],
          ),
        );

      case detailMatkulDosen:
        return MaterialPageRoute(
          builder: (_) => DetailMatkulDosenPage(namaMatkul: args as String),
        );

      case presensiMahasiswa:
        final data = args as Map;
        return MaterialPageRoute(
          builder: (_) => PresensiMahasiswaPage(
            matkul: data['matkul'],
            latKelas: data['lat'],
            lonKelas: data['lon'],
          ),
        );

      case presensiDosen:
        return MaterialPageRoute(
          builder: (_) => PresensiDosenPage(matkul: args as String),
        );

      case rekapMhs:
        return MaterialPageRoute(
          builder: (_) => RekapMatkulMahasiswaPage(namaMatkul: args as String),
        );

      case rekapDosen:
        return MaterialPageRoute(
          builder: (_) => RekapMatkulDosenPage(namaMatkul: args as String),
        );
    }

    return null;
  }
}
