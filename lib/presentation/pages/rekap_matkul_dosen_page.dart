import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import 'rekap_detail_dosen_page.dart';

class RekapMatkulDosenPage extends StatefulWidget {
  const RekapMatkulDosenPage({super.key});

  @override
  State<RekapMatkulDosenPage> createState() => _RekapMatkulDosenPageState();
}

class _RekapMatkulDosenPageState extends State<RekapMatkulDosenPage> {
  String searchQuery = "";
  bool ascending = true;

  final List<Map<String, dynamic>> dataMatkul = [
    {"matkul": "Workshop Sistem Analog", "minggu": 14, "hadir": 14, "alpha": 0},
    {
      "matkul": "Praktikum Organisasi Mesin & Bahasa Assembly",
      "minggu": 13,
      "hadir": 13,
      "alpha": 0,
    },
    {
      "matkul": "Organisasi Mesin & Bahasa Assembly",
      "minggu": 13,
      "hadir": 13,
      "alpha": 0,
    },
  ];

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
      appBar: const CustomAppBar(role: "dsn", title: "Rekap Presensi"),

      body: Column(
        children: [
          const SizedBox(height: 8),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "Cari mata kuliah...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // SORT BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                  onPressed: () => setState(() => ascending = !ascending),
                ),
              ],
            ),
          ),

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
                        builder: (_) => RekapDetailDosenPage(data: item),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER HITAM
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            item["matkul"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Waktu : Minggu ke ${item["minggu"]}"),
                              Text("Hadir  : ${item["hadir"]}"),
                              Text("Alpha  : ${item["alpha"]}"),
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
