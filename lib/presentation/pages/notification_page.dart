import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int currentIndex = 1; // Notifikasi ada di posisi ke-1

  void handleNavTap(int index) {
    setState(() => currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.homeMahasiswa);
        break;

      case 1:
        // halaman ini → tidak pindah
        break;

      case 2:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.rekapMhs,
          arguments: "Praktikum Bahasa Pemrograman",
        );
        break;

      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B5E86),
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: const Center(
          child: Column(
            children: [
              Text(
                "PASS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "PENS Attendance Smart System",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            "Notifikasi",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNotifCard(
                  title: "Pengumuman Presensi",
                  subtitle: "Presensi kelas Mobile Programming dibuka.",
                ),
                const SizedBox(height: 12),
                _buildNotifCard(
                  title: "Notifikasi Sistem",
                  subtitle: "Akun Anda telah diverifikasi.",
                ),
                const SizedBox(height: 12),
                _buildNotifCard(
                  title: "Pengingat Presensi",
                  subtitle: "Presensi wajib dilakukan dalam 10 menit.",
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF0B5E86),
        unselectedItemColor: Colors.black54,
        onTap: handleNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notif",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Presensi",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildNotifCard({required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black45),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(subtitle, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
