import 'package:flutter/material.dart';
import '../pages/detail_matkul_mahasiswa_page.dart'; // <-- tambahkan import ini

class HomeMahasiswa extends StatefulWidget {
  const HomeMahasiswa({super.key});

  @override
  State<HomeMahasiswa> createState() => _HomeMahasiswaState();
}

class Matkul {
  final String nama;
  final String dosen;
  final String tempat;
  final String jadwal;

  Matkul({
    required this.nama,
    required this.dosen,
    required this.tempat,
    required this.jadwal,
  });
}

List<Matkul> mataKuliah = [
  Matkul(
    nama: "Praktikum Bahasa Pemrograman",
    dosen: "Pak A",
    tempat: "Gedung D201",
    jadwal: "08:00 - 10:00",
  ),
  Matkul(
    nama: "Bahasa Pemrograman",
    dosen: "Bu B",
    tempat: "Gedung D202",
    jadwal: "10:00 - 12:00",
  ),
  Matkul(
    nama: "Workshop Sistem Analog",
    dosen: "Pak C",
    tempat: "Gedung D301",
    jadwal: "13:00 - 15:00",
  ),
];

class _HomeMahasiswaState extends State<HomeMahasiswa> {
  String search = '';
  bool ascending = true;

  @override
  Widget build(BuildContext context) {
    List<Matkul> filtered = mataKuliah
        .where((m) => m.nama.toLowerCase().contains(search.toLowerCase()))
        .toList();

    filtered.sort(
      (a, b) => ascending ? a.nama.compareTo(b.nama) : b.nama.compareTo(a.nama),
    );

    return Scaffold(
      backgroundColor: Colors.white,

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
        children: [
          const SizedBox(height: 10),

          const Text(
            "Home",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final mk = filtered[index];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailMatkulMahasiswaPage(
                          namaMatkul: mk.nama,
                          ruangan: mk.tempat,
                          jam: mk.jadwal,
                          latitude: 0.0, // nanti isi dari supabase
                          longitude: 0.0, // nanti isi dari supabase
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
                        // TITLE BLACK BAR
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
                          "Dosen : ${mk.dosen}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tempat : ${mk.tempat}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Jadwal : ${mk.jadwal}",
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
