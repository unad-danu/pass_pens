import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final String? title;
  final String? role;

  const CustomAppBar({super.key, this.showBack = false, this.title, this.role});

  @override
  Widget build(BuildContext context) {
    final String normalizedRole = (role ?? "").toLowerCase();
    final bool isDosen = normalizedRole == "dsn" || normalizedRole == "dosen";

    final Color appBarColor = isDosen
        ? const Color(0xFF898C94) // Abu-abu dosen
        : const Color(0xFF0B5E86); // Biru mahasiswa

    final Color bottomLineColor = isDosen
        ? const Color(0xFF000000) // Dosen → hitam
        : const Color(0xFFF4C400); // Mahasiswa → kuning

    final double bottomLineHeight = 10;

    return AppBar(
      backgroundColor: appBarColor,
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: 95,
      centerTitle: true,

      // ===========================
      //        CONTENT
      // ===========================
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset("assets/logoPENS.png", height: 38),

          Expanded(
            child: Column(
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Image.asset("assets/PASS.png", height: 38),
        ],
      ),

      // ===========================
      //   GARIS DI BAWAH APPBAR
      // ===========================
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(bottomLineHeight),
        child: Container(height: bottomLineHeight, color: bottomLineColor),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(95);
}
