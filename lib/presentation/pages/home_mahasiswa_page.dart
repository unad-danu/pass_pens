import 'package:flutter/material.dart';

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
    dosen: "",
    tempat: "",
    jadwal: "",
  ),
  Matkul(nama: "Bahasa Pemrograman", dosen: "", tempat: "", jadwal: ""),
  Matkul(nama: "Workshop Sistem Analog", dosen: "", tempat: "", jadwal: ""),
];

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

          // BACK + HOME
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Center(
              child: Text(
                "Home",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // SEARCH + SORT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // SEARCH BAR
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
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

                // SORT BUTTON
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

          // LIST MK
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
                      const Text("Dosen :", style: TextStyle(fontSize: 15)),
                      const SizedBox(height: 4),
                      const Text("Tempat :", style: TextStyle(fontSize: 15)),
                      const SizedBox(height: 4),
                      const Text("Jadwal :", style: TextStyle(fontSize: 15)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // BOTTOM NAV (tidak diubah)
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
              // NOTIFIKASI
              Navigator.pushNamed(context, '/notification');
              break;

            case 2:
              // REKAP PRESENSI — HARUS KIRIM ARGUMEN
              Navigator.pushNamed(
                context,
                '/rekap_mhs',
                arguments: "Praktikum Bahasa Pemrograman",
              );
              break;

            case 3:
              // PROFIL
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notif",
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
