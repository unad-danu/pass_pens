import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class RekapMatkulMahasiswaPage extends StatelessWidget {
  final String namaMatkul;

  const RekapMatkulMahasiswaPage({super.key, required this.namaMatkul});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Rekap - $namaMatkul"),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text("Pertemuan 1"),
            subtitle: Text("Status: Hadir"),
            trailing: Text("08.00"),
          ),
          Divider(),
          ListTile(
            title: Text("Pertemuan 2"),
            subtitle: Text("Status: Alfa"),
            trailing: Text("-"),
          ),
        ],
      ),
    );
  }
}
