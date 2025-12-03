import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/custom_appbar.dart';
import 'rekap_detail_dosen_page.dart';

class RekapPresensiMatkulPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const RekapPresensiMatkulPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> pertemuan = List.generate(16, (i) {
      return {"minggu": i + 1, "hadir": 76, "alpha": 11};
    });

    return Scaffold(
      appBar: const CustomAppBar(role: "dsn"),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ===================== BACK + TITLE ==========================
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.arrow_back, size: 28),
                  ),
                ),
              ),

              const Expanded(
                child: Center(
                  child: Text(
                    "Rekap Presensi Mahasiswa",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(width: 36), // agar title tetap center
            ],
          ),

          const SizedBox(height: 20),

          // ===================== HEADER MATKUL FULL HITAM ==========================
          FadeInDown(
            duration: const Duration(milliseconds: 450),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 26,
                horizontal: 26,
              ), // lebih lebar
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // === Judul matkul (full center + wrap) ===
                  Text(
                    data["matkul"],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // === KELAS ===
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.class_, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Kelas: 3 Str Teknik Komputer",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // === JUMLAH MAHASISWA ===
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Jumlah mahasiswa: 87",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // ===================== LIST PERTEMUAN ==========================
          ...List.generate(pertemuan.length, (i) {
            final p = pertemuan[i];

            return FadeInUp(
              duration: Duration(milliseconds: 300 + i * 50),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                size: 18,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Pertemuan ${p["minggu"]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text("${p["hadir"]} Hadir"),

                              const SizedBox(width: 20),

                              const Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text("${p["alpha"]} Alpha"),
                            ],
                          ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RekapDetailDosenPage(data: p),
                          ),
                        );
                      },
                      child: const Text(
                        "Lihat Detail",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
