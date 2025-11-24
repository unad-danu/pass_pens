import 'package:flutter/material.dart';

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

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B5E86),
        elevation: 0,
        toolbarHeight: 80,
        title: const Column(
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
        centerTitle: true,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
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
