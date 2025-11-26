import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final String? title;
  final String? role; // opsional

  const CustomAppBar({super.key, this.showBack = false, this.title, this.role});

  @override
  Widget build(BuildContext context) {
    // ============================
    // NORMALISASI ROLE (lowercase)
    // ============================
    final String normalizedRole = (role ?? "").toLowerCase();

    final bool isDosen = normalizedRole == "dsn" || normalizedRole == "dosen";

    // ============================
    // WARNA APPBAR BERDASARKAN ROLE
    // ============================
    final Color appBarColor = isDosen
        ? const Color.fromARGB(255, 2, 135, 20) // hijau dosen
        : const Color(0xFF0B5E86); // biru mahasiswa (default)

    return AppBar(
      backgroundColor: appBarColor,
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: 95,
      centerTitle: true,

      // ============================
      // TOMBOL BACK OPSIONAL
      // ============================
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          : const SizedBox(),

      title: Column(
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

          // ============================
          // SUBTITLE / TITLE (OPSIONAL)
          // ============================
          if (title != null) ...[
            const SizedBox(height: 6),
            Text(
              title!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(95);
}
