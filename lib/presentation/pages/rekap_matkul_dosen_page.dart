import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

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
      appBar: const CustomAppBar(role: "dsn"),

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
