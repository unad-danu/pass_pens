import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final String? title;
  final String? role;

  const CustomAppBar({super.key, this.showBack = false, this.title, this.role});

  static const double _bottomLineHeight = 10;

  @override
  Widget build(BuildContext context) {
    final String normalizedRole = (role ?? "").toLowerCase();
    final bool isDosen = normalizedRole == "dsn" || normalizedRole == "dosen";

    final Color appBarColor = isDosen
        ? const Color(0xFF898C94)
        : const Color(0xFF0B5E86);

    final Color bottomLineColor = isDosen
        ? const Color(0xFF000000)
        : const Color(0xFFF4C400);

    return AppBar(
      backgroundColor: appBarColor,
      automaticallyImplyLeading: showBack,
      elevation: 0,
      toolbarHeight: 95,
      centerTitle: true,

      title: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset("assets/logoPENS.png", height: 38),

            Column(
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
                  SizedBox(height: 4),
                  Text(
                    title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),

            Image.asset("assets/PASS.png", height: 38),
          ],
        ),
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(_bottomLineHeight),
        child: Container(height: _bottomLineHeight, color: bottomLineColor),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(95 + _bottomLineHeight);
}
