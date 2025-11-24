import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class RekapMatkulMahasiswaPage extends StatefulWidget {
  const RekapMatkulMahasiswaPage({super.key});

  @override
  State<RekapMatkulMahasiswaPage> createState() =>
      _RekapMatkulMahasiswaPageState();
}

class _RekapMatkulMahasiswaPageState extends State<RekapMatkulMahasiswaPage> {
  int currentIndex = 2; // Rekap berada di posisi ke-2
  String? selectedMatkul; // Mata kuliah yang dipilih

  final List<String> listMatkul = [
    "Mobile Programming",
    "Basis Data",
    "Jaringan Komputer",
  ];

  void handleNavTap(int index) {
    setState(() => currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.homeMahasiswa);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.notification);
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===== HEADER mirip notifikasi =====
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

      // ===== BODY =====
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

      // ===== BOTTOM NAV BAR =====
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF0B5E86),
        unselectedItemColor: Colors.black54,
        onTap: handleNavTap,
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

// Widget pertemuan mirip card notifikasi
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
