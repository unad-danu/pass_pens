import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import 'rekap_presensi_matkul_page.dart';
import '../../data/services/rekap_dosen_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RekapMatkulDosenPage extends StatefulWidget {
  const RekapMatkulDosenPage({super.key});

  @override
  State<RekapMatkulDosenPage> createState() => _RekapMatkulDosenPageState();
}

class _RekapMatkulDosenPageState extends State<RekapMatkulDosenPage> {
  final supabase = Supabase.instance.client;

  String searchQuery = "";
  bool ascending = true;

  List<Map<String, dynamic>> dataMatkul = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final service = RekapDosenService();
    final result = await service.getRekapMatkul();

    setState(() {
      dataMatkul = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List filtered = dataMatkul
        .where(
          (m) => m["matkul"].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();

    filtered.sort(
      (a, b) => ascending
          ? a["matkul"].compareTo(b["matkul"])
          : b["matkul"].compareTo(a["matkul"]),
    );

    return Scaffold(
      appBar: const CustomAppBar(role: "dsn"),

      body: Column(
        children: [
          const SizedBox(height: 15),

          const Center(
            child: Text(
              "Rekap Presensi Mata Kuliah",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 15),

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
                    onChanged: (v) => setState(() => searchQuery = v),
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

          const SizedBox(height: 15),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RekapPresensiMatkulPage(data: item),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== HEADER GRADIENT =====
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF222222), Color(0xFF000000)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.menu_book_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item["matkul"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // BADGE "X minggu" → sudah DIHAPUS sesuai permintaan
                            ],
                          ),
                        ),

                        // ===== ISI CARD =====
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green.withOpacity(0.15),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: FutureBuilder(
                                      future: Supabase.instance.client
                                          .from('absensi')
                                          .select('pertemuan')
                                          .eq('jadwal_id', item["jadwal_id"]),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Text("Loading...");
                                        }

                                        final data = snapshot.data as List;
                                        final Set<int> mingguUnik = {};

                                        for (final row in data) {
                                          final minggu = row["pertemuan"];
                                          if (minggu != null && minggu != 0) {
                                            mingguUnik.add(minggu);
                                          }
                                        }

                                        final int terlaksana =
                                            mingguUnik.length;

                                        return Text(
                                          "Perkuliahan terlaksana : $terlaksana pertemuan",
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              Container(height: 1, color: Colors.black12),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.withOpacity(0.15),
                                    ),
                                    child: const Icon(
                                      Icons.schedule_rounded,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: FutureBuilder(
                                      future: Supabase.instance.client
                                          .from('absensi')
                                          .select('pertemuan')
                                          .eq('jadwal_id', item["jadwal_id"]),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Text("Loading...");
                                        }

                                        final data = snapshot.data as List;
                                        final Set<int> mingguUnik = {};

                                        for (final row in data) {
                                          final minggu = row["pertemuan"];
                                          if (minggu != null && minggu != 0) {
                                            mingguUnik.add(minggu);
                                          }
                                        }

                                        final int terlaksana =
                                            mingguUnik.length;
                                        final int belum = 16 - terlaksana;

                                        return Text(
                                          "Belum terlaksana : $belum pertemuan",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // ICON ARROW → DIHAPUS
                            ],
                          ),
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
