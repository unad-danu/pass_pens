import 'package:flutter/material.dart';
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B5E86),
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: const Center(
          child: Column(
            children: [
              Text(
                "PASS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "PENS Attendance Smart System",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ruangan : $ruangan", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Jam : $jam", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            const Spacer(),

            // Tombol Presensi (full width)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
            ),
          ],
        ),
      ),
    );
  }
}
