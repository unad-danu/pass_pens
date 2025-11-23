import 'package:flutter/material.dart';

class HomeMahasiswa extends StatefulWidget {
  const HomeMahasiswa({super.key});

  @override
  State<HomeMahasiswa> createState() => _HomeMahasiswaState();
}

// ================= MODEL + DATA DUMMY (ADA DI DALAM FILE INI) =================
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
    nama: "Pemrograman Mobile",
    dosen: "Ir. Ahmad, S.T., M.Eng",
    tempat: "Ruang B303",
    jadwal: "Senin, 09.00 - 11.30",
  ),
  Matkul(
    nama: "Sistem Embedded",
    dosen: "Dr. Rina, S.T., M.T",
    tempat: "Lab Embedded",
    jadwal: "Selasa, 10.00 - 12.30",
  ),
  Matkul(
    nama: "Jaringan Komputer",
    dosen: "Prof. Dimas, S.T., Ph.D",
    tempat: "Ruang C204",
    jadwal: "Rabu, 08.00 - 10.00",
  ),
];

// ================= HALAMAN HOME =================
class _HomeMahasiswaState extends State<HomeMahasiswa> {
  String search = '';
  bool ascending = true;
  int currentIndex = 0;

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

      // ================= HEADER =================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0B5E86),
        elevation: 0,
        toolbarHeight: 90,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40, width: 40),
            Column(
              children: const [
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
            const SizedBox(height: 40, width: 40),
          ],
        ),
      ),

      // ================= BODY =================
      body: Column(
        children: [
          const SizedBox(height: 10),

          // Back + Home
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: const [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 8),
                  Text(
                    "Home",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Search + Sort
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

          const SizedBox(height: 10),

          // ================= LIST MK =================
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final mk = filtered[index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          mk.nama,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Dosen : ${mk.dosen}"),
                      Text("Tempat : ${mk.tempat}"),
                      Text("Jadwal : ${mk.jadwal}"),
                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          child: const Text("Detail >"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailMahasiswa(matkul: mk),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF0B5E86),
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          setState(() => currentIndex = index);

          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/jadwal_mhs');
              break;
            case 2:
              Navigator.pushNamed(context, '/rekap_mhs');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile_mhs');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Jadwal",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Presensi",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

// ================= HALAMAN DETAIL MK (ADA DI DALAM FILE INI) =================
class DetailMahasiswa extends StatelessWidget {
  final Matkul matkul;

  const DetailMahasiswa({super.key, required this.matkul});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(matkul.nama),
        backgroundColor: const Color(0xFF0B5E86),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mata Kuliah: ${matkul.nama}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Dosen: ${matkul.dosen}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Tempat: ${matkul.tempat}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Jadwal: ${matkul.jadwal}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
