import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class RekapDetailDosenPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const RekapDetailDosenPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mahasiswa = [
      {"nama": "Mulyawan Danu Adriansyah", "hadir": 3, "alpha": 2},
      {"nama": "Shatara Ayu Maulina", "hadir": 0, "alpha": 5},
      {"nama": "Calista Anggraini", "hadir": 2, "alpha": 3},
      {"nama": "Alifia Nur Fadila", "hadir": 5, "alpha": 0},
    ];

    return Scaffold(
      appBar: const CustomAppBar(
        role: "dsn",
        title: "Rekap Presensi",
        showBack: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // HEADER MATKUL
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    data["matkul"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Waktu : Minggu ke ${data["minggu"]}"),
                      Text("Hadir  : ${data["hadir"]}"),
                      Text("Alpha  : ${data["alpha"]}"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // LIST MAHASISWA
          ...mahasiswa.map((mhs) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nama & status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mhs["nama"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          Text(" ${mhs["hadir"]} Hadir   "),
                          const Icon(Icons.cancel, color: Colors.red, size: 20),
                          Text(" ${mhs["alpha"]} Alpha"),
                        ],
                      ),
                    ],
                  ),

                  // Detail
                  InkWell(
                    onTap: () {},
                    child: const Text(
                      "Lihat Detail >",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
