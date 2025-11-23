import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Notifikasi"),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text("Pengumuman Presensi"),
            subtitle: Text("Presensi kelas Mobile Programming dibuka."),
          ),
          Divider(),
          ListTile(
            title: Text("Notifikasi Sistem"),
            subtitle: Text("Akun Anda telah diverifikasi."),
          ),
        ],
      ),
    );
  }
}
