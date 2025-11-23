import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import 'presensi_mahasiswa_page.dart';

class DetailMatkulMahasiswaPage extends StatelessWidget {
  final String namaMatkul;
  final String ruangan;
  final String jam;
  final double latitude;
  final double longitude;

  const DetailMatkulMahasiswaPage({
    super.key,
    required this.namaMatkul,
    required this.ruangan,
    required this.jam,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: namaMatkul),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ruangan : $ruangan", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Jam : $jam", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PresensiMahasiswaPage(
                      matkul: namaMatkul,
                      latKelas: latitude,
                      lonKelas: longitude,
                    ),
                  ),
                );
              },
              child: const Text("Presensi Sekarang"),
            ),
          ],
        ),
      ),
    );
  }
}
