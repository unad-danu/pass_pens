import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart'; // pastikan path sesuai

class RekapMatkulMahasiswaPage extends StatefulWidget {
  const RekapMatkulMahasiswaPage({super.key});

  @override
  State<RekapMatkulMahasiswaPage> createState() =>
      _RekapMatkulMahasiswaPageState();
}

class _RekapMatkulMahasiswaPageState extends State<RekapMatkulMahasiswaPage> {
  String? selectedMatkul;

  final List<String> listMatkul = [
    "Mobile Programming",
    "Basis Data",
    "Jaringan Komputer",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ======================
      //     CUSTOM APPBAR
      // ======================
      appBar: const CustomAppBar(role: "mhs"),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Judul
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Rekap Presensi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 12),

          // Dropdown mata kuliah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Pilih Mata Kuliah",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              value: selectedMatkul,
              items: listMatkul
                  .map(
                    (matkul) =>
                        DropdownMenuItem(value: matkul, child: Text(matkul)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => selectedMatkul = value);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Daftar pertemuan
          Expanded(
            child: selectedMatkul == null
                ? const Center(child: Text("Silahkan pilih mata kuliah"))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: const [
                      _PertemuanCard(
                        pertemuan: "Pertemuan 1",
                        status: "Hadir",
                        jam: "08.00",
                      ),
                      SizedBox(height: 8),
                      _PertemuanCard(
                        pertemuan: "Pertemuan 2",
                        status: "Alfa",
                        jam: "-",
                      ),
                      SizedBox(height: 8),
                      _PertemuanCard(
                        pertemuan: "Pertemuan 3",
                        status: "Hadir",
                        jam: "08.00",
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PertemuanCard extends StatelessWidget {
  final String pertemuan;
  final String status;
  final String jam;

  const _PertemuanCard({
    required this.pertemuan,
    required this.status,
    required this.jam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black45),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header pertemuan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                pertemuan,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text("Status: $status", style: const TextStyle(fontSize: 15)),

          const SizedBox(height: 4),

          Text("Jam: $jam", style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
