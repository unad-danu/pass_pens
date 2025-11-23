import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import 'presensi_dosen_page.dart';
import 'rekap_matkul_dosen_page.dart';

class DetailMatkulDosenPage extends StatelessWidget {
  final String namaMatkul;

  const DetailMatkulDosenPage({super.key, required this.namaMatkul});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: namaMatkul),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.person_pin_circle),
              label: const Text("Kelola Presensi"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PresensiDosenPage(matkul: namaMatkul),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text("Lihat Rekap Presensi"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RekapMatkulDosenPage(namaMatkul: namaMatkul),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
