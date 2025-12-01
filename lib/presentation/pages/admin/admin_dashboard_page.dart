import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _menuItem(
            icon: Icons.book,
            title: "Kelola Matkul",
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.adminKelolaMatkul),
          ),
          _menuItem(
            icon: Icons.people,
            title: "Kelola Dosen",
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.adminKelolaDosen),
          ),
          _menuItem(
            icon: Icons.schedule,
            title: "Kelola Jadwal",
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.adminKelolaJadwal),
          ),
          _menuItem(
            icon: Icons.class_,
            title: "Kelola Kelas",
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.adminKelolaKelas),
          ),
          _menuItem(
            icon: Icons.meeting_room,
            title: "Kelola Ruang",
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.adminKelolaRuang),
          ),

          // ============================
          // MENU BARU: ASSIGN MATKUL
          // ============================
          _menuItem(
            icon: Icons.add_task,
            title: "Assign Matkul",
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.adminAssignMatkul),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.blueGrey.shade100,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueGrey.shade900),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
