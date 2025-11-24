import 'package:flutter/material.dart';

class RekapMatkulDosenPage extends StatefulWidget {
  const RekapMatkulDosenPage({super.key});

  @override
  _RekapMatkulDosenPageState createState() => _RekapMatkulDosenPageState();
}

class _RekapMatkulDosenPageState extends State<RekapMatkulDosenPage> {
  String? selectedMatkul;

  final List<String> listMatkul = [
    "Mobile Programming",
    "Basis Data",
    "Jaringan Komputer",
  ];

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

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          const Center(
            child: Text(
              "Rekap Presensi Dosen",
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
              ),
              value: selectedMatkul,
              items: listMatkul
                  .map(
                    (matkul) =>
                        DropdownMenuItem(value: matkul, child: Text(matkul)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selectedMatkul = value),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: selectedMatkul == null
                ? const Center(child: Text("Silahkan pilih mata kuliah"))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: const [
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text("Mahasiswa A"),
                        subtitle: Text("Hadir 12 / 14"),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text("Mahasiswa B"),
                        subtitle: Text("Hadir 10 / 14"),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
