import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class RekapMatkulDosenPage extends StatelessWidget {
  final String namaMatkul;

  const RekapMatkulDosenPage({super.key, required this.namaMatkul});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Rekap Presensi - $namaMatkul"),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Mahasiswa A"),
            subtitle: Text("Hadir 12 / 14"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Mahasiswa B"),
            subtitle: Text("Hadir 10 / 14"),
          ),
        ],
      ),
    );
  }
}
