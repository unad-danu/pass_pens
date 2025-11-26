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
      backgroundColor: Colors.white,

      // ==============================
      // CUSTOM APPBAR
      // ==============================
      appBar: const CustomAppBar(role: "dsn"),

      // ==============================
      // BODY
      // ==============================
      body: Column(
        children: [
          const SizedBox(height: 10),

          const Center(
            child: Text(
              "Home",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 12),

          // SEARCH + SORT
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
                    onChanged: (v) => setState(() => search = v),
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

          const SizedBox(height: 10),

          // LIST MATKUL
          Expanded(
            child: ListView.builder(
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
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black45),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TOP BLACK TITLE BAR
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              mk.nama,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        Text(
                          "Ruangan : ${mk.ruangan}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Jam     : ${mk.jam}",
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
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
