import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';

import '../widgets/custom_appbar.dart';
import 'rekap_detail_dosen_page.dart';

class RekapPresensiMatkulPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const RekapPresensiMatkulPage({super.key, required this.data});

  @override
  State<RekapPresensiMatkulPage> createState() =>
      _RekapPresensiMatkulPageState();
}

class _RekapPresensiMatkulPageState extends State<RekapPresensiMatkulPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> rekap = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRekap();
  }

  Future<void> fetchRekap() async {
    try {
      final res = await supabase
          .from('absensi')
          .select('pertemuan, status')
          .eq('jadwal_id', widget.data["jadwal_id"]);

      Map<int, Map<String, int>> counter = {};

      for (final row in res) {
        int minggu = row["pertemuan"] ?? 0;
        String status = row["status"] ?? "";

        if (minggu == 0) continue;

        counter.putIfAbsent(minggu, () => {"hadir": 0, "alpha": 0});

        if (status == "hadir") {
          counter[minggu]!["hadir"] = (counter[minggu]!["hadir"] ?? 0) + 1;
        }

        if (status == "alpha") {
          counter[minggu]!["alpha"] = (counter[minggu]!["alpha"] ?? 0) + 1;
        }
      }

      List<Map<String, dynamic>> finalList = [];

      for (int minggu = 1; minggu <= 16; minggu++) {
        final data = counter[minggu];

        finalList.add({
          "minggu": minggu,
          "jadwal_id": widget.data["jadwal_id"],

          "hadir": data?["hadir"] ?? 0,
          "alpha": data?["alpha"] ?? 0,

          "status": data == null ? "belum" : "ada",
        });
      }

      setState(() {
        rekap = finalList;
        loading = false;
      });
    } catch (e) {
      print("Error fetch rekap: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      appBar: const CustomAppBar(role: "dsn"),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                // ===== Back + Title =====
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
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),

                const SizedBox(height: 20),

                // ===== Header Matkul =====
                FadeInDown(
                  duration: const Duration(milliseconds: 450),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 26,
                      horizontal: 26,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
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
                        Text(
                          "Kelas: ${data["kelas"] ?? "-"}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Jumlah mahasiswa: ${data["jumlah_mhs"] ?? "-"}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ===== List Pertemuan dari Database =====
                ...rekap.map((p) {
                  return FadeInUp(
                    duration: const Duration(milliseconds: 350),
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
                          // Detail Pertemuan
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_month, size: 18),
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
                                p["status"] == "belum"
                                    ? const Text(
                                        "Belum Dilaksanakan",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : Row(
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
                            onTap: p["status"] == "belum"
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            RekapDetailDosenPage(data: p),
                                      ),
                                    );
                                  },
                            child: Text(
                              "Lihat Detail",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: p["status"] == "belum"
                                    ? TextDecoration.none
                                    : TextDecoration.underline,
                                color: p["status"] == "belum"
                                    ? Colors.grey
                                    : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }
}
