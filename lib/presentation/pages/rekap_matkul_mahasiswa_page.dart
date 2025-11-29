import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import 'rekap_detail_matkul_mahasiswa_page.dart';

class RekapMatkulMahasiswaPage extends StatefulWidget {
  @override
  _RekapMatkulMahasiswaPageState createState() =>
      _RekapMatkulMahasiswaPageState();
}

class _RekapMatkulMahasiswaPageState extends State<RekapMatkulMahasiswaPage> {
  List<Map<String, dynamic>> matkulList = [
    {"nama": "Elektronika Dasar", "pertemuan": 16},
    {"nama": "Sistem Digital", "pertemuan": 14},
    {"nama": "Jaringan Komputer", "pertemuan": 12},
    {"nama": "Pemrograman Mobile", "pertemuan": 10},
  ];

  String searchQuery = "";
  bool ascending = true;

  @override
  Widget build(BuildContext context) {
    List filtered = matkulList.where((m) {
      return m["nama"].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    filtered.sort(
      (a, b) => ascending
          ? a["nama"].compareTo(b["nama"])
          : b["nama"].compareTo(a["nama"]),
    );

    return Scaffold(
      appBar: const CustomAppBar(role: "mhs"),

      body: Column(
        children: [
          const SizedBox(height: 10),

          const Text(
            "Rekap Presensi Mata Kuliah",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search",
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black38),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                    onChanged: (v) => setState(() => searchQuery = v),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => setState(() => ascending = !ascending),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.sort),
                  ),
                ),
              ],
            ),
          ),

          // LIST MATKUL
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final mk = filtered[index];
                return Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      mk["nama"],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${mk["pertemuan"]} Pertemuan"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailRekapMatkulPage(
                            namaMatkul: mk["nama"],
                            totalPertemuan: mk["pertemuan"],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
