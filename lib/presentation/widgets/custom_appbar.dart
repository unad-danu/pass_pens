import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const CustomAppBar({super.key, required this.title, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            )
          : const SizedBox(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
