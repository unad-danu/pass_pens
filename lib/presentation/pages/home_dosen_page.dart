import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../pages/detail_matkul_dosen_page.dart';

class HomeDosenPage extends StatefulWidget {
  const HomeDosenPage({super.key});

  @override
  State<HomeDosenPage> createState() => _HomeDosenPageState();
}

class MatkulDosen {
  final String nama;
  final String ruangan;
  final String jam;

  MatkulDosen({required this.nama, required this.ruangan, required this.jam});
}

List<MatkulDosen> daftarMatkulDosen = [
  MatkulDosen(nama: "Sistem Operasi", ruangan: "D201", jam: "08.00 - 09.40"),
  MatkulDosen(nama: "Jaringan Komputer", ruangan: "D305", jam: "10.00 - 11.40"),
  MatkulDosen(
    nama: "Pemrograman Mobile",
    ruangan: "Lab Android",
    jam: "13.00 - 15.30",
  ),
];

class _HomeDosenPageState extends State<HomeDosenPage> {
  String search = "";
  bool ascending = true;

  @override
  Widget build(BuildContext context) {
    List<MatkulDosen> filtered = daftarMatkulDosen
        .where((m) => m.nama.toLowerCase().contains(search.toLowerCase()))
        .toList();

    filtered.sort(
      (a, b) => ascending ? a.nama.compareTo(b.nama) : b.nama.compareTo(a.nama),
    );

    return Scaffold(
      appBar: const CustomAppBar(title: "Beranda Dosen"),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // SEARCH & SORT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Cari Mata Kuliah",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => setState(() => search = value),
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

          const SizedBox(height: 12),

          // LIST MK TANPA MATKUL CARD
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final mk = filtered[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailMatkulDosenPage(
                          nama: mk.nama,
                          ruangan: mk.ruangan,
                          jam: mk.jam,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mk.nama,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text("Ruangan: ${mk.ruangan}"),
                          Text("Jam: ${mk.jam}"),
                        ],
                      ),
                    ),
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
