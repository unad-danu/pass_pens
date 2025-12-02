import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarAdmin(title: "Dashboard Admin"),

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
          // _menuItem(
          // icon: Icons.schedule,
          // title: "Kelola Jadwal",
          // onTap: () =>
          //     Navigator.pushNamed(context, AppRoutes.adminKelolaJadwal),
          // ),
          // _menuItem(
          // icon: Icons.class_,
          // title: "Kelola Kelas",
          // onTap: () =>
          //    Navigator.pushNamed(context, AppRoutes.adminKelolaKelas),
          //),
          _menuItem(
            icon: Icons.meeting_room,
            title: "Kelola Ruang",
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.adminKelolaRuang),
          ),
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

  // ====================================================
  // WIDGET MENU ITEM
  // ====================================================
  static Widget _menuItem({
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

// ====================================================
// CUSTOM APP BAR ADMIN (GAYA MAHASISWA TANPA LOGO)
// ====================================================
class CustomAppBarAdmin extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const CustomAppBarAdmin({super.key, this.title});

  static const double _bottomLineHeight = 10;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0B5E86),
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: 95,
      centerTitle: true,

      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "PASS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "PENS Attendance Smart System",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          if (title != null) ...[
            const SizedBox(height: 4),
            Text(
              title!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),

      // TOMBOL LOGOUT
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          },
        ),
      ],

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(_bottomLineHeight),
        child: Container(
          height: _bottomLineHeight,
          color: const Color(0xFFF4C400),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(95 + _bottomLineHeight);
}
