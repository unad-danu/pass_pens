import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class DetailMatkulDosenPage extends StatelessWidget {
  final String nama;
  final String ruangan;
  final String jam;

  const DetailMatkulDosenPage({
    super.key,
    required this.nama,
    required this.ruangan,
    required this.jam,
  });

  @override
  Widget build(BuildContext context) {
    const String attendanceTerakhir = "Selasa, 11 November 2025";

    // DATA HADIR / TIDAK HADIR
    final List<Map<String, String>> dataMahasiswa = [
      {"nama": "Ari Tejo", "status": "Hadir"},
      {"nama": "Bagas Dwi", "status": "Tidak Hadir"},
      {"nama": "Cindy Lestari", "status": "Hadir"},
      {"nama": "Dimas Saputra", "status": "Hadir"},
    ];

    final tidakHadir = dataMahasiswa.where((m) => m["status"] == "Tidak Hadir");
    final hadir = dataMahasiswa.where((m) => m["status"] == "Hadir");

    return Scaffold(
      appBar: const CustomAppBar(showBack: false, role: "dsn"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =======================================
            // ROW BACK BUTTON + JUDUL
            // =======================================
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back, size: 28),
                    ),
                  ),
                ),
                const Text(
                  "Detail Matakuliah",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ============================
            // CARD DETAIL MATKUL
            // ============================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        nama.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Text("Dosen : "),
                  const SizedBox(height: 4),
                  Text("Tempat : $ruangan"),
                  const SizedBox(height: 4),
                  Text("Jadwal : $jam"),
                  const SizedBox(height: 4),
                  Text("Attendance Terakhir : $attendanceTerakhir"),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Offline Presensi",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Online Presensi",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ============================
            // HISTORY PRESENSI
            // ============================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
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

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Column(
                      children: [
                        Container(
                          color: Colors.lightBlueAccent.withOpacity(0.3),
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

                        for (var item in [
                          {"id": "1064", "tgl": "Selasa, 11 November 2025"},
                          {"id": "1043", "tgl": "Selasa, 11 November 2025"},
                          {"id": "1022", "tgl": "Selasa, 11 November 2025"},
                          {"id": "1001", "tgl": "Selasa, 11 November 2025"},
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

            const SizedBox(height: 25),

            // ============================
            // TABEL HADIR / TIDAK HADIR (SUDAH DIBUAT SESUAI PERMINTAAN)
            // ============================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text(
                        "Presensi Mahasiswa",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ============================
                  // LIST TIDAK HADIR
                  // ============================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    color: Colors.lightBlueAccent.withOpacity(0.3),
                    child: const Text(
                      "Tidak Hadir",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  for (var mhs in tidakHadir)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              mhs["nama"]!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              mhs["status"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ============================
                  // LIST HADIR
                  // ============================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    color: Colors.lightBlueAccent.withOpacity(0.3),
                    child: const Text(
                      "Hadir",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  for (var mhs in hadir)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              mhs["nama"]!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              mhs["status"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
