import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/custom_appbar.dart';

class RekapDetailDosenPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const RekapDetailDosenPage({super.key, required this.data});

  // =====================================
  // FUNCTION PRODI (Final)
  // =====================================
  String getProdiString(String nrp) {
    String prodiCode = nrp.substring(0, 2);
    String prodi = "Tidak diketahui";
    if (prodiCode == "32") prodi = "Teknik Komputer";

    int angkatan = int.parse(nrp.substring(2, 4));
    int tahunSekarang = int.parse(
      DateTime.now().year.toString().substring(2, 4),
    );
    int kelasTahun = tahunSekarang - angkatan + 1;
    if (kelasTahun < 1) kelasTahun = 1;

    String jenjangCode = nrp.substring(4, 7);
    String jenjang = (jenjangCode == "600")
        ? "D4"
        : (jenjangCode == "500")
        ? "D3"
        : "Unknown";

    int urut = int.parse(nrp.substring(7, 10));
    String kelasHuruf = "Unknown";

    if (urut >= 1 && urut <= 30)
      kelasHuruf = "A";
    else if (urut <= 60)
      kelasHuruf = "B";
    else if (urut <= 90)
      kelasHuruf = "C";
    else if (urut <= 120)
      kelasHuruf = "D";
    else if (urut <= 150)
      kelasHuruf = "E";

    return "$kelasTahun $jenjang $prodi $kelasHuruf";
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> hadir = [
      {"nama": "Mulyawan Danu", "nrp": "3224600013"},
      {"nama": "Calista Anggraini", "nrp": "3224600021"},
      {"nama": "Alifia Nur Fadila", "nrp": "3224600032"},
    ];

    final List<Map<String, String>> alpha = [
      {"nama": "Shatara Ayu Maulina", "nrp": "3224600044"},
      {"nama": "Bintang Pratama", "nrp": "3224600055"},
    ];

    return Scaffold(
      appBar: const CustomAppBar(role: "dsn"),

      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ======================================
          // HEADER FIX — BACK BUTTON SEJAJAR & TITLE CENTER
          // ======================================
          SizedBox(
            height: 50,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back, size: 28),
                    ),
                  ),
                ),

                Center(
                  child: Text(
                    "Pertemuan ${data["minggu"]}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ================================
          // MAHASISWA HADIR
          // ================================
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Mahasiswa Hadir",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          ...List.generate(hadir.length, (i) {
            final mhs = hadir[i];
            return FadeInUp(
              duration: Duration(milliseconds: 300 + (i * 60)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mhs["nama"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("NRP : ${mhs["nrp"]}"),
                          Text("Prodi : ${getProdiString(mhs["nrp"]!)}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // ================================
          // MAHASISWA TIDAK HADIR
          // ================================
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: const [
                  Icon(Icons.cancel, color: Colors.red, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Mahasiswa Tidak Hadir",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          ...List.generate(alpha.length, (i) {
            final mhs = alpha[i];
            return FadeInUp(
              duration: Duration(milliseconds: 300 + (i * 60)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cancel, color: Colors.red),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mhs["nama"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("NRP : ${mhs["nrp"]}"),
                          Text("Prodi : ${getProdiString(mhs["nrp"]!)}"),
                        ],
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
