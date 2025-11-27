import 'package:flutter/material.dart';

// HOME
import '../pages/home_mahasiswa_page.dart';
import '../pages/home_dosen_page.dart';

// NOTIFICATION
import '../pages/notification_page.dart';

// REKAP
import '../pages/rekap_matkul_mahasiswa_page.dart';
import '../pages/rekap_matkul_dosen_page.dart';

// PROFILE
import '../pages/profile_page.dart';

class MainNavigation extends StatefulWidget {
  final String role; // "mhs" atau "dsn"

  const MainNavigation({super.key, required this.role});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    // ============================
    //  HALAMAN BERDASARKAN ROLE
    // ============================
    if (widget.role == "mhs" || widget.role == "mahasiswa") {
      pages = [
        const HomeMahasiswa(),
        NotificationPage(role: "mhs"),
        const RekapMatkulMahasiswaPage(), // FIX
        ProfilePage(role: widget.role),
      ];
    } else {
      pages = [
        const HomeDosenPage(),
        NotificationPage(role: "dsn"),
        const RekapMatkulDosenPage(), // FIX
        ProfilePage(role: widget.role),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = (widget.role == "dsn" || widget.role == "dosen")
        ? const Color(0xFF000000)
        : const Color(0xFF0B5E86);

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: selectedColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifikasi",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Rekap"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
