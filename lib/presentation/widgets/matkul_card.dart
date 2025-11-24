import 'package:flutter/material.dart';

class MatkulCard extends StatelessWidget {
  final String namaMatkul;
  final String tempat;
  final String jadwal;
  final String? dosen; // untuk dosen
  final String? kelas; // untuk mahasiswa
  final VoidCallback? onTap;

  const MatkulCard({
    super.key,
    required this.namaMatkul,
    required this.tempat,
    required this.jadwal,
    this.dosen,
    this.kelas,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 HEADER MATAKULIAH (HITAM)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                namaMatkul,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 🔥 KONTEN DETAIL
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dosen != null) ...[Text("Dosen : $dosen")],
                  if (kelas != null) ...[Text("Kelas : $kelas")],
                  Text("Tempat : $tempat"),
                  Text("Jadwal : $jadwal"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
