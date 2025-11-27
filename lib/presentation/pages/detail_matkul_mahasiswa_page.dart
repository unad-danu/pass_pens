import 'package:flutter/material.dart';
import 'presensi_mahasiswa_page.dart';
import '../widgets/custom_appbar.dart';

class DetailMatkulMahasiswaPage extends StatelessWidget {
  final String namaMatkul;
  final String dosen;
  final String ruangan;
  final String jadwal;
  final String attendanceTerakhir;
  final bool isOffline; // true = offline (merah), false = online (biru)
  final double latitude;
  final double longitude;

  const DetailMatkulMahasiswaPage({
    super.key,
    required this.namaMatkul,
    required this.dosen,
    required this.ruangan,
    required this.jadwal,
    required this.attendanceTerakhir,
    required this.isOffline,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBack: false,
        role: "mhs",
      ), // back dihapus dari AppBar

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =============================
            // TOMBOL BACK + JUDUL
            // =============================
            Stack(
              alignment: Alignment.center,
              children: [
                // Tombol Back di kiri
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back, size: 28),
                    ),
                  ),
                ),

                // Judul di tengah
                const Text(
                  "Detail Matakuliah",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // =============================
            // CARD INFO MATA KULIAH
            // =============================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Hitam
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        namaMatkul,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text("Dosen : $dosen"),
                  const SizedBox(height: 4),
                  Text("Tempat : $ruangan"),
                  const SizedBox(height: 4),
                  Text("Jadwal : $jadwal"),
                  const SizedBox(height: 4),
                  Text("Attendance Terakhir : $attendanceTerakhir"),

                  const SizedBox(height: 20),

                  // Tombol Presensi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOffline ? Colors.red : Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (isOffline) {
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
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Presensi Online dilakukan!"),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Presensi",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==================================
            // HISTORY PRESENSI
            // ==================================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Header Hitam
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text(
                        "History Presensi",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tabel
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Column(
                      children: [
                        // Header Tabel
                        Container(
                          color: Colors.lightBlue[100],
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "ID",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Tanggal",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Isi contoh dummy
                        for (var item in [
                          {"id": "1084", "tgl": "Selasa \n11 November 2025"},
                          {"id": "1063", "tgl": "Selasa \n11 November 2025"},
                          {"id": "1042", "tgl": "Selasa \n11 November 2025"},
                          {"id": "1021", "tgl": "Selasa \n11 November 2025"},
                        ])
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item["id"]!,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item["tgl"]!,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
