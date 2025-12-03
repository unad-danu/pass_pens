import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_appbar.dart';

class RekapDetailDosenPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const RekapDetailDosenPage({super.key, required this.data});

  // =====================================
  // FUNCTION PRODI (Tetap)
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

    if (urut >= 1 && urut <= 30) {
      kelasHuruf = "A";
    } else if (urut <= 60)
      kelasHuruf = "B";
    else if (urut <= 90)
      kelasHuruf = "C";
    else if (urut <= 120)
      kelasHuruf = "D";
    else if (urut <= 150)
      kelasHuruf = "E";

    return "$kelasTahun $jenjang $prodi $kelasHuruf";
  }

  // ============================================
  // FETCH ABSENSI DARI SUPABASE (PENTING!)
  // ============================================
  Future<Map<String, dynamic>> fetchAbsensi() async {
    final supabase = Supabase.instance.client;

    final jadwalId = data["jadwal_id"];
    final pertemuan = data["minggu"];

    // Ambil semua absensi per pertemuan
    final resp = await supabase
        .from("absensi")
        .select("*, mahasiswa:nama_mahasiswa(id, nama, nrp)")
        .eq("jadwal_id", jadwalId)
        .eq("pertemuan", pertemuan);

    List hadir = [];
    List alpha = [];

    for (var row in resp) {
      bool valid = row["distance_valid"] == true;
      String status = row["status"] ?? "";

      final mhs = {
        "nama": row["mahasiswa"]["nama"],
        "nrp": row["mahasiswa"]["nrp"],
        "jarak": row["jarak"]?.toStringAsFixed(2) ?? "-",
      };

      if (valid || status == "hadir") {
        hadir.add(mhs);
      } else {
        alpha.add(mhs);
      }
    }

    return {"hadir": hadir, "alpha": alpha};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(role: "dsn"),

      body: FutureBuilder(
        future: fetchAbsensi(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final hadir = snap.data!["hadir"];
          final alpha = snap.data!["alpha"];

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // TITLE
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

              // ---------------- MAHASISWA HADIR ----------------
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
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

              ...hadir.map((mhs) {
                return FadeInUp(
                  duration: const Duration(milliseconds: 350),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                                mhs["nama"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("NRP : ${mhs["nrp"]}"),
                              Text("Prodi : ${getProdiString(mhs["nrp"])}"),
                              Text("Jarak : ${mhs["jarak"]} m"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // ---------------- MAHASISWA ALPHA ----------------
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red),
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

              ...alpha.map((mhs) {
                return FadeInUp(
                  duration: const Duration(milliseconds: 350),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                                mhs["nama"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("NRP : ${mhs["nrp"]}"),
                              Text("Prodi : ${getProdiString(mhs["nrp"])}"),
                              Text("Jarak : ${mhs["jarak"]} m"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
